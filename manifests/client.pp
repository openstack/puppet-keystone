# == Class: keystone::client
#
# Installs Keystone client.
#
# === Parameters
#
# [*ensure*]
#   (optional) Ensure state of the package.
#   Defaults to 'present'.
#
class keystone::client (
  $ensure = 'present'
) {

  package { 'python-keystoneclient':
    ensure => $ensure,
    tag    => 'openstack',
  }

  if $ensure == 'present' {
    include '::openstacklib::openstackclient'
  } else {
    class { '::openstacklib::openstackclient':
      package_ensure => $ensure,
    }
  }
}
