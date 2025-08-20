#
# This class contains the platform differences for keystone
#
class keystone::params {
  include openstacklib::defaults

  $pyver3 = $openstacklib::defaults::pyver3

  $client_package_name = 'python3-keystoneclient'
  $user                = 'keystone'
  $group               = 'keystone'

  # NOTE(tkajinam) These are kept for backward compatibility
  $keystone_user       = $user
  $keystone_group      = $group

  case $facts['os']['family'] {
    'Debian': {
      $package_name                 = 'keystone'
      $service_name                 = 'keystone'
      $keystone_wsgi_script_path    = '/usr/lib/cgi-bin/keystone'
      $keystone_wsgi_script_source  = '/usr/bin/keystone-wsgi-public'
      $python_memcache_package_name = 'python3-memcache'
      $python_ldappool_package_name = 'python3-ldappool'
    }
    'RedHat': {
      $package_name                 = 'openstack-keystone'
      $service_name                 = 'openstack-keystone'
      $keystone_wsgi_script_path    = '/var/www/cgi-bin/keystone'
      $keystone_wsgi_script_source  = "/usr/lib/python${pyver3}/site-packages/keystone/wsgi/api.py"
      $python_memcache_package_name = 'python3-memcached'
      $python_ldappool_package_name = 'python3-ldappool'
    }
    default: {
      fail("Unsupported osfamily: ${facts['os']['family']}")
    }
  }
}
