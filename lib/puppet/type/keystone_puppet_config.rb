Puppet::Type.newtype(:keystone_puppet_config) do
  require File.expand_path(File.join(
                    File.dirname(__FILE__), '..', '..',
                    'puppet_x', 'keystone_config', 'ini_setting'))
  extend PuppetX::KeystoneConfig::IniSetting

  create_parameters

  autorequire(:file) do
    ['/etc/keystone/puppet.conf']
  end
end
