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
#   (Optional) The desired state of the keystone service
#   Defaults to undef
#
# [*service_name*]
#   (Optional) The name of the keystone service
#   Defaults to $::keystone::params::service_name
#
# [*enable*]
#   (Optional) Whether to enable the keystone service
#   Defaults to true
#
# [*hasstatus*]
#   (Optional) Whether the keystone service has status
#   Defaults to true
#
# [*hasrestart*]
#   (Optional) Whether the keystone service has restart
#   Defaults to true
#
## DEPRECATED PARAMS
#
# [*validate*]
#   (optional) Whether to validate the service is working after any service refreshes
#   Defaults to undef
#
# [*admin_token*]
#   (optional) The admin token to use for validation
#   Defaults to undef
#
# [*admin_endpoint*]
#   (optional) The admin endpont to use for validation
#   Defaults to undef
#
# [*retries*]
#   (optional) Number of times to retry validation
#   Defaults to undef
#
# [*delay*]
#   (optional) Number of seconds between validation attempts
#   Defaults to undef
#
# [*insecure*]
#   (optional) Whether to validate keystone connections
#   using the --insecure option with keystone client.
#   Defaults to undef
#
# [*cacert*]
#   (optional) Whether to validate keystone connections
#   using the specified argument with the --os-cacert option
#   with keystone client.
#   Defaults to undef
#
class keystone::service (
  $ensure         = undef,
  $service_name   = $::keystone::params::service_name,
  $enable         = true,
  $hasstatus      = true,
  $hasrestart     = true,
  ## DEPRECATED PARAMS
  $validate       = undef,
  $admin_token    = undef,
  $admin_endpoint = undef,
  $retries        = undef,
  $delay          = undef,
  $insecure       = undef,
  $cacert         = undef,
) inherits keystone::params {

  include ::keystone::deps

  if $service_name == 'keystone-public-keystone-admin' {
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
}
