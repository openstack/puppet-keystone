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
# [*service_description*]
#   (Optional) Description for keystone service.
#   Defaults to 'OpenStack Identity Service'.
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
# [*bootstrap*]
#   (Optional) Whether to run keystone-manage bootstrap command.
#   Defaults to true
#
# [*manage_resources*]
#   (Optional) Whether to manage resources created by bootstrap.
#   Defaults to true
#
class keystone::bootstrap (
  String[1] $password,
  String[1] $username                                   = 'admin',
  String[1] $email                                      = 'admin@localhost',
  String[1] $project_name                               = 'admin',
  String[1] $service_project_name                       = 'services',
  String[1] $role_name                                  = 'admin',
  String[1] $service_name                               = 'keystone',
  String[1] $service_description                        = 'OpenStack Identity Service',
  Keystone::KeystoneEndpointUrl $admin_url              = 'http://127.0.0.1:5000',
  Keystone::KeystonePublicEndpointUrl $public_url       = 'http://127.0.0.1:5000',
  Optional[Keystone::KeystoneEndpointUrl] $internal_url = undef,
  String[1] $region                                     = 'RegionOne',
  Enum['public', 'internal', 'admin'] $interface        = 'public',
  Boolean $bootstrap                                    = true,
  Boolean $manage_resources                             = true,
) inherits keystone::params {

  include keystone::deps

  $internal_url_real = $internal_url ? {
    undef   => $public_url,
    default => $internal_url
  }

  if defined('$::keystone::keystone_user') {
    $keystone_user = $::keystone::keystone_user
  } else {
    $keystone_user = $::keystone::params::user
  }

  if $bootstrap {
    $bootstrap_adminurl_env = $admin_url ? {
      ''      => undef,
      default => "OS_BOOTSTRAP_ADMIN_URL=${admin_url}",
    }
    $bootstrap_internalurl_env = $internal_url_real ? {
      ''      => undef,
      default => "OS_BOOTSTRAP_INTERNAL_URL=${internal_url_real}",
    }
    $bootstrap_env = delete_undef_values([
      "OS_BOOTSTRAP_USERNAME=${username}",
      "OS_BOOTSTRAP_PASSWORD=${password}",
      "OS_BOOTSTRAP_PROJECT_NAME=${project_name}",
      "OS_BOOTSTRAP_ROLE_NAME=${role_name}",
      "OS_BOOTSTRAP_SERVICE_NAME=${service_name}",
      "OS_BOOTSTRAP_PUBLIC_URL=${public_url}",
      "OS_BOOTSTRAP_REGION_ID=${region}",
      $bootstrap_adminurl_env,
      $bootstrap_internalurl_env,
    ])

    # The initial bootstrap that creates all resources required but
    # only subscribes to notifies from the keystone::dbsync::end anchor
    # which means this is not guaranteed to execute on each run.
    exec { 'keystone bootstrap':
      command     => 'keystone-manage bootstrap',
      environment => $bootstrap_env,
      user        => $keystone_user,
      path        => '/usr/bin',
      refreshonly => true,
      subscribe   => Anchor['keystone::dbsync::end'],
      notify      => Anchor['keystone::service::begin'],
      tag         => 'keystone-bootstrap',
    }
  }

  if $manage_resources {
    # Since the bootstrap is not guaranteed to execute on each run we
    # use the below resources to make sure the current resources are
    # correct so if some value was updated we set that.

    ensure_resource('keystone_role',
      [$role_name, 'manager', 'member', 'reader', 'service'], {
      'ensure' => 'present',
    })

    ensure_resource('keystone_implied_role',
      [
        "${role_name}@manager",
        'manager@member',
        'member@reader',
      ], {
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

    ensure_resource('keystone_user_role', "${username}@::::all", {
      'ensure' => 'present',
      'roles'  => $role_name,
    })

    ensure_resource('keystone_service', "${service_name}::identity", {
      'ensure'      => 'present',
      'description' => $service_description,
    })

    ensure_resource('keystone_endpoint', "${region}/${service_name}::identity", {
      'ensure'       => 'present',
      'public_url'   => $public_url,
      'admin_url'    => $admin_url,
      'internal_url' => $internal_url_real,
    })
  }

  $auth_url_real = $interface ? {
    'admin'    => $admin_url,
    'internal' => $internal_url_real,
    default    => $public_url
  }
  if $auth_url_real == '' {
    fail("The ${interface} endpoint should not be empty to be used by the interface parameter.")
  }

  ensure_resource('file', '/etc/openstack', {
    'ensure' => 'directory',
    'mode'   => '0755',
    'owner'  => 'root',
    'group'  => 'root',
  })

  ensure_resource('file', '/etc/openstack/puppet', {
    'ensure' => 'directory',
    'mode'   => '0755',
    'owner'  => 'root',
    'group'  => 'root',
  })

  openstacklib::clouds { '/etc/openstack/puppet/admin-clouds.yaml':
    username     => $username,
    password     => $password,
    auth_url     => $auth_url_real,
    project_name => $project_name,
    system_scope => 'all',
    region_name  => $region,
    interface    => $interface,
  }
  Anchor['keystone::config::begin']
    -> Openstacklib::Clouds['/etc/openstack/puppet/admin-clouds.yaml']
    -> Anchor['keystone::config::end']
}
