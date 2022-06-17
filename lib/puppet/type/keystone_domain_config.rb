Puppet::Type.newtype(:keystone_domain_config) do

  require File.expand_path(File.join(
                    File.dirname(__FILE__), '..', '..',
                    'puppet_x', 'keystone_config', 'ini_setting'))
  # mixin, shared with keystone_domain_config until this one moves on
  # to openstack cli
  extend PuppetX::KeystoneConfig::IniSetting

  create_parameters

  autonotify(:service) do
    ['keystone']
  end

  # if one declare the domain directory as a resource, this will
  # create a soft dependency with it.
  autorequire(:file) do
    currently_defined = provider.class.find_domain_conf(catalog)
    # we use the catalog and fall back to provider.self.base_dir (see
    # its comment).  Note at this time the @base_dir in
    # provider.class.base_dir will always be false as self.prefetch
    # hasn't run yet.
    currently_defined.nil? ? [provider.class.base_dir] : [currently_defined[:value]]
  end

  # if the keystone configuration is changed we require it
  autorequire(:keystone_config) do
    ['identity/domain_config_dir']
  end
end
