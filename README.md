keystone
=======

#### Table of Contents

1. [Overview - What is the keystone module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with keystone](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors - Those with commits](#contributors)

Overview
--------

The keystone module is a part of [OpenStack](https://github.com/openstack), an effort by the OpenStack infrastructure team to provide continuous integration testing and code review for OpenStack and OpenStack community projects as part of the core software.  The module itself is used to flexibly configure and manage the identity service for OpenStack.

Module Description
------------------

The keystone module is a thorough attempt to make Puppet capable of managing the entirety of keystone.  This includes manifests to provision region specific endpoint and database connections.  Types are shipped as part of the keystone module to assist in manipulation of configuration files.

This module is tested in combination with other modules needed to build and leverage an entire OpenStack software stack.

Setup
-----

**What the keystone module affects**

* [Keystone](http://docs.openstack.org/developer/keystone/), the identity service for OpenStack.

### Installing keystone

    puppet module install openstack/keystone

### Beginning with keystone

To utilize the keystone module's functionality you will need to declare multiple resources. This is not an exhaustive list of all the components needed, we recommend you consult and understand the [core openstack](http://docs.openstack.org) documentation.

**Define a keystone node**

```puppet
class { 'keystone':
  verbose             => True,
  catalog_type        => 'sql',
  admin_token         => 'random_uuid',
  database_connection => 'mysql://keystone_admin:super_secret_db_password@openstack-controller.example.com/keystone',
}

# Adds the admin credential to keystone.
class { 'keystone::roles::admin':
  email        => 'admin@example.com',
  password     => 'super_secret',
}

# Installs the service user endpoint.
class { 'keystone::endpoint':
  public_url   => 'http://10.16.0.101:5000/v2.0',
  admin_url    => 'http://10.16.1.101:35357/v2.0',
  internal_url => 'http://10.16.2.101:5000/v2.0',
  region       => 'example-1',
}

# Remove the admin_token_auth paste pipeline.
# After the first puppet run this requires setting keystone v3
# admin credentials via /root/openrc or as environment variables.
include keystone::disable_admin_token_auth
```

**Leveraging the Native Types**

Keystone ships with a collection of native types that can be used to interact with the data stored in keystone.  The following, related to user management could live throughout your Puppet code base.  They even support puppet's ability to introspect the current environment much the same as `puppet resource user`, `puppet resource keystone_tenant` will print out all the currently stored tenants and their parameters.

```puppet
keystone_tenant { 'openstack':
  ensure  => present,
  enabled => True,
}
keystone_user { 'openstack':
  ensure  => present,
  enabled => True,
}
keystone_role { 'admin':
  ensure => present,
}
keystone_user_role { 'admin@openstack':
  roles => ['admin', 'superawesomedude'],
  ensure => present
}
```

These two will seldom be used outside openstack related classes, like nova or cinder.  These are modified examples from Class['nova::keystone::auth'].

```puppet
# Setup the nova keystone service
keystone_service { 'nova':
  ensure      => present,
  type        => 'compute',
  description => 'OpenStack Compute Service',
}

```

Services can also be written with the type as a suffix:

```puppet
keystone_service { 'nova::type':
  ensure      => present,
  description => 'OpenStack Compute Service',
}


# Setup nova keystone endpoint
keystone_endpoint { 'example-1-west/nova':
   ensure       => present,
   type         => 'compute',
   public_url   => "http://127.0.0.1:8774/v2/%(tenant_id)s",
   admin_url    => "http://127.0.0.1:8774/v2/%(tenant_id)s",
   internal_url => "http://127.0.0.1:8774/v2/%(tenant_id)s",
}
```

Endpoints can also be written with the type as a suffix:

```puppet
keystone_endpoint { 'example-1-west/nova::compute':
   ensure       => present,
   public_url   => "http://127.0.0.1:8774/v2/%(tenant_id)s",
   admin_url    => "http://127.0.0.1:8774/v2/%(tenant_id)s",
   internal_url => "http://127.0.0.1:8774/v2/%(tenant_id)s",
}
```

Defining an endpoint without the type is supported in Liberty release
for backward compatibility, but will be dropped in Mitaka, as this can
lead to corruption of the endpoint database if omitted.  See [this
bug](https://bugs.launchpad.net/puppet-keystone/+bug/1506996)

**Setting up a database for keystone**

A keystone database can be configured separately from the keystone services.

If one needs to actually install a fresh database they have the choice of mysql or postgres.  Use the mysql::server or postgreql::server classes to do this setup, and then the Class['keystone::db::mysql'] or Class['keystone::db::postgresql'] for adding the databases and users that will be needed by keystone.

* For mysql

```puppet
class { 'mysql::server': }

class { 'keystone::db::mysql':
  password      => 'super_secret_db_password',
  allowed_hosts => '%',
}
```

* For postgresql

```puppet
class { 'postgresql::server': }

class { 'keystone::db::postgresql': password => 'super_secret_db_password', }
```

**About Keystone V3 syntax in keystone_user/keystone_tenant/keystone_user_role**

A complete description of the syntax available for those resources are
in `examples/user_project_user_role_composite_namevar.pp`

**About Keystone V3 and default domain**

***For users***

With Keystone V3, domains made their appearance.  For backward
compatibility a default domain is defined in the `keystone.conf` file.
All the V2 resources are then assigned to this default domain.  The
default domain id is by default `default` associated with the name
`Default`.

What it means is that this user:

```puppet
keystone_user { 'my_non_full_qualified_user':
  ensure => present
}
```

will be assigned to the `Default` domain.

The same is true for `keystone_tenant` and `keystone_user_role`:

```puppet
keystone_tenant { 'project_one':
  ensure => present
}

keystone_user_role { 'user_one@project_one':
  ensure => present,
  roles  => ['admin']
}
```

will be assigned to the `Default` domain.

Now, you can change the default domain if you want.  But then the
puppet resource you defined will *have* to be fully qualified.

So, for instance, if you change the default domain to be
`my_new_default`, then you'll have to do:

```puppet
keystone_user { 'full_qualified_user::my_new_default':
  ensure => present
}
keystone_tenant { 'project_one::my_new_default':
  ensure => present
}

keystone_user_role { 'user_one::my_new_default@project_one::my_new_default':
  ensure => present,
  roles  => ['admin']
}
```

as the module will *always* assign a resource without domain to
the `Default` domain.

A deprecation warning will be visible in the log when you have
changed the default domain id and used an non fully qualified name for
your resource.

In Mitaka, a deprecation warning will be displayed any time
you use a non fully qualified resource.

After Mitaka all the resources will have to be fully qualified.

***For developers***

Other modules can try to find user/tenant resources using Puppet's
indirection.  The rule for the name of the resources are:

 1. fully qualified if domain is not 'Default';
 2. short form if domain is 'Default'

This is for backward compatibility.

Note that, as stated above, the 'Default' domain is hardcoded.  It is
not related to the real default domain which can be set to something
else.  But then again, you will have to set the fully qualified name.

You can check `spec/acceptance/default_domain_spec.rb` to see an
example of the behavior described here.

Implementation
--------------

### keystone

keystone is a combination of Puppet manifest and ruby code to delivery configuration and extra functionality through types and providers.

### Types

#### keystone_config

The `keystone_config` provider is a children of the ini_setting provider. It allows one to write an entry in the `/etc/keystone/keystone.conf` file.

```puppet
keystone_config { 'DEFAULT/verbose' :
  value => true,
}
```

This will write `verbose=true` in the `[DEFAULT]` section.

##### name

Section/setting name to manage from `keystone.conf`

##### value

The value of the setting to be defined.

##### secret

Whether to hide the value from Puppet logs. Defaults to `false`.

##### ensure_absent_val

If value is equal to ensure_absent_val then the resource will behave as if `ensure => absent` was specified. Defaults to `<SERVICE DEFAULT>`

Limitations
------------

* All the keystone types use the CLI tools and so need to be run on the keystone node.

### Upgrade warning

* If you've setup OpenStack using previous versions of this module you need to be aware that it used UUID as the default for the token_format parameter but now defaults to PKI.  If you're using this module to manage a Grizzly OpenStack deployment that was set up using a development release of the modules or are attempting an upgrade from Folsom then you'll need to make sure you set the token_format to UUID at classification time.

Beaker-Rspec
------------

This module has beaker-rspec tests

To run:

``shell
bundle install
bundle exec rspec spec/acceptance
``

Development
-----------

Developer documentation for the entire puppet-openstack project.

* https://wiki.openstack.org/wiki/Puppet-openstack#Developer_documentation

Contributors
------------

* https://github.com/openstack/puppet-keystone/graphs/contributors
