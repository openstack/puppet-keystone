#
# This class contains the platform differences for keystone
#
class keystone::params {
  include ::openstacklib::defaults
  $pyvers = $::openstacklib::defaults::pyvers

  $client_package_name = "python${pyvers}-keystoneclient"
  $keystone_user       = 'keystone'
  $keystone_group      = 'keystone'
  $group               = 'keystone'

  case $::osfamily {
    'Debian': {
      $package_name                 = 'keystone'
      $service_name                 = 'keystone'
      $keystone_wsgi_script_path    = '/usr/lib/cgi-bin/keystone'
      $python_memcache_package_name = "python${pyvers}-memcache"
      $python_ldappool_package_name = "python${pyvers}-ldappool"
      $python_pysaml2_package_name  = "python${pyvers}-pysaml2"
      $mellon_package_name          = 'libapache2-mod-auth-mellon'
      $openidc_package_name         = 'libapache2-mod-auth-openidc'
    }
    'RedHat': {
      $package_name                 = 'openstack-keystone'
      $service_name                 = 'openstack-keystone'
      $keystone_wsgi_script_path    = '/var/www/cgi-bin/keystone'
      $python_memcache_package_name = "python${pyvers}-memcached"
      $python_ldappool_package_name = "python${pyvers}-ldappool"
      $python_pysaml2_package_name  = "python${pyvers}-pysaml2"
      $mellon_package_name          = 'mod_auth_mellon'
      $openidc_package_name         = 'mod_auth_openidc'
    }
    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }
  }
}
