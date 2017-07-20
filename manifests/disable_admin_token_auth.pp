#
# Class to manage and secure the keystone-paste.ini pipeline configuration.
#
# The keystone module uses the admin_token parameter in keystone.conf to
# bootstrap the basic setup of an admin user, project, and domain. However, the
# admin_token provides an easy vector of attack for production keystone
# installations. Including this class will remove the admin_token_auth
# from the paste pipeline to improve security. After this class is run,
# future puppet runs must have an openrc file with valid keystone v3
# admin credentials in /root/openrc available, or else must be run with
# valid keystone v3 credentials set as environment variables.
#
class keystone::disable_admin_token_auth {

  require ::keystone::roles::admin

  Keystone::Resource::Service_identity<||> -> Class['::keystone::disable_admin_token_auth']

  ini_subsetting { 'public_api/admin_token_auth':
    ensure     => absent,
    path       => '/etc/keystone/keystone-paste.ini',
    section    => 'pipeline:public_api',
    setting    => 'pipeline',
    subsetting => 'admin_token_auth',
    tag        => 'disable-admin-token-auth',
  }
  ini_subsetting { 'admin_api/admin_token_auth':
    ensure     => absent,
    path       => '/etc/keystone/keystone-paste.ini',
    section    => 'pipeline:admin_api',
    setting    => 'pipeline',
    subsetting => 'admin_token_auth',
    tag        => 'disable-admin-token-auth',
  }
  ini_subsetting { 'api_v3/admin_token_auth':
    ensure     => absent,
    path       => '/etc/keystone/keystone-paste.ini',
    section    => 'pipeline:api_v3',
    setting    => 'pipeline',
    subsetting => 'admin_token_auth',
    tag        => 'disable-admin-token-auth',
  }

  Ini_subsetting <| tag == 'disable-admin-token-auth' |>
    ~> Exec<| name == 'restart_keystone' |>
}
