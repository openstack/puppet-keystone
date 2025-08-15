#
# Class to execute "keystone-manage db_sync
#
# == Parameters
#
# [*extra_params*]
#   (Optional) String of extra command line parameters to append
#   to the keystone-manage db_sync command.  These will be
#   inserted in the command line between 'keystone-manage' and
#   'db_sync' in the command line.
#   Defaults to ''
#
# [*keystone_user*]
#   (Optional) Specify the keystone system user to be used with keystone-manage.
#   Defaults to $keystone::params::user
#
# [*db_sync_timeout*]
#   (Optional) Timeout for the execution of the db_sync
#   Defaults to 300
#
class keystone::db::sync(
  $extra_params    = undef,
  $keystone_user   = $keystone::params::user,
  $db_sync_timeout = 300,
) inherits keystone::params {

  include keystone::deps

  exec { 'keystone-manage db_sync':
    command     => "keystone-manage ${extra_params} db_sync",
    path        => '/usr/bin',
    user        => $keystone_user,
    refreshonly => true,
    try_sleep   => 5,
    tries       => 10,
    timeout     => $db_sync_timeout,
    logoutput   => on_failure,
    subscribe   => [
      Anchor['keystone::install::end'],
      Anchor['keystone::config::end'],
      Anchor['keystone::dbsync::begin']
    ],
    notify      => Anchor['keystone::dbsync::end'],
    tag         => ['keystone-exec', 'openstack-db'],
  }
}
