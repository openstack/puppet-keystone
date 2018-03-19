# == Class keystone::service
#
# Encapsulates the keystone service to a class.
# This allows resources that require keystone to
# require this class, which can optionally
# validate that the service can actually accept
# connections.
#
# === Parameters
#
# [*ensure*]
#   (optional) The desired state of the keystone service
#   Defaults to undef
#
# [*service_name*]
#   (optional) The name of the keystone service
#   Defaults to $::keystone::params::service_name
#
# [*enable*]
#   (optional) Whether to enable the keystone service
#   Defaults to true
#
# [*hasstatus*]
#   (optional) Whether the keystone service has status
#   Defaults to true
#
# [*hasrestart*]
#   (optional) Whether the keystone service has restart
#   Defaults to true
#
# [*validate*]
#   (optional) Whether to validate the service is working after any service refreshes
#   Defaults to false
#
# [*admin_token*]
#   (optional) The admin token to use for validation
#   Defaults to undef
#
# [*admin_endpoint*]
#   (optional) The admin endpont to use for validation
#   Defaults to 'http://localhost:35357/v2.0'
#
# [*retries*]
#   (optional) Number of times to retry validation
#   Defaults to 10
#
# [*delay*]
#   (optional) Number of seconds between validation attempts
#   Defaults to 2
#
# [*insecure*]
#   (optional) Whether to validate keystone connections
#   using the --insecure option with keystone client.
#   Defaults to false
#
# [*cacert*]
#   (optional) Whether to validate keystone connections
#   using the specified argument with the --os-cacert option
#   with keystone client.
#   Defaults to undef
#
class keystone::service(
  $ensure         = undef,
  $service_name   = $::keystone::params::service_name,
  $enable         = true,
  $hasstatus      = true,
  $hasrestart     = true,
  $validate       = false,
  $admin_token    = undef,
  $admin_endpoint = 'http://localhost:35357/v2.0',
  $retries        = 10,
  $delay          = 2,
  $insecure       = false,
  $cacert         = undef,
) {

  include ::keystone::deps
  include ::keystone::params

  if ($service_name == 'keystone-public-keystone-admin'){
    service { 'keystone-public':
      ensure     => $ensure,
      name       => 'keystone-public',
      enable     => $enable,
      hasstatus  => $hasstatus,
      hasrestart => $hasrestart,
      tag        => 'keystone-service',
    }
    service { 'keystone-admin':
      ensure     => $ensure,
      name       => 'keystone-admin',
      enable     => $enable,
      hasstatus  => $hasstatus,
      hasrestart => $hasrestart,
      tag        => 'keystone-service',
    }
  } else {
    service { 'keystone':
      ensure     => $ensure,
      name       => $service_name,
      enable     => $enable,
      hasstatus  => $hasstatus,
      hasrestart => $hasrestart,
      tag        => 'keystone-service',
    }
  }

  if $insecure {
    $insecure_s = '--insecure'
  } else {
    $insecure_s = ''
  }

  if $cacert {
    $cacert_s = "--os-cacert ${cacert}"
  } else {
    $cacert_s = ''
  }

  if $validate and $admin_token and $admin_endpoint {
    $cmd = "openstack --os-auth-url ${admin_endpoint} --os-token ${admin_token} ${insecure_s} ${cacert_s} user list"
    $catch = 'name'
    exec { 'validate_keystone_connection':
      path        => '/usr/bin:/bin:/usr/sbin:/sbin',
      provider    => shell,
      command     => $cmd,
      subscribe   => Service['keystone'],
      refreshonly => true,
      tries       => $retries,
      try_sleep   => $delay,
      notify      => Anchor['keystone::service::end'],
    }
  }
}
