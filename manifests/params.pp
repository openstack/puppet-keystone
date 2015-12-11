#
# This class contains the platform differences for keystone
#
class keystone::params {
  $client_package_name = 'python-keystone'

  case $::osfamily {
    'Debian': {
      $package_name                 = 'keystone'
      $service_name                 = 'keystone'
      $keystone_wsgi_script_path    = '/usr/lib/cgi-bin/keystone'
      $keystone_wsgi_script_source  = '/usr/share/keystone/wsgi.py'
      $python_memcache_package_name = 'python-memcache'
      $sqlite_package_name          = 'python-pysqlite2'
      $paste_config                 = undef
      $pymysql_package_name         = 'python-pymysql'
      $mellon_package_name          = 'libapache2-mod-auth-mellon'
      case $::operatingsystem {
        'Debian': {
          $service_provider            = undef
        }
        default: {
          $service_provider            = 'upstart'
        }
      }
    }
    'RedHat': {
      $package_name                 = 'openstack-keystone'
      $service_name                 = 'openstack-keystone'
      $keystone_wsgi_script_path    = '/var/www/cgi-bin/keystone'
      $python_memcache_package_name = 'python-memcached'
      $sqlite_package_name          = undef
      $service_provider             = undef
      $keystone_wsgi_script_source  = '/usr/share/keystone/keystone.wsgi'
      $paste_config                 = '/usr/share/keystone/keystone-dist-paste.ini'
      $pymysql_package_name         = undef
      $mellon_package_name          = 'mod_auth_mellon'
    }
  }
}
