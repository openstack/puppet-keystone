# class: keystone::db
#
#  Configure the Keystone database
#
# === Parameters
#
# [*database_db_max_retries*]
#   Maximum retries in case of connection error or deadlock error before
#   error is raised. Set to -1 to specify an infinite retry count.
#   (Optional) Defaults to $::os_service_default
#
# [*database_connection*]
#   Url used to connect to database.
#   (Optional) Defaults to 'sqlite:////var/lib/keystone/keystone.sqlite'.
#
# [*database_connection_recycle_time*]
#   Timeout when db connections should be reaped.
#   (Optional) Defaults to $::os_service_default
#
# [*database_max_retries*]
#   Maximum number of database connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   (Optional) Defaults to $::os_service_default
#
# [*database_retry_interval*]
#   Interval between retries of opening a database connection.
#   (Optional) Defaults to $::os_service_default
#
# [*database_min_pool_size*]
#   Minimum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to $::os_service_default
#
# [*database_max_pool_size*]
#   Maximum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to $::os_service_default
#
# [*database_max_overflow*]
#   If set, use this value for max_overflow with sqlalchemy.
#   (Optional) Defaults to $::os_service_default
#
# [*database_pool_timeout*]
#   (Optional) If set, use this value for pool_timeout with SQLAlchemy.
#   Defaults to $::os_service_default
#
# DEPRECATED PARAMETERS
#
# [*database_idle_timeout*]
#   Timeout when db connections should be reaped.
#   Defaults to undef.
#
class keystone::db (
  $database_db_max_retries          = $::os_service_default,
  $database_connection              = 'sqlite:////var/lib/keystone/keystone.sqlite',
  $database_connection_recycle_time = $::os_service_default,
  $database_min_pool_size           = $::os_service_default,
  $database_max_pool_size           = $::os_service_default,
  $database_max_retries             = $::os_service_default,
  $database_retry_interval          = $::os_service_default,
  $database_max_overflow            = $::os_service_default,
  $database_pool_timeout            = $::os_service_default,
  # DEPRECATED PARAMETERS
  $database_idle_timeout            = undef,
) {

  include ::keystone::deps

  if $database_idle_timeout {
    warning('The database_idle_timeout parameter is deprecated. Please use \
database_connection_recycle_time instead.')
  }

  # NOTE(spredzy): In order to keep backward compatibility we rely on the pick function
  # to use keystone::<myparam> if keystone::db::<myparam> isn't specified.
  $database_connection_real = pick($::keystone::database_connection, $database_connection)
  $database_connection_recycle_time_real = pick($::keystone::database_idle_timeout, $database_idle_timeout,
                                                $database_connection_recycle_time)
  $database_min_pool_size_real = pick($::keystone::database_min_pool_size, $database_min_pool_size)
  $database_max_pool_size_real = pick($::keystone::database_max_pool_size, $database_max_pool_size)
  $database_max_retries_real = pick($::keystone::database_max_retries, $database_max_retries)
  $database_retry_interval_real = pick($::keystone::database_retry_interval, $database_retry_interval)
  $database_max_overflow_real = pick($::keystone::database_max_overflow, $database_max_overflow)

  validate_legacy(Oslo::Dbconn, 'validate_re', $database_connection_real,
    ['^(sqlite|mysql(\+pymysql)?|postgresql(\+psycopg2)?):\/\/(\S+:\S+@\S+\/\S+)?'])

  oslo::db { 'keystone_config':
    db_max_retries          => $database_db_max_retries,
    connection              => $database_connection_real,
    connection_recycle_time => $database_connection_recycle_time_real,
    min_pool_size           => $database_min_pool_size_real,
    max_pool_size           => $database_max_pool_size_real,
    max_retries             => $database_max_retries_real,
    retry_interval          => $database_retry_interval_real,
    max_overflow            => $database_max_overflow_real,
    pool_timeout            => $database_pool_timeout,
  }

}
