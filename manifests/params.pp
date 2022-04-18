#
# This class contains the platform differences for keystone
#
class keystone::params {
  include openstacklib::defaults

  $client_package_name = 'python3-keystoneclient'
  $user                = 'keystone'
  $group               = 'keystone'

  # NOTE(tkajinam) These are kept for backword compatibility
  $keystone_user       = $user
  $keystone_group      = $group

  case $::osfamily {
    'Debian': {
      $package_name                 = 'keystone'
      $service_name                 = 'keystone'
      $keystone_wsgi_script_path    = '/usr/lib/cgi-bin/keystone'
      $python_memcache_package_name = 'python3-memcache'
      $python_ldappool_package_name = 'python3-ldappool'
      $python_pysaml2_package_name  = 'python3-pysaml2'
      $mellon_package_name          = 'libapache2-mod-auth-mellon'
      $openidc_package_name         = 'libapache2-mod-auth-openidc'
    }
    'RedHat': {
      $package_name                 = 'openstack-keystone'
      $service_name                 = 'openstack-keystone'
      $keystone_wsgi_script_path    = '/var/www/cgi-bin/keystone'
      $python_memcache_package_name = 'python3-memcached'
      $python_ldappool_package_name = 'python3-ldappool'
      $python_pysaml2_package_name  = 'python3-pysaml2'
      $mellon_package_name          = 'mod_auth_mellon'
      $openidc_package_name         = 'mod_auth_openidc'
    }
    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }
  }
}
