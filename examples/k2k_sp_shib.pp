# Example to configure Keystone as Service Provider for
# K2K Federation.
#
# To be sure everything is working, run:
#   $ export OS_USERNAME=admin
#   $ export OS_PASSWORD=ChangeMe
#   $ export OS_TENANT_NAME=openstack
#   $ export OS_AUTH_URL=http://keystone.local/keystone/main/v2.0
#   $ keystone catalog
#   Service: identity
#   +-------------+----------------------------------------------+
#   |   Property  |                    Value                     |
#   +-------------+----------------------------------------------+
#   |   adminURL  | http://keystone.local:80/keystone/admin/v2.0 |
#   |      id     |       4f0f55f6789d4c73a53c51f991559b72       |
#   | internalURL | http://keystone.local:80/keystone/main/v2.0  |
#   |  publicURL  | http://keystone.local:80/keystone/main/v2.0  |
#   |    region   |                  RegionOne                   |
#   +-------------+----------------------------------------------+
#

Exec { logoutput => 'on_failure' }

# Note: The yumrepo part is only necessary if you are using RedHat.
# Yumrepo begin
yumrepo { 'shibboleth':
  name     => 'Shibboleth',
  baseurl  => 'http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/',
  descr    => 'Shibboleth repo for RedHat',
  gpgcheck => 1,
  gpgkey   => 'http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/repodata/repomd.xml.key',
  enabled  => 1,
  require  => Anchor['openstack_extras_redhat']
}

Yumrepo['shibboleth'] -> Class['::keystone::federation::shibboleth']
# Yumrepo end

class { '::mysql::server': }
class { '::keystone::db::mysql':
  password => 'keystone',
}

class { '::keystone':
  verbose             => true,
  debug               => true,
  database_connection => 'mysql://keystone:keystone@127.0.0.1/keystone',
  catalog_type        => 'sql',
  admin_token         => 'admin_token',
  enabled             => false,
}

class { '::keystone::roles::admin':
  email    => 'test@puppetlabs.com',
  password => 'ChangeMe',
}

class { '::keystone::endpoint':
  public_url => "https://${::fqdn}:5000/",
  admin_url  => "https://${::fqdn}:35357/",
}

keystone_config { 'ssl/enable': value => true }

include ::apache
class { '::keystone::wsgi::apache':
  ssl => true
}

class { '::keystone::federation::shibboleth':
  methods => 'password, token, oauth1, saml2',
}
