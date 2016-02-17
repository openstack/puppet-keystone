require 'puppet/provider/keystone'

Puppet::Type.type(:keystone_role).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc 'Provider for keystone roles.'

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

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
      fail("Not managing Keystone_role[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    self.class.request('role', 'create', name)
    @property_hash[:ensure] = :present
  end

  def destroy
    if self.class.do_not_manage
      fail("Not managing Keystone_role[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    self.class.request('role', 'delete', @property_hash[:id])
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def id
    @property_hash[:id]
  end

  def self.instances
    self.do_not_manage = true
    list = request('role', 'list')
    reallist = list.collect do |role|
      new(
        :name        => role[:name],
        :ensure      => :present,
        :id          => role[:id]
      )
    end
    self.do_not_manage = false
    reallist
  end

  def self.prefetch(resources)
    roles = instances
    resources.keys.each do |name|
       if provider = roles.find{ |role| role.name == name }
        resources[name].provider = provider
      end
    end
  end
end
