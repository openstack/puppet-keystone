require File.join(File.dirname(__FILE__), '..','..','..', 'puppet/provider/keystone')

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
    properties = [resource[:name]]
    if resource[:enabled] == :true
      properties << '--enable'
    elsif resource[:enabled] == :false
      properties << '--disable'
    end
    if resource[:password]
      properties << '--password' << resource[:password]
    end
    if resource[:description]
      properties << '--description' << resource[:description]
    end
    if resource[:email]
      properties << '--email' << resource[:email]
    end
    properties << '--domain' << resource[:domain]
    @property_hash = self.class.system_request('user', 'create', properties)
    @property_hash[:name] = resource[:name]
    @property_hash[:domain] = resource[:domain]
    @property_hash[:ensure] = :present
  end

  def destroy
    self.class.system_request('user', 'delete', id)
    @property_hash.clear
  end

  def flush
    options = []
    if @property_flush && !@property_flush.empty?
      options << '--enable'  if @property_flush[:enabled] == :true
      options << '--disable' if @property_flush[:enabled] == :false
      # There is a --description flag for the set command, but it does not work if the value is empty
      options << '--password' << resource[:password] if @property_flush[:password]
      options << '--description' << resource[:description] if @property_flush[:description]
      options << '--email'    << resource[:email]    if @property_flush[:email]
      # project handled in tenant= separately
      unless options.empty?
        options << id
        self.class.system_request('user', 'set', options)
      end
      @property_flush.clear
    end
  end

  mk_resource_methods

  def exists?
    return true if @property_hash[:ensure] == :present
    domain_name = self.class.domain_id_from_name(resource[:domain])
    @property_hash =
      self.class.fetch_user(resource[:name], domain_name)
    @property_hash ||= {}
    # This can happen in bad LDAP mapping
    @property_hash[:enabled] = 'true' if @property_hash[:enabled].nil?
    @property_hash[:domain] = domain_name

    return false if @property_hash.nil? || @property_hash[:id].nil?
    true
  end

  # Types properties
  def enabled
    is_enabled = @property_hash[:enabled].downcase.chomp == 'true' ? true : false
    bool_to_sym(is_enabled)
  end

  def enabled=(value)
    @property_flush[:enabled] = value
  end

  def description=(value)
    @property_flush[:description] = value
  end

  def email=(value)
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

end
