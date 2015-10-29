require 'puppet/provider/keystone'

Puppet::Type.type(:keystone_user).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc "Provider to manage keystone users."

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def create
    # see if resource[:domain], or user specified as user::domain
    user_name, user_domain = self.class.name_and_domain(resource[:name], resource[:domain])
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
        options << @property_hash[:id]
        self.class.request('user', 'set', options)
      end
      @property_flush.clear
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  # Types properties
  def enabled
    bool_to_sym(@property_hash[:enabled])
  end

  def enabled=(value)
    @property_flush[:enabled] = value
  end

  def email
    @property_hash[:email]
  end

  def email=(value)
    @property_flush[:email] = value
  end

  def id
    @property_hash[:id]
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
      credentials.username, unused = self.class.name_and_domain(resource[:name], domain)
      # Need to specify a project id to get a project scoped token.  List
      # all of the projects for the user, and use the id from the first one.
      projects = self.class.request('project', 'list', ['--user', id, '--long'])
      if projects && projects[0] && projects[0][:id]
        credentials.project_id = projects[0][:id]
      else
        # last chance - try a domain scoped token
        credentials.domain_name = domain
      end
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
    @property_flush[:password] = value
  end

  def replace_password
    @property_hash[:replace_password]
  end

  def replace_password=(value)
    @property_flush[:replace_password] = value
  end

  def domain
    @property_hash[:domain]
  end

  def domain_id
    @property_hash[:domain_id]
  end

  def self.instances
    users = request('user', 'list', ['--long'])
    users.collect do |user|
      domain_name = domain_name_from_id(user[:domain_id])
      user_name = set_domain_for_name(user[:name], domain_name)
      new(
        :name        => user_name,
        :ensure      => :present,
        :enabled     => user[:enabled].downcase.chomp == 'true' ? true : false,
        :password    => user[:password],
        :email       => user[:email],
        :description => user[:description],
        :domain      => domain_name,
        :domain_id   => user[:domain_id],
        :id          => user[:id]
      )
    end
  end

  def self.prefetch(resources)
    users = instances
    resources.each do |resname, resource|
      # resname may be specified as just "name" or "name::domain"
      name, resdomain = name_and_domain(resname, resource[:domain])
      provider = users.find do |user|
        # have a match if the full instance name matches the full resource name, OR
        # the base resource name matches the base instance name, and the
        # resource domain matches the instance domain
        username, user_domain = name_and_domain(user.name, user.domain)
        (user.name == resname) ||
          ((username == name) && (user_domain == resdomain))
      end
      resource.provider = provider if provider
    end
  end

end
