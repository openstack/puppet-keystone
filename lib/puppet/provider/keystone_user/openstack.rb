require 'net/http'
require 'json'
require 'puppet/provider/keystone'
Puppet::Type.type(:keystone_user).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc "Provider to manage keystone users."

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def create
    properties = []
    if resource[:enabled] == :true
      properties << '--enable'
    elsif resource[:enabled] == :false
      properties << '--disable'
    end
    if resource[:password]
      properties << '--password'
      properties << resource[:password]
    end
    if resource[:tenant]
      properties << '--project'
      properties << resource[:tenant]
    end
    if resource[:email]
      properties << '--email'
      properties << resource[:email]
    end
    @instance = request('user', 'create', resource[:name], resource[:auth], properties)
  end

  def exists?
    ! instance(resource[:name]).empty?
  end

  def destroy
    request('user', 'delete', resource[:name], resource[:auth])
  end


  def enabled=(value)
    @property_flush[:enabled] = value
  end

  def enabled
    bool_to_sym(instance(resource[:name])[:enabled])
  end


  def password=(value)
    @property_flush[:password] = value
  end

  def password
    # if we don't know a password we can't test it
    return nil if resource[:password] == nil
    # if the user is disabled then the password can't be changed
    return resource[:password] if resource[:enabled] == :false
    # if replacing password is disabled, then don't change it
    return resource[:password] if resource[:replace_password] == :false
    # we can't get the value of the password but we can test to see if the one we know
    # about works, if it doesn't then return nil, causing it to be reset
    endpoint = nil
    if password_credentials_set?(resource[:auth]) || service_credentials_set?(resource[:auth])
      endpoint = (resource[:auth])['auth_url']
    elsif openrc_set?(resource[:auth])
      endpoint = get_credentials_from_openrc(resource[:auth])['auth_url']
    elsif env_vars_set?
      endpoint = ENV['OS_AUTH_URL']
    else
      # try to get endpoint from keystone.conf
      endpoint = get_admin_endpoint
    end
    if endpoint == nil
      raise(Puppet::Error::OpenstackAuthInputError, 'Could not find auth url to check user password.')
    else
      auth_params = {
        'username'    => resource[:name],
        'password'    => resource[:password],
        'tenant_name' => resource[:tenant],
        'auth_url'    => endpoint,
      }
      # LP#1408754
      # Ideally this would be checked with the `openstack token issue` command,
      # but that command is not available with version 0.3.0 of openstackclient
      # which is what ships on Ubuntu during Juno.
      # Instead we'll check whether the user can authenticate with curl.
      creds_hash = {
        :auth => {
          :passwordCredentials => {
            :username => auth_params['username'],
            :password => auth_params['password'],
          }
        }
      }
      url = URI.parse(endpoint)
      # There is issue with ipv6 where address has to be in brackets, this causes the
      # underlying ruby TCPSocket to fail. Net::HTTP.new will fail without brackets on
      # joining the ipv6 address with :port or passing brackets to TCPSocket. It was
      # found that if we use Net::HTTP.start with url.hostname the incriminated code
      # won't be hit.
      use_ssl = url.scheme == "https" ? true : false
      http = Net::HTTP.start(url.hostname, url.port, {:use_ssl => use_ssl})
      request = Net::HTTP::Post.new('/v2.0/tokens')
      request.body = creds_hash.to_json
      request.content_type = 'application/json'
      response = http.request(request)
      if response.code.to_i == 401 || response.code.to_i == 403 # 401 => unauthorized, 403 => userDisabled
        return nil
      elsif ! (response.code == 200 || response.code == 203)
        return resource[:password]
      else
        raise(Puppet::Error, "Received bad response while trying to authenticate user: #{response.body}")
      end
    end
  end

  def tenant=(value)
    begin
      request('user', 'set', resource[:name], resource[:auth], '--project', value)
    rescue Puppet::ExecutionFailure => e
      if e.message =~ /You are not authorized to perform the requested action: LDAP user update/
        # read-only LDAP identity backend - just fall through
      else
        raise e
      end
      # note: read-write ldap will silently fail, not raise an exception
    end
    set_project(value)
  end

  def tenant
    return resource[:tenant] if sym_to_bool(resource[:ignore_default_tenant])
    # use the one returned from instances
    tenant_name = instance(resource[:name])[:project]
    if tenant_name.nil? or tenant_name.empty?
      # if none (i.e. ldap backend) use the given one
      tenant_name = resource[:tenant]
    else
      return tenant_name
    end
    if tenant_name.nil? or tenant_name.empty?
      return nil # nothing found, nothing given
    end
    # If the user list command doesn't report the project, it might still be there
    # We don't need to know exactly what it is, we just need to know whether it's
    # the one we're trying to set.
    roles = request('user role', 'list', resource[:name], resource[:auth], ['--project', tenant_name])
    if roles.empty?
      return nil
    else
      return tenant_name
    end
  end

  def replace_password
    instance(resource[:name])[:replace_password]
  end

  def replace_password=(value)
    @property_flush[:replace_password] = value
  end

  def email=(value)
    @property_flush[:email] = value
  end

  def email
    instance(resource[:name])[:email]
  end

  def id
    instance(resource[:name])[:id]
  end

  def self.instances
    list = request('user', 'list', nil, nil, '--long')
    list.collect do |user|
      new(
        :name        => user[:name],
        :ensure      => :present,
        :enabled     => user[:enabled].downcase.chomp == 'true' ? true : false,
        :password    => user[:password],
        :tenant      => user[:project],
        :email       => user[:email],
        :id          => user[:id]
      )
    end
  end

  def instances
    instances = request('user', 'list', nil, resource[:auth], '--long')
    instances.collect do |user|
      {
        :name        => user[:name],
        :enabled     => user[:enabled].downcase.chomp == 'true' ? true : false,
        :password    => user[:password],
        :project     => user[:project],
        :email       => user[:email],
        :id          => user[:id]
      }
    end
  end

  def instance(name)
    @instance ||= instances.select { |instance| instance[:name] == name }.first || {}
  end

  def set_project(newproject)
    # some backends do not store the project/tenant in the user object, so we have to
    # to modify the project/tenant instead
    # First, see if the project actually needs to change
    roles = request('user role', 'list', resource[:name], resource[:auth], ['--project', newproject])
    unless roles.empty?
      return # if already set, just skip
    end
    # Currently the only way to assign a user to a tenant not using user-create
    # is to use user-role-add - this means we also need a role - there is usual
    # a default role called _member_ which can be used for this purpose.  What
    # usually happens in a puppet module is that immediately after calling
    # keystone_user, the module will then assign a role to that user.  It is
    # ok for a user to have the _member_ role and another role.
    default_role = "_member_"
    begin
      request('role', 'show', default_role, resource[:auth])
    rescue
      debug("Keystone role #{default_role} does not exist - creating")
      request('role', 'create', default_role, resource[:auth])
    end
    request('role', 'add', default_role, resource[:auth],
            '--project', newproject, '--user', resource[:name])
  end

  def flush
    options = []
    if @property_flush
      (options << '--enable') if @property_flush[:enabled] == :true
      (options << '--disable') if @property_flush[:enabled] == :false
      # There is a --description flag for the set command, but it does not work if the value is empty
      (options << '--password' << resource[:password]) if @property_flush[:password]
      (options << '--email'    << resource[:email])    if @property_flush[:email]
      # project handled in tenant= separately
      request('user', 'set', resource[:name], resource[:auth], options) unless options.empty?
    end
  end

end
