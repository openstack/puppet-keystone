Puppet::Type.newtype(:keystone_config) do

  require File.expand_path(File.join(
                    File.dirname(__FILE__), '..', '..',
                    'puppet_x', 'keystone_config', 'ini_setting'))
  # mixin, shared with keystone_domain_config until this one moves on
  # to openstack cli
  extend PuppetX::KeystoneConfig::IniSetting

  create_parameters

end
