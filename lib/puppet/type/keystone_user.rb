# LP#1408531
File.expand_path('../..', File.dirname(__FILE__)).tap { |dir| $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir) }
File.expand_path('../../../../openstacklib/lib', File.dirname(__FILE__)).tap { |dir| $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir) }

require 'puppet/provider/keystone/util'
require 'puppet_x/keystone/composite_namevar'
require 'puppet_x/keystone/type'

Puppet::Type.newtype(:keystone_user) do

  desc 'Type for managing keystone users.'

  ensurable

  newparam(:name, :namevar => true) do
    newvalues(/\S+/)
  end

  newproperty(:enabled) do
    newvalues(/(t|T)rue/, /(f|F)alse/, true, false)
    defaultto(true)
    munge do |value|
      value.to_s.downcase.to_sym
    end
  end

  newproperty(:password) do
    newvalues(/\S+/)
    def change_to_s(currentvalue, newvalue)
      if currentvalue == :absent
        return 'created password'
      else
        return 'changed password'
      end
    end

    def is_to_s( currentvalue )
      return '[old password redacted]'
    end

    def should_to_s( newvalue )
      return '[new password redacted]'
    end
  end

  newproperty(:email) do
    newvalues(/^(\S+@\S+)|$/)
  end

  newproperty(:id) do
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  newparam(:replace_password) do
    newvalues(/(t|T)rue/, /(f|F)alse/, true, false)
    defaultto(true)
    munge do |value|
      value.to_s.downcase.to_sym
    end
  end

  newparam(:domain) do
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

  # we should not do anything until the keystone service is started
  autorequire(:anchor) do
    ['keystone::service::end', 'default_domain_created']
  end

  def self.title_patterns
    PuppetX::Keystone::CompositeNamevar.basic_split_title_patterns(:name, :domain)
  end
end
