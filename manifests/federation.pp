# == class: keystone::federation
#
# == Parameters
#
# [*trusted_dashboards*]
#   (optional) URL list of trusted horizon servers.
#   This setting ensures that keystone only sends token data back to trusted
#   servers. This is performed as a precaution, specifically to prevent man-in-
#   the-middle (MITM) attacks.
#   Defaults to undef
#
# [*remote_id_attribute*]
#   (optional) Value to be used to obtain the entity ID of the Identity
#   Provider from the environment.
#
class keystone::federation (
  $trusted_dashboards  = undef,
  $remote_id_attribute = undef,
) {
  include ::keystone::deps

  keystone_config {
    'federation/trusted_dashboard': value  => any2array($trusted_dashboards);
  }

  if $remote_id_attribute {
    keystone_config {
      'federation/remote_id_attribute': value => $remote_id_attribute;
    }
  }
}
