# == Class: keystone::bootstrap
#
# Bootstrap keystone with keystone-manage bootstrap.
#
# === Parameters
#
# [*password*]
#   (Optional) The password for the user.
#   WARNING: This parameter will be required in a future release.
#   Defaults to undef
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
  # TODO(tobias-urdin): Make the password required when compat is removed.
  $password             = undef,
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

  # TODO(tobias-urdin): Remove compat layer.
  if $password == undef {
    if defined('$::keystone::admin_password') and $::keystone::admin_password != undef {
      $password_real = $::keystone::admin_password
      warning('Using deprecated keystone::admin_password as admin password')
      # Check if we differ from the roles admin pw
      if defined('$::keystone::roles::admin::password') and $::keystone::roles::admin::password != $password_real {
        warning('The keystone::admin_password and keystone::roles::admin::password differs and will cause a flip-flopping\
          behaviour and authentication issues for the admin user.')
      }
    } elsif defined('$::keystone::admin_token') and $::keystone::admin_token != undef {
      $password_real = $::keystone::admin_token
      warning('Using deprecated keystone::admin_token as admin password')
      # Check if we differ from the roles admin pw
      if defined('$::keystone::roles::admin::password') and $::keystone::roles::admin::password != $password_real {
        warning('The keystone::admin_token and keystone::roles::admin::password differs and will cause a flip-flopping\
          behaviour and authentication issues for the admin user.')
      }
    } else {
      # Check the keystone::roles::admin class as well.
      if defined('$::keystone::roles::admin::password') and $::keystone::roles::admin::password != undef {
        $password_real = $::keystone::roles::admin::password
        warning('Using deprecated keystone::roles::admin::password as admin password')
      } else {
        fail('keystone::bootstrap::password is undef, could not resolve a password')
      }
    }
  } else {
    $password_real = $password
  }
  if defined('$::keystone::endpoint::public_url') and $::keystone::endpoint::public_url != undef {
    $public_url_real = $::keystone::endpoint::public_url
    $using_deprecated_public_url = true
    warning('Using deprecated keystone::endpoint::public_url, please update to using keystone::bootstrap')
  } else {
    $public_url_real = $public_url
    $using_deprecated_public_url = false
  }
  if defined('$::keystone::endpoint::internal_url') and $::keystone::endpoint::internal_url != undef {
    $internal_url_final = $::keystone::endpoint::internal_url
    $using_deprecated_internal_url = true
    warning('Using deprecated keystone::endpoint::internal_url, please update to using keystone::bootstrap')
  } else {
    $internal_url_final = $internal_url
    $using_deprecated_internal_url = false
  }
  if defined('$::keystone::endpoint::admin_url') and $::keystone::endpoint::admin_url != undef {
    $admin_url_real = $::keystone::endpoint::admin_url
    warning('Using deprecated keystone::endpoint::admin_url, please update to using keystone::bootstrap')
  } else {
    $admin_url_real = $admin_url
  }
  if defined('$::keystone::endpoint::region') and $::keystone::endpoint::region != undef {
    $region_real = $::keystone::endpoint::region
    warning('Using deprecated keystone::endpoint::region, please update to using keystone::bootstrap')
  } else {
    $region_real = $region
  }
  if !$using_deprecated_internal_url and $internal_url == undef and $using_deprecated_public_url {
    warning('Using deprecated keystone::endpoint::public_url for keystone::bootstrap::internal_url')
  }
  if defined('$::keystone::roles::admin::admin') and $::keystone::roles::admin::admin != undef {
    $username_real = $::keystone::roles::admin::admin
    if $username_real != $username and $username == 'admin' {
      warning('Using keystone::roles::admin::admin as username, the keystone::bootstrap::username default is different\
        dont forget to set that later')
    }
  } else {
    $username_real = $username
  }
  if defined('$::keystone::roles::admin::email') and $::keystone::roles::admin::email != undef {
    $email_real = $::keystone::roles::admin::email
    if $email_real != $email and $email == 'admin@localhost' {
      warning('Using keystone::roles::admin::email as email, the keystone::bootstrap::email default is different\
        dont forget to set that later')
    }
  } else {
    $email_real = $email
  }
  if defined('$::keystone::roles::admin::admin_roles') and $::keystone::roles::admin::admin_roles != undef {
    $role_name_real = $::keystone::roles::admin::admin_roles
    warning("Using keystone::roles::admin::admin_roles with value ${role_name_real} note that the\
      keystone::bootstrap when used will only set a single role, by default the 'admin' role.")
    warning('Will use the first value in admin_roles for bootstrap and all (if multiple) for all other resources!')
    if is_array($role_name_real) {
      $bootstrap_role_name = $role_name_real[0]
    } else {
      $bootstrap_role_name = $role_name_real
    }
  } else {
    $role_name_real = [$role_name]
    $bootstrap_role_name = $role_name
  }
  if defined('$::keystone::roles::admin::admin_tenant') {
    $admin_tenant = $::keystone::roles::admin::admin_tenant
    if ($admin_tenant == undef or $admin_tenant == 'openstack') {
      # Try to keep the backward compatible creation of the openstack project.
      # We still create the 'admin' project with the bootstrap process below.
      # This is a best effort, we still ignore the description and default domain.
      ensure_resource('keystone_tenant', 'openstack', {
        'ensure'  => 'present',
        'enabled' => true,
      })
      ensure_resource('keystone_user_role', "${username_real}@openstack", {
        'ensure' => 'present',
        'roles'  => $role_name_real,
      })

      # Use the default value so we create the "admin" project
      $project_name_real = $project_name
    } else {
      warning('Using keystone::roles::admin::admin_tenant as project name for admin')
      $project_name_real = $admin_tenant
    }
  } else {
    $project_name_real = $project_name
  }
  if defined('$::keystone::roles::admin::service_tenant') and $::keystone::roles::admin::service_tenant != undef {
    warning('Using keystone::roles::admin::service_tenant as service project name')
    $service_project_name_real = $::keystone::roles::admin::service_tenant
  } else {
    $service_project_name_real = $service_project_name
  }
  # Compat code ends here.

  $internal_url_real = $internal_url_final ? {
    undef   => $public_url_real,
    default => $internal_url_final
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
      "OS_BOOTSTRAP_USERNAME=${username_real}",
      "OS_BOOTSTRAP_PASSWORD=${password_real}",
      "OS_BOOTSTRAP_PROJECT_NAME=${project_name_real}",
      "OS_BOOTSTRAP_ROLE_NAME=${bootstrap_role_name}",
      "OS_BOOTSTRAP_SERVICE_NAME=${service_name}",
      "OS_BOOTSTRAP_ADMIN_URL=${admin_url_real}",
      "OS_BOOTSTRAP_PUBLIC_URL=${public_url_real}",
      "OS_BOOTSTRAP_INTERNAL_URL=${internal_url_real}",
      "OS_BOOTSTRAP_REGION_ID=${region_real}",
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

  ensure_resource('keystone_role', $role_name_real, {
    'ensure' => 'present',
  })

  ensure_resource('keystone_user', $username_real, {
    'ensure'   => 'present',
    'enabled'  => true,
    'email'    => $email_real,
    'password' => $password_real,
  })

  ensure_resource('keystone_tenant', $service_project_name_real, {
    'ensure'  => 'present',
    'enabled' => true,
  })

  ensure_resource('keystone_tenant', $project_name_real, {
    'ensure'  => 'present',
    'enabled' => true,
  })

  ensure_resource('keystone_user_role', "${username_real}@${project_name_real}", {
    'ensure' => 'present',
    'roles'  => $role_name_real,
  })

  ensure_resource('keystone_service', "${service_name}::identity", {
    'ensure' => 'present',
  })

  ensure_resource('keystone_endpoint', "${region_real}/${service_name}::identity", {
    'ensure'       => 'present',
    'public_url'   => $public_url_real,
    'admin_url'    => $admin_url_real,
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
    $auth_url_real = $admin_url_real
  } elsif $interface == 'internal' {
    $auth_url_real = $internal_url_real
  } else {
    $auth_url_real = $public_url_real
  }

  keystone::resource::authtoken { 'keystone_puppet_config':
    username     => $username_real,
    password     => $password_real,
    auth_url     => $auth_url_real,
    project_name => $project_name_real,
    region_name  => $region_real,
    interface    => $interface,
  }
}
