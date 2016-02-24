# LP#1408531
File.expand_path('../..', File.dirname(__FILE__)).tap { |dir| $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir) }
File.expand_path('../../../../openstacklib/lib', File.dirname(__FILE__)).tap { |dir| $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir) }
require 'puppet_x/keystone/composite_namevar'
require 'puppet_x/keystone/type'

Puppet::Type.newtype(:keystone_service) do

  desc 'This type can be used to manage keystone services.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the service.'
    newvalues(/\S+/)
  end

  newproperty(:id) do
    include PuppetX::Keystone::Type::ReadOnly
  end

  newparam(:type) do
    isnamevar
    desc 'The type of service'
    include PuppetX::Keystone::Type::Required
  end

  newproperty(:description) do
    desc 'A description of the service.'
    defaultto('')
  end

  # This ensures the service is started and therefore the keystone
  # config is configured IF we need them for authentication.
  # If there is no keystone config, authentication credentials
  # need to come from another source.
  autorequire(:anchor) do
    ['keystone::service::end']
  end

  def self.title_patterns
    PuppetX::Keystone::CompositeNamevar.basic_split_title_patterns(:name, :type)
  end
end
