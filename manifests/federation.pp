# == Class: keystone::federation
#
# == Parameters
#
# [*trusted_dashboards*]
#   (Optional) URL list of trusted horizon servers.
#   This setting ensures that keystone only sends token data back to trusted
#   servers. This is performed as a precaution, specifically to prevent man-in-
#   the-middle (MITM) attacks.
#   Defaults to $facts['os_service_default']
#
# [*remote_id_attribute*]
#   (Optional) Value to be used to obtain the entity ID of the Identity
#   Provider from the environment.
#   Defaults to $facts['os_service_default']
#
class keystone::federation (
  $trusted_dashboards  = $facts['os_service_default'],
  $remote_id_attribute = $facts['os_service_default'],
) {

  include keystone::deps

  keystone_config {
    'federation/trusted_dashboard':   value => $trusted_dashboards;
    'federation/remote_id_attribute': value => $remote_id_attribute;
  }
}
