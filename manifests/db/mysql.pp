# The keystone::db::mysql class implements mysql backend for keystone
#
# This class can be used to create tables, users and grant
# privilege for a mysql keystone database.
#
# == Parameters
#
# [*password*]
#   (Required) Password to connect to the database.
#
# [*dbname*]
#   (Optional) Name of the database.
#   Defaults to 'keystone'.
#
# [*user*]
#   (Optional) User to connect to the database.
#   Defaults to 'keystone'.
#
# [*host*]
#   (Optional) The default source host user is allowed to connect from.
#   Defaults to '127.0.0.1'
#
# [*allowed_hosts*]
#   (Optional) Other hosts the user is allowed to connect from.
#   Defaults to 'undef'.
#
# [*charset*]
#   (Optional) The database charset.
#   Defaults to 'utf8'
#
# [*collate*]
#   (Optional) The database collate.
#   Only used with mysql modules >= 2.2.
#   Defaults to 'utf8_general_ci'
#
class keystone::db::mysql(
  String[1] $password,
  $dbname        = 'keystone',
  $user          = 'keystone',
  $host          = '127.0.0.1',
  $charset       = 'utf8',
  $collate       = 'utf8_general_ci',
  $allowed_hosts = undef
) {

  include keystone::deps

  openstacklib::db::mysql { 'keystone':
    user          => $user,
    password      => $password,
    dbname        => $dbname,
    host          => $host,
    charset       => $charset,
    collate       => $collate,
    allowed_hosts => $allowed_hosts,
  }

  Anchor['keystone::db::begin']
  ~> Class['keystone::db::mysql']
  ~> Anchor['keystone::db::end']
}
