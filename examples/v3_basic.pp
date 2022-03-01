Exec { logoutput => 'on_failure' }


class { 'mysql::server': }
class { 'keystone::db::mysql':
  password => 'keystone',
}
class { 'keystone::db':
  database_connection => 'mysql://keystone:keystone@127.0.0.1/keystone',
}
class { 'keystone':
  debug   => true,
  enabled => true,
}
class { 'keystone::bootstrap':
  password => 'a_big_secret',
}
