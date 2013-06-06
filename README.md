# Overview #

This module can be used to flexibly configure [keystone](http://keystone.openstack.org/),
the Identity Service of Openstack.

It has been tested with a combination of other modules, and has primarily been
developed as a subcomponent of the [openstack module](https://github.com/stackforge/puppet-openstack)

This modules contains both classes as well as native types that install and configure keystone.

This version of the module is targetted at Folsom and Grizzly.

# Tested use cases #

This module has mainly been tested against Ubuntu Precise and RHEL 6.

It has only currently been tested as a single node installation of keystone.


# Dependencies: #

This module has relatively few dependencies:

  # if using mysql as a backend
  https://github.com/puppetlabs/puppetlabs-mysql

# Usage #

## class keystone ##

The keystone class sets up the basic configuration for the keystone service.

for example:

    class { 'keystone':
      admin_token => 'my_secret_token'
      verbose     => 'True',
    }

## setting up a keystone mysql db ##

  A keystone mysql database can be configured separately from
  the service.

  If you need to actually install a mysql database server, you can use
  the mysql::server class from the puppetlabs mysql module

    # check out the mysql module's README to learn more about
    # how to more appropriately configure a server
    # http://forge.puppetlabs.com/puppetlabs/mysql
    class { 'mysql::server': }

    class { 'keystone::db::mysql':
      dbname   => 'keystone',
      user     => 'keystone',
      password => 'keystone_password',
    }

## setting up a keystone postgresql db ##

  A keystone postgresql database can be configured separately from
  the service instead of mysql.

  Use puppetlab's postgresql module to install postgresql.
  http://forge.puppetlabs.com/puppetlabs/postgresql

    class { 'postgresql::server': }

    class { 'keystone::db::postgresql':
        dbname   => 'keystone',
        user     => 'keystone',
        password => 'keystone_password',
    }

## Install keystone role ##

  The following class adds admin credentials to keystone.

    class { 'keystone::roles::admin':
      email        => 'you@your_domain.com',
      password     => 'password',
      admin_tenant => 'admin_tenant',
    }

## Install service user and endpoint ##

  The following class installs the keystone service user and endpoints.

    class { 'keystone::endpoint':
      public_address   => '212.234.21.4',
      admin_address    => '10.0.0.4',
      internal_address => '11.0.1.4',
      region           => 'RegionTwo',
    }

## Examples

Examples can be located in the examples directory of this modules. The node keystone_mysql is the most common deployment style.

The keystone deployment description that I use for testing can be found here:

https://github.com/puppetlabs/puppetlabs-openstack_dev_env/tree/master/manifests

## Native Types ##

  The Puppet support for keystone also includes native types that can be
  used to manage the following keystone objects:

    - keystone_tenant
    - keystone_user
    - keystone_role
    - keystone_user_role
    - keystone_service
    - keystone_endpoint

  These types will only work on the keystone server (and they read keystone.conf
  to figure out the admin port and admin token, which is kind of hacky, but the best
  way I could think of.)

    - keystone_config - manages individual config file entries as resources.

### examples ###

    keystone_tenant { 'openstack':
      ensure  => present,
      enabled => 'True',
    }
    keystone_user { 'openstack':
      ensure  => present,
      enabled => 'True'
    }
    keystone_role { 'admin':
      ensure => present,
    }
    keystone_user_role { 'admin@openstack':
      roles => ['admin', 'superawesomedude'],
      ensure => present
    }

  The keystone_config native type allows you to arbitrarily modify any config line
  from any scope in Puppet.

    keystone_config { 'ssl/enable':
      value => 'True',
    }

### puppet resource ###

These native types also allow for some interesting introspection using puppet resource

To list all of the objects of a certain type in the keystone database, you can run:

  puppet resource <type>

For example, the following command lists all keystone tenants when run on the keystone server:

    puppet resource keystone_tenant

