require 'puppet/provider/keystone'

Puppet::Type.type(:keystone_tenant).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc "Provider to manage keystone tenants/projects."

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

  include PuppetX::Keystone::CompositeNamevar::Helpers

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def create
    properties = [resource[:name]]
    if resource[:enabled] == :true
      properties << '--enable'
    elsif resource[:enabled] == :false
      properties << '--disable'
    end
    if resource[:description]
      properties << '--description'
      properties << resource[:description]
    end
    properties << '--domain'
    properties << resource[:domain]

    @property_hash = self.class.request('project', 'create', properties)
    @property_hash[:name]   = resource[:name]
    @property_hash[:domain] = resource[:domain]
    @property_hash[:ensure] = :present
  rescue Puppet::ExecutionFailure => e
    if e.message =~ /No domain with a name or ID of/
      raise(Puppet::Error, "No project #{resource[:name]} with domain #{resource[:domain]} found")
    else
      raise
    end
  end

  mk_resource_methods

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    self.class.request('project', 'delete', id)
    @property_hash.clear
  end

  def enabled=(value)
    @property_flush[:enabled] = value
  end

  def enabled
    bool_to_sym(@property_hash[:enabled])
  end

  def description=(value)
    @property_flush[:description] = value
  end

  def self.instances
    if default_domain_changed
      warning(default_domain_deprecation_message)
    end
    projects = request('project', 'list', '--long')
    projects.collect do |project|
      domain_name = domain_name_from_id(project[:domain_id])
      new(
        :name        => resource_to_name(domain_name, project[:name]),
        :ensure      => :present,
        :enabled     => project[:enabled].downcase.chomp == 'true' ? true : false,
        :description => project[:description],
        :domain      => domain_name,
        :domain_id   => project[:domain_id],
        :id          => project[:id]
      )
    end
  end

  def self.prefetch(resources)
    prefetch_composite(resources) do |sorted_namevars|
      domain = sorted_namevars[0]
      name   = sorted_namevars[1]
      resource_to_name(domain, name)
    end
  end

  def flush
    options = []
    if @property_flush && !@property_flush.empty?
      case @property_flush[:enabled]
      when :true
        options << '--enable'
      when :false
        options << '--disable'
      end
      (options << "--description=#{resource[:description]}") if @property_flush[:description]
      self.class.request('project', 'set', [id] + options) unless options.empty?
      @property_flush.clear
    end
  end
end
