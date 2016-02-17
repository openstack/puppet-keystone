require 'puppet/provider/keystone'

Puppet::Type.type(:keystone_user).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc "Provider to manage keystone users."

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

  include PuppetX::Keystone::CompositeNamevar::Helpers

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.do_not_manage
    @do_not_manage
  end

  def self.do_not_manage=(value)
    @do_not_manage = value
  end

  def create
    if self.class.do_not_manage
      fail("Not managing Keystone_user[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    user_name, user_domain = resource[:name], resource[:domain]
    properties = [user_name]
    if resource[:enabled] == :true
      properties << '--enable'
    elsif resource[:enabled] == :false
      properties << '--disable'
    end
    if resource[:password]
      properties << '--password' << resource[:password]
    end
    if resource[:email]
      properties << '--email' << resource[:email]
    end
    if user_domain
      properties << '--domain'
      properties << user_domain
    end
    @property_hash = self.class.request('user', 'create', properties)
    @property_hash[:name] = resource[:name]
    @property_hash[:domain] = user_domain
    @property_hash[:ensure] = :present
  end

  def destroy
    if self.class.do_not_manage
      fail("Not managing Keystone_user[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    self.class.request('user', 'delete', id)
    @property_hash.clear
  end

  def flush
    options = []
    if @property_flush && !@property_flush.empty?
      options << '--enable'  if @property_flush[:enabled] == :true
      options << '--disable' if @property_flush[:enabled] == :false
      # There is a --description flag for the set command, but it does not work if the value is empty
      options << '--password' << resource[:password] if @property_flush[:password]
      options << '--email'    << resource[:email]    if @property_flush[:email]
      # project handled in tenant= separately
      unless options.empty?
        options << id
        self.class.request('user', 'set', options)
      end
      @property_flush.clear
    end
  end

  mk_resource_methods

  def exists?
    @property_hash[:ensure] == :present
  end

  # Types properties
  def enabled
    bool_to_sym(@property_hash[:enabled])
  end

  def enabled=(value)
    if self.class.do_not_manage
      fail("Not managing Keystone_user[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    @property_flush[:enabled] = value
  end

  def email=(value)
    if self.class.do_not_manage
      fail("Not managing Keystone_user[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    @property_flush[:email] = value
  end

  def password
    passwd = nil
    return passwd if resource[:password] == nil
    if resource[:enabled] == :false || resource[:replace_password] == :false
      # Unchanged password
      passwd = resource[:password]
    else
      # Password validation
      credentials = Puppet::Provider::Openstack::CredentialsV3.new
      unless credentials.auth_url = self.class.get_auth_url
        raise(Puppet::Error::OpenstackAuthInputError, "Could not find authentication url to validate user's password.")
      end
      credentials.password = resource[:password]
      credentials.user_id = id

      # NOTE: The only reason we use username is so that the openstack provider
      # will know we are doing v3password auth - otherwise, it is not used.  The
      # user_id uniquely identifies the user including domain.
      credentials.username = resource[:name]
      # Need to specify a project id to get a project scoped token.  List
      # all of the projects for the user, and use the id from the first one.
      projects = self.class.request('project', 'list', ['--user', id, '--long'])
      if projects && projects[0] && projects[0][:id]
        credentials.project_id = projects[0][:id]
      else
        # last chance - try a domain scoped token
        credentials.domain_name = domain
      end

      credentials.identity_api_version = '2' if credentials.auth_url =~ /v2\.0\/?$/

      begin
        token = Puppet::Provider::Openstack.request('token', 'issue', ['--format', 'value'], credentials)
      rescue Puppet::Error::OpenstackUnauthorizedError
        # password is invalid
      else
        passwd = resource[:password] unless token.empty?
      end
    end
    return passwd
  end

  def password=(value)
    if self.class.do_not_manage
      fail("Not managing Keystone_user[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    @property_flush[:password] = value
  end

  def replace_password
    @property_hash[:replace_password]
  end

  def replace_password=(value)
    if self.class.do_not_manage
      fail("Not managing Keystone_user[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    @property_flush[:replace_password] = value
  end

  def domain
    @property_hash[:domain]
  end

  def domain_id
    @property_hash[:domain_id]
  end

  def self.instances
    if default_domain_changed
      warning(default_domain_deprecation_message)
    end
    self.do_not_manage = true
    users = request('user', 'list', ['--long'])
    list = users.collect do |user|
      domain_name = domain_name_from_id(user[:domain])
      new(
        :name        => resource_to_name(domain_name, user[:name]),
        :ensure      => :present,
        :enabled     => user[:enabled].downcase.chomp == 'true' ? true : false,
        :password    => user[:password],
        :email       => user[:email],
        :description => user[:description],
        :domain      => domain_name,
        :domain_id   => user[:domain],
        :id          => user[:id]
      )
    end
    self.do_not_manage = false
    list
  end

  def self.prefetch(resources)
    prefetch_composite(resources) do |sorted_namevars|
      domain = sorted_namevars[0]
      name   = sorted_namevars[1]
      resource_to_name(domain, name)
    end
  end

end
