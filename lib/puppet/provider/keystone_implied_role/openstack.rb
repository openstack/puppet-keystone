require File.join(File.dirname(__FILE__), '..','..','..', 'puppet/provider/keystone')
require File.join(File.dirname(__FILE__), '..','..','..', 'puppet_x/keystone/composite_namevar')

Puppet::Type.type(:keystone_implied_role).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc 'Provider for keystone implied roles.'

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

  include PuppetX::Keystone::CompositeNamevar::Helpers

  def initialize(value={})
    super(value)
  end

  def self.do_not_manage
    @do_not_manage
  end

  def self.do_not_manage=(value)
    @do_not_manage = value
  end

  def create
    if self.class.do_not_manage
      fail("Not managing Keystone_implied_role[#{@resource[:role]}@#{@resource[:implied_role]}] due to earlier Keystone API failures.")
    end
    self.class.system_request('implied role', 'create', [@resource[:role], '--implied-role', @resource[:implied_role]])
    @property_hash[:ensure] = :present
    @property_hash[:role] = @resource[:role]
    @property_hash[:implied_role] = @resource[:implied_role]
  end

  def destroy
    if self.class.do_not_manage
      fail("Not managing Keystone_implied_role[#{@resource[:role]}@#{@resource[:implied_role]}] due to earlier Keystone API failures.")
    end
    self.class.system_request('implied role', 'delete', [@resource[:role], '--implied-role', @resource[:implied_role]])
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  mk_resource_methods

  [
    :role,
    :implied_role,
  ].each do |attr|
    define_method(attr.to_s + "=") do |value|
      fail("Property #{attr.to_s} does not support being updated")
    end
  end

  def self.instances
    self.do_not_manage = true
    list = system_request('implied role', 'list')
    reallist = list.collect do |role|
      new(
        :ensure       => :present,
        :role         => role[:prior_role_name].downcase,
        :implied_role => role[:implied_role_name].downcase,
      )
    end
    self.do_not_manage = false
    reallist
  end

  def self.prefetch(resources)
    prefetch_composite(resources)
  end
end
