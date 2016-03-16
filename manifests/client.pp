# == Class: keystone::client
#
# Installs Keystone client.
#
# === Parameters
#
# [*client_package_name*]
#   (optional) The name of python keystone client package
#   Defaults to $keystone::params::client_package_name
#
# [*ensure*]
#   (optional) Ensure state of the package.
#   Defaults to 'present'.
#
class keystone::client (
  $client_package_name = $keystone::params::client_package_name,
  $ensure = 'present'
) inherits keystone::params {

  include ::keystone::deps

  package { 'python-keystoneclient':
    ensure => $ensure,
    name   => $client_package_name,
    tag    => 'openstack',
  }

  include '::openstacklib::openstackclient'
}
