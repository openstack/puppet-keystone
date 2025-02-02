require 'puppet_x/keystone/composite_namevar'
require 'puppet_x/keystone/type'

Puppet::Type.newtype(:keystone_tenant) do

  desc 'This type can be used to manage keystone tenants.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the tenant.'
    newvalues(/\w+/)
  end

  newproperty(:enabled) do
    desc 'Whether the tenant should be enabled. Defaults to true.'
    newvalues(/(t|T)rue/, /(f|F)alse/, true, false )
    defaultto(true)
    munge do |value|
      value.to_s.downcase.to_sym
    end
  end

  newproperty(:description) do
    desc 'A description of the tenant.'
  end

  newproperty(:id) do
    desc 'Read-only property of the tenant.'
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newparam(:domain) do
    desc 'Domain for tenant.'
    isnamevar
    include PuppetX::Keystone::Type::DefaultDomain
  end

  autorequire(:keystone_domain) do
    default_domain = catalog.resources.find do |r|
      r.class.to_s == 'Puppet::Type::Keystone_domain' &&
        r[:is_default] == :true &&
        r[:ensure] == :present
    end
    rv = [self[:domain]]
    # Only used to display the deprecation warning.
    rv << default_domain.name unless default_domain.nil?
    rv
  end

  # This ensures the service is started and therefore the keystone
  # config is configured IF we need them for authentication.
  # If there is no keystone config, authentication credentials
  # need to come from another source.
  autorequire(:anchor) do
    ['keystone::service::end', 'default_domain_created']
  end

  def self.title_patterns
    PuppetX::Keystone::CompositeNamevar.basic_split_title_patterns(:name, :domain)
  end
end
