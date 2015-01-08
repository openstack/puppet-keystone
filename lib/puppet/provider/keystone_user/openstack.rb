require 'net/http'
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
    request('user', 'create', resource[:name], resource[:auth], properties)
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
      response = Net::HTTP.start(url.host, url.port) do |http|
        http.request_post('/v2.0/tokens', creds_hash.to_json, {'Content-Type' => 'application/json'})
      end
      if response.code == 401 || response.code == 403 # 401 => unauthorized, 403 => userDisabled
        return nil
      elsif ! (response.code == 200 || response.code == 203)
        return resource[:password]
      else
        raise(Puppet::Error, "Received bad response while trying to authenticate user: #{response.body}")
      end
    end
  end

  def tenant=(value)
    @property_flush[:project] = value
  end

  def tenant
    instance(resource[:name])[:project]
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
    @instances ||= instances.select { |instance| instance[:name] == name }.first || {}
  end

  def flush
    options = []
    if @property_flush
      (options << '--enable') if @property_flush[:enabled] == :true
      (options << '--disable') if @property_flush[:enabled] == :false
      # There is a --description flag for the set command, but it does not work if the value is empty
      (options << '--password' << resource[:password]) if @property_flush[:password]
      (options << '--email'    << resource[:email])    if @property_flush[:email]
      (options << '--project'  << resource[:tenant])   if @property_flush[:project]
      request('user', 'set', resource[:name], resource[:auth], options) unless options.empty?
    end
  end

end
