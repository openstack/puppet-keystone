#
# This class contains the platform differences for keystone
#
class keystone::params {
  include ::openstacklib::defaults
  if ($::os_package_type == 'debian') {
    $pyvers = '3'
  } else {
    $pyvers = ''
  }
  $client_package_name = "python${pyvers}-keystoneclient"
  $keystone_user       = 'keystone'
  $keystone_group      = 'keystone'
  $keystone_wsgi_admin_script_path  = '/usr/bin/keystone-wsgi-admin'
  $keystone_wsgi_public_script_path = '/usr/bin/keystone-wsgi-public'
  $group                            = 'keystone'
  case $::osfamily {
    'Debian': {
      $package_name                 = 'keystone'
      $service_name                 = 'keystone'
      $keystone_wsgi_script_path    = '/usr/lib/cgi-bin/keystone'
      $python_memcache_package_name = "python${pyvers}-memcache"
      $mellon_package_name          = 'libapache2-mod-auth-mellon'
      $openidc_package_name         = 'libapache2-mod-auth-openidc'
    }
    'RedHat': {
      $package_name                 = 'openstack-keystone'
      $service_name                 = 'openstack-keystone'
      $keystone_wsgi_script_path    = '/var/www/cgi-bin/keystone'
      $python_memcache_package_name = 'python-memcached'
      $mellon_package_name          = 'mod_auth_mellon'
      $openidc_package_name         = 'mod_auth_openidc'
    }
    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }
  }
}
