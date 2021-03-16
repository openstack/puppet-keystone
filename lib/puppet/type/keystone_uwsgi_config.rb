Puppet::Type.newtype(:keystone_uwsgi_config) do
  require File.expand_path(File.join(
                    File.dirname(__FILE__), '..', '..',
                    'puppet_x', 'keystone_config', 'ini_setting'))
  extend PuppetX::KeystoneConfig::IniSetting

  create_parameters

  autorequire(:file) do
    ['/etc/keystone/keystone-uwsgi.ini']
  end
end
