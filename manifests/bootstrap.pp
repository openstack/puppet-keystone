# == Class: keystone::bootstrap
#
# Bootstrap keystone with keystone-manage bootstrap.
#
# === Parameters
#
# [*password*]
#   (Required) The password for the user.
#
# [*username*]
#   (Optional) The username.
#   Defaults to 'admin'
#
# [*email*]
#   (Optional) The email for the user.
#   Defaults to 'admin@localhost'
#
# [*project_name*]
#   (Optional) The project name.
#   Defaults to 'admin'
#
# [*service_project_name*]
#   (Optional) The service project name.
#   Defaults to 'services'
#
# [*role_name*]
#   (Optional) The role name.
#   Defaults to 'admin'
#
# [*service_name*]
#   (Optional) The service name.
#   Defaults to 'keystone'
#
# [*admin_url*]
#   (Optional) Admin URL for Keystone endpoint.
#   This url should *not* contain any version or trailing '/'.
#   Defaults to 'http://127.0.0.1:5000'
#
# [*public_url*]
#   (Optional) Public URL for Keystone endpoint.
#   This URL should *not* contain any version or trailing '/'.
#   Defaults to 'http://127.0.0.1:5000'
#
# [*internal_url*]
#   (Optional) Internal URL for Keystone endpoint.
#   This URL should *not* contain any version or trailing '/'.
#   Defaults to $public_url
#
# [*region*]
#   (Optional) Region for endpoint.
#   Defaults to 'RegionOne'
#
# [*interface*]
#   (Optional) Which interface endpoint should be used.
#    Defaults to 'public'
#
class keystone::bootstrap (
  $password,
  $username             = 'admin',
  $email                = 'admin@localhost',
  $project_name         = 'admin',
  $service_project_name = 'services',
  $role_name            = 'admin',
  $service_name         = 'keystone',
  $admin_url            = 'http://127.0.0.1:5000',
  $public_url           = 'http://127.0.0.1:5000',
  $internal_url         = undef,
  $region               = 'RegionOne',
  $interface            = 'public',
) inherits keystone::params {

  include keystone::deps

  $internal_url_real = $internal_url ? {
    undef   => $public_url,
    default => $internal_url
  }

  if defined('$::keystone::keystone_user') {
    $keystone_user = $::keystone::keystone_user
  } else {
    $keystone_user = $::keystone::params::keystone_user
  }

  # The initial bootstrap that creates all resources required but
  # only subscribes to notifies from the keystone::dbsync::end anchor
  # which means this is not guaranteed to execute on each run.
  exec { 'keystone bootstrap':
    command     => 'keystone-manage bootstrap',
    environment => [
      "OS_BOOTSTRAP_USERNAME=${username}",
      "OS_BOOTSTRAP_PASSWORD=${password}",
      "OS_BOOTSTRAP_PROJECT_NAME=${project_name}",
      "OS_BOOTSTRAP_ROLE_NAME=${role_name}",
      "OS_BOOTSTRAP_SERVICE_NAME=${service_name}",
      "OS_BOOTSTRAP_ADMIN_URL=${admin_url}",
      "OS_BOOTSTRAP_PUBLIC_URL=${public_url}",
      "OS_BOOTSTRAP_INTERNAL_URL=${internal_url_real}",
      "OS_BOOTSTRAP_REGION_ID=${region}",
    ],
    user        => $keystone_user,
    path        => '/usr/bin',
    refreshonly => true,
    subscribe   => Anchor['keystone::dbsync::end'],
    notify      => Anchor['keystone::service::begin'],
    tag         => 'keystone-bootstrap',
  }

  # Since the bootstrap is not guaranteed to execute on each run we
  # use the below resources to make sure the current resources are
  # correct so if some value was updated we set that.

  ensure_resource('keystone_role', $role_name, {
    'ensure' => 'present',
  })

  ensure_resource('keystone_user', $username, {
    'ensure'   => 'present',
    'enabled'  => true,
    'email'    => $email,
    'password' => $password,
  })

  ensure_resource('keystone_tenant', $service_project_name, {
    'ensure'  => 'present',
    'enabled' => true,
  })

  ensure_resource('keystone_tenant', $project_name, {
    'ensure'  => 'present',
    'enabled' => true,
  })

  ensure_resource('keystone_user_role', "${username}@${project_name}", {
    'ensure' => 'present',
    'roles'  => $role_name,
  })

  ensure_resource('keystone_service', "${service_name}::identity", {
    'ensure' => 'present',
  })

  ensure_resource('keystone_endpoint', "${region}/${service_name}::identity", {
    'ensure'       => 'present',
    'public_url'   => $public_url,
    'admin_url'    => $admin_url,
    'internal_url' => $internal_url_real,
  })

  # The below creates and populates the /etc/keystone/puppet.conf file that contains
  # the credentials that can be loaded by providers. Ensure it has the proper owner,
  # group and mode so that it cannot be read by anything other than root.
  file { '/etc/keystone/puppet.conf':
    ensure  => 'present',
    replace => false,
    content => '',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Anchor['keystone::install::end'],
  }

  if $interface == 'admin' {
    $auth_url_real = $admin_url
  } elsif $interface == 'internal' {
    $auth_url_real = $internal_url_real
  } else {
    $auth_url_real = $public_url
  }

  keystone::resource::authtoken { 'keystone_puppet_config':
    username     => $username,
    password     => $password,
    auth_url     => $auth_url_real,
    project_name => $project_name,
    region_name  => $region,
    interface    => $interface,
  }
}
