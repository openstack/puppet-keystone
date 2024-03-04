# Class: keystone::db
#
#  Configure the Keystone database
#
# === Parameters
#
# [*database_db_max_retries*]
#   Maximum retries in case of connection error or deadlock error before
#   error is raised. Set to -1 to specify an infinite retry count.
#   (Optional) Defaults to $facts['os_service_default']
#
# [*database_connection*]
#   Url used to connect to database.
#   (Optional) Defaults to 'sqlite:////var/lib/keystone/keystone.sqlite'.
#
# [*database_connection_recycle_time*]
#   Timeout when db connections should be reaped.
#   (Optional) Defaults to $facts['os_service_default']
#
# [*database_max_retries*]
#   Maximum number of database connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   (Optional) Defaults to $facts['os_service_default']
#
# [*database_retry_interval*]
#   Interval between retries of opening a database connection.
#   (Optional) Defaults to $facts['os_service_default']
#
# [*database_max_pool_size*]
#   Maximum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to $facts['os_service_default']
#
# [*database_max_overflow*]
#   If set, use this value for max_overflow with sqlalchemy.
#   (Optional) Defaults to $facts['os_service_default']
#
# [*database_pool_timeout*]
#   (Optional) If set, use this value for pool_timeout with SQLAlchemy.
#   Defaults to $facts['os_service_default']
#
# [*mysql_enable_ndb*]
#   (Optional) If True, transparently enables support for handling MySQL
#   Cluster (NDB).
#   Defaults to $facts['os_service_default']
#
class keystone::db (
  $database_db_max_retries          = $facts['os_service_default'],
  $database_connection              = 'sqlite:////var/lib/keystone/keystone.sqlite',
  $database_connection_recycle_time = $facts['os_service_default'],
  $database_max_pool_size           = $facts['os_service_default'],
  $database_max_retries             = $facts['os_service_default'],
  $database_retry_interval          = $facts['os_service_default'],
  $database_max_overflow            = $facts['os_service_default'],
  $database_pool_timeout            = $facts['os_service_default'],
  $mysql_enable_ndb                 = $facts['os_service_default'],
) {

  include keystone::deps

  oslo::db { 'keystone_config':
    db_max_retries          => $database_db_max_retries,
    connection              => $database_connection,
    connection_recycle_time => $database_connection_recycle_time,
    max_pool_size           => $database_max_pool_size,
    max_retries             => $database_max_retries,
    retry_interval          => $database_retry_interval,
    max_overflow            => $database_max_overflow,
    pool_timeout            => $database_pool_timeout,
    mysql_enable_ndb        => $mysql_enable_ndb,
  }

  # all db settings should be applied and all packages should be installed
  # before dbsync starts
  Oslo::Db['keystone_config'] -> Anchor['keystone::dbsync::begin']
}
