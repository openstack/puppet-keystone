# Class to disable the Keystone v2.0 API via keystone-paste.ini.
#
# This class removes the /v2.0 entries for Keystone, ensuring that the
# only supported API's are v3. After this class is executed, the
# standard overcloudrc file will no longer work, the user needs to
# utilise the overcloudrc.v3 openrc file, or alternatively the clients
# must be using valid keystone v3 credentials set as environment variables.
#

class keystone::disable_v2_api {

  require ::keystone::roles::admin

  Keystone::Resource::Service_identity<||> -> Class['::keystone::disable_v2_api']
  ini_setting { 'disable_admin/v2.0':
    ensure  => absent,
    path    => '/etc/keystone/keystone-paste.ini',
    section => 'composite:admin',
    setting => '/v2.0',
    value   => undef,
    tag     => 'disable-v2.0-api',
  }
  ini_setting { 'disable_main/v2.0':
    ensure  => absent,
    path    => '/etc/keystone/keystone-paste.ini',
    section => 'composite:main',
    setting => '/v2.0',
    value   => undef,
    tag     => 'disable-v2.0-api',
  }
  Ini_subsetting <| tag == 'disable-v2.0-api' |>
    ~> Exec<| name == 'restart_keystone' |>
}
