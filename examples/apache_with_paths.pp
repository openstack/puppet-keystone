# Example using apache to serve keystone
#
# To be sure everything is working, run:
#   $ export OS_USERNAME=admin
#   $ export OS_PASSWORD=ChangeMe
#   $ export OS_TENANT_NAME=openstack
#   $ export OS_AUTH_URL=http://keystone.local/v3
#   $ keystone catalog
#   Service: identity
#   +-------------+----------------------------------------------+
#   |   Property  |                    Value                     |
#   +-------------+----------------------------------------------+
#   |   adminURL  | http://keystone.local:80/v3                  |
#   |      id     |       4f0f55f6789d4c73a53c51f991559b72       |
#   | internalURL | http://keystone.local:80/v3                  |
#   |  publicURL  | http://keystone.local:80/v3                  |
#   |    region   |                  RegionOne                   |
#   +-------------+----------------------------------------------+
#

Exec { logoutput => 'on_failure' }

class { 'mysql::server': }
class { 'keystone::db::mysql':
  password => 'keystone',
}
class { 'keystone::db':
  database_connection => 'mysql://keystone:keystone@127.0.0.1/keystone',
}

class { 'keystone':
  debug          => true,
  catalog_driver => 'sql',
  enabled        => true,
}
class { 'keystone::bootstrap':
  password   => 'ChangeMe',
  public_url => "https://${facts['networking']['fqdn']}:443/v3",
  admin_url  => "https://${facts['networking']['fqdn']}:443/v3",
}

include apache
class { 'keystone::wsgi::apache':
  ssl      => true,
  api_port => 443,
}
