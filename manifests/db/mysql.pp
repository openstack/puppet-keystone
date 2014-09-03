# The keystone::db::mysql class implements mysql backend for keystone
#
# This class can be used to create tables, users and grant
# privelege for a mysql keystone database.
#
# == parameters
#
# [password] Password that will be used for the keystone db user.
#   Optional. Defaults to: 'keystone_default_password'
#
# [dbname] Name of keystone database. Optional. Defaults to keystone.
#
# [user] Name of keystone user. Optional. Defaults to keystone.
#
# [host] Host where user should be allowed all priveleges for database.
# Optional. Defaults to 127.0.0.1.
#
# [allowed_hosts] Hosts allowed to use the database
#
# [*mysql_module*] Deprecated. Does nothing.
#
# == Dependencies
#   Class['mysql::server']
#
# == Examples
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2012 Puppetlabs Inc, unless otherwise noted.
#
class keystone::db::mysql(
  $password,
  $dbname        = 'keystone',
  $user          = 'keystone',
  $host          = '127.0.0.1',
  $charset       = 'utf8',
  $collate       = 'utf8_unicode_ci',
  $mysql_module  = undef,
  $allowed_hosts = undef
) {

  if $mysql_module {
    warning('The mysql_module parameter is deprecated. The latest 2.x mysql module will be used.')
  }

  validate_string($password)

  ::openstacklib::db::mysql { 'keystone':
    user          => $user,
    password_hash => mysql_password($password),
    dbname        => $dbname,
    host          => $host,
    charset       => $charset,
    collate       => $collate,
    allowed_hosts => $allowed_hosts,
  }

  ::Openstacklib::Db::Mysql['keystone'] ~> Exec<| title == 'keystone-manage db_sync' |>
}
