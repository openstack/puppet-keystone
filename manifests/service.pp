# == Class keystone::service
#
# Encapsulates the keystone service to a class.
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
class keystone::service (
  $ensure       = undef,
  $service_name = $::keystone::params::service_name,
  $enable       = true,
  $hasstatus    = true,
  $hasrestart   = true,
) inherits keystone::params {

  include keystone::deps

  service { 'keystone':
    ensure     => $ensure,
    name       => $service_name,
    enable     => $enable,
    hasstatus  => $hasstatus,
    hasrestart => $hasrestart,
    tag        => 'keystone-service',
  }
}
