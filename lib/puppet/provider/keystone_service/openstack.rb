require File.join(File.dirname(__FILE__), '..','..','..', 'puppet/provider/keystone')

Puppet::Type.type(:keystone_service).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc "Provider to manage keystone services."

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

  include PuppetX::Keystone::CompositeNamevar::Helpers

  def initialize(value = {})
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
      fail("Not managing Keystone_service[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    properties = [resource[:type]]
    properties << '--name' << resource[:name]
    if resource[:description]
      properties << '--description' << resource[:description]
    end
    created = self.class.request('service', 'create', properties)
    @property_hash[:ensure] = :present
    @property_hash[:type] = resource[:type]
    @property_hash[:id] = created[:id]
    @property_hash[:description] = resource[:description]
  end

  def destroy
    if self.class.do_not_manage
      fail("Not managing Keystone_service[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    self.class.request('service', 'delete', @property_hash[:id])
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  mk_resource_methods

  def description=(value)
    if self.class.do_not_manage
      fail("Not managing Keystone_service[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    @property_flush[:description] = value
  end

  def type=(value)
    if self.class.do_not_manage
      fail("Not managing Keystone_service[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    @property_flush[:type] = value
  end

  def self.instances
    self.do_not_manage = true
    list = request('service', 'list', '--long')
    reallist = list.collect do |service|
      new(
        :name        => resource_to_name(service[:type], service[:name], false),
        :ensure      => :present,
        :type        => service[:type],
        :description => service[:description],
        :id          => service[:id]
      )
    end
    self.do_not_manage = false
    reallist
  end

  def self.prefetch(resources)
    prefetch_composite(resources) do |sorted_namevars|
      name = sorted_namevars[0]
      type = sorted_namevars[1]
      resource_to_name(type, name, false)
    end
  end

  def flush
    options = []
    if @property_flush && !@property_flush.empty?
      options << "--description=#{resource[:description]}" if @property_flush[:description]
      options << "--type=#{resource[:type]}" if @property_flush[:type]
      self.class.request('service', 'set', [@property_hash[:id]] + options) unless options.empty?
      @property_flush.clear
    end
  end
end
