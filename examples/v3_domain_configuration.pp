# Example using v3 domain configuration.  This setup a directory where
# the domain configurations will be and adjust the keystone.
# For the rest of the configuration check v3_basic.pp.
#

Exec { logoutput => 'on_failure' }

class { '::mysql::server': }
class { '::keystone::db::mysql':
  password => 'keystone',
}
class { '::keystone':
  verbose             => true,
  debug               => true,
  database_connection => 'mysql://keystone:keystone@192.168.1.1/keystone',
  admin_token         => 'admin_token',
  enabled             => true,
  # The domain configuration setup at keystone level
  using_domain_config => true,
}
class { '::keystone::roles::admin':
  email    => 'test@example.tld',
  password => 'a_big_secret',
}
class { '::keystone::endpoint':
  public_url => 'http://192.168.1.1:5000/',
  admin_url  => 'http://192.168.1.1:35357/',
}

# Creates the /etc/keystone/domains/keystone.my_domain.conf file and
# notifies keystone service
keystone_domain_config {
  'my_domain::ldap/url':                 value => 'ldap://ldapservice.my_org.com';
  'my_domain::ldap/user':                value => 'cn=Manager,dc=openstack,dc=org';
  'my_domain::ldap/password':            value => 'mysecret';
  'my_domain::ldap/suffix':              value => 'dc=openstack,dc=org';
  'my_domain::ldap/group_tree_dn':       value => 'ou=UserGroups,dc=openstack,dc=org';
  'my_domain::ldap/user_tree_dn':        value => 'ou=Users,dc=openstack,dc=org';
  'my_domain::ldap/user_mail_attribute': value => 'mail';
}
