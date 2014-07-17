#
# Module for managing keystone config.
#
# == Parameters
#
#   [package_ensure] Desired ensure state of packages. Optional. Defaults to present.
#     accepts latest or specific versions.
#   [bind_host] Host that keystone binds to.
#   [bind_port] Port that keystone binds to.
#   [public_port]
#   [compute_port]
#   [admin_port]
#   [admin_port] Port that can be used for admin tasks.
#   [admin_token] Admin token that can be used to authenticate as a keystone
#     admin. Required.
#   [verbose] Rather keystone should log at verbose level. Optional.
#     Defaults to False.
#   [debug] Rather keystone should log at debug level. Optional.
#     Defaults to False.
#   [use_syslog] Use syslog for logging. Optional.
#     Defaults to False.
#   [log_facility] Syslog facility to receive log lines. Optional.
#   [catalog_type] Type of catalog that keystone uses to store endpoints,services. Optional.
#     Defaults to sql. (Also accepts template)
#   [catalog_driver] Catalog driver used by Keystone to store endpoints and services. Optional.
#     Setting this value will override and ignore catalog_type.
#   [catalog_template_file] Path to the catalog used if catalog_type equals 'template'.
#     Defaults to '/etc/keystone/default_catalog.templates'
#   [token_provider] Format keystone uses for tokens. Optional.
#     Defaults to 'keystone.token.providers.pki.Provider'
#     Supports PKI and UUID.
#   [token_driver] Driver to use for managing tokens.
#     Optional.  Defaults to 'keystone.token.backends.sql.Token'
#   [token_expiration] Amount of time a token should remain valid (seconds).
#     Optional.  Defaults to 3600 (1 hour).
#   [token_format] Deprecated: Use token_provider instead.
#   [cache_dir] Directory created when token_provider is pki. Optional.
#     Defaults to /var/cache/keystone.
#   [memcache_servers] List of memcache servers/ports. Optional. Used with
#     token_driver keystone.token.backends.memcache.Token.  Defaults to false.
#   [enabled] If the keystone services should be enabled. Optional. Default to true.
#
#   [*database_connection*]
#     (optional) Url used to connect to database.
#     Defaults to sqlite:////var/lib/keystone/keystone.db
#
#   [*sql_connection*]
#     (optional) Deprecated. Use database_connection instead.
#
#   [*database_idle_timeout*]
#     (optional) Timeout when db connections should be reaped.
#     Defaults to 200.
#
#   [*idle_timeout*]
#     (optional) Deprecated. Use database_idle_timeout instead.
#
#   [enable_pki_setup] Enable call to pki_setup.
#   [rabbit_host] Location of rabbitmq installation. Optional. Defaults to localhost.
#   [rabbit_port] Port for rabbitmq instance. Optional. Defaults to 5672.
#   [rabbit_hosts] Location of rabbitmq installation. Optional. Defaults to undef.
#   [rabbit_password] Password used to connect to rabbitmq. Optional. Defaults to guest.
#   [rabbit_userid] User used to connect to rabbitmq. Optional. Defaults to guest.
#   [rabbit_virtual_host] The RabbitMQ virtual host. Optional. Defaults to /.
#   [notification_driver] RPC driver. Not enabled by default
#   [notification_topics] AMQP topics to publish to when using the RPC notification driver.
#   [control_exchange] AMQP exchange to connect to if using RabbitMQ or Qpid
#
#   [*public_bind_host*]
#   (optional) The IP address of the public network interface to listen on
#   Deprecates bind_host
#   Default to '0.0.0.0'.
#
#   [*admin_bind_host*]
#   (optional) The IP address of the public network interface to listen on
#   Deprecates bind_host
#   Default to '0.0.0.0'.
#
#   [*log_dir*]
#   (optional) Directory where logs should be stored
#   If set to boolean false, it will not log to any directory
#   Defaults to '/var/log/keystone'
#
# [*log_file*]
#   (optional) Where to log
#   Defaults to false
#
#   [*public_endpoint*]
#   (optional) The base public endpoint URL for keystone that are
#   advertised to clients (NOTE: this does NOT affect how
#   keystone listens for connections) (string value)
#   If set to false, no public_endpoint will be defined in keystone.conf.
#   Sample value: 'http://localhost:5000/v2.0/'
#   Defaults to false
#
#   [*admin_endpoint*]
#   (optional) The base admin endpoint URL for keystone that are
#   advertised to clients (NOTE: this does NOT affect how keystone listens
#   for connections) (string value)
#   If set to false, no admin_endpoint will be defined in keystone.conf.
#   Sample value: 'http://localhost:35357/v2.0/'
#   Defaults to false
#
#   [*enable_ssl*]
#   (optional) Toggle for SSL support on the keystone eventlet servers.
#   (boolean value)
#   Defaults to false
#
#   [*ssl_certfile*]
#   (optional) Path of the certfile for SSL. (string value)
#   Defaults to '/etc/keystone/ssl/certs/keystone.pem'
#
#   [*ssl_keyfile*]
#   (optional) Path of the keyfile for SSL. (string value)
#   Defaults to '/etc/keystone/ssl/private/keystonekey.pem'
#
#   [*ssl_ca_certs*]
#   (optional) Path of the ca cert file for SSL. (string value)
#   Defaults to '/etc/keystone/ssl/certs/ca.pem'
#
#   [*ssl_ca_key*]
#   (optional) Path of the CA key file for SSL (string value)
#   Defaults to '/etc/keystone/ssl/private/cakey.pem'
#
#   [*ssl_cert_subject*]
#   (optional) SSL Certificate Subject (auto generated certificate)
#   (string value)
#   Defaults to '/C=US/ST=Unset/L=Unset/O=Unset/CN=localhost'
#
#   [*mysql_module*]
#   (optional) The mysql puppet module version to use
#   Tested versions include 0.9 and 2.2
#   Default to '0.9'
#
#   [*service_name*]
#   (optional) Name of the service that will be providing the
#   server functionality of keystone.  For example, the default
#   is just 'keystone', which means keystone will be run as a
#   standalone eventlet service, and will able to be managed
#   separately by the operating system's service manager.  For
#   example, you will be able to use
#   service openstack-keystone restart
#   to restart the service.
#   If the value is 'httpd', this means keystone will be a web
#   service, and you must use another class to configure that
#   web service.  For example, after calling class {'keystone'...}
#   use class { 'keystone::wsgi::apache'...} to make keystone be
#   a web app using apache mod_wsgi.
#   Defaults to 'keystone'
#
# == Dependencies
#  None
#
# == Examples
#
#   class { 'keystone':
#     log_verbose => 'True',
#     admin_token => 'my_special_token',
#   }
#
#   OR
#
#   class { 'keystone':
#      ...
#      service_name => 'httpd',
#      ...
#   }
#   class { 'keystone::wsgi::apache':
#      ...
#   }
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2012 Puppetlabs Inc, unless otherwise noted.
#
class keystone(
  $admin_token,
  $package_ensure        = 'present',
  $bind_host             = false,
  $public_bind_host      = '0.0.0.0',
  $admin_bind_host       = '0.0.0.0',
  $public_port           = '5000',
  $admin_port            = '35357',
  $compute_port          = '8774',
  $verbose               = false,
  $debug                 = false,
  $log_dir               = '/var/log/keystone',
  $log_file              = false,
  $use_syslog            = false,
  $log_facility          = 'LOG_USER',
  $catalog_type          = 'sql',
  $catalog_driver        = false,
  $catalog_template_file = '/etc/keystone/default_catalog.templates',
  $token_format          = false,
  $token_provider        = 'keystone.token.providers.pki.Provider',
  $token_driver          = 'keystone.token.backends.sql.Token',
  $token_expiration      = 3600,
  $public_endpoint       = false,
  $admin_endpoint        = false,
  $enable_ssl            = false,
  $ssl_certfile          = '/etc/keystone/ssl/certs/keystone.pem',
  $ssl_keyfile           = '/etc/keystone/ssl/private/keystonekey.pem',
  $ssl_ca_certs          = '/etc/keystone/ssl/certs/ca.pem',
  $ssl_ca_key            = '/etc/keystone/ssl/private/cakey.pem',
  $ssl_cert_subject      = '/C=US/ST=Unset/L=Unset/O=Unset/CN=localhost',
  $cache_dir             = '/var/cache/keystone',
  $memcache_servers      = false,
  $enabled               = true,
  $database_connection   = 'sqlite:////var/lib/keystone/keystone.db',
  $database_idle_timeout = '200',
  $enable_pki_setup      = true,
  $mysql_module          = '0.9',
  $rabbit_host           = 'localhost',
  $rabbit_hosts          = false,
  $rabbit_password       = 'guest',
  $rabbit_port           = '5672',
  $rabbit_userid         = 'guest',
  $rabbit_virtual_host   = '/',
  $notification_driver   = false,
  $notification_topics   = false,
  $control_exchange      = false,
  $service_name          = 'keystone',
  # DEPRECATED PARAMETERS
  $sql_connection        = undef,
  $idle_timeout          = undef,
) {

  if ! $catalog_driver {
    validate_re($catalog_type, 'template|sql')
  }

  if $sql_connection {
    warning('The sql_connection parameter is deprecated, use database_connection instead.')
    $database_connection_real = $sql_connection
  } else {
    $database_connection_real = $database_connection
  }

  if $idle_timeout {
    warning('The idle_timeout parameter is deprecated, use database_idle_timeout instead.')
    $database_idle_timeout_real = $idle_timeout
  } else {
    $database_idle_timeout_real = $database_idle_timeout
  }

  File['/etc/keystone/keystone.conf'] -> Keystone_config<||> ~> Service[$service_name]
  Keystone_config<||> ~> Exec<| title == 'keystone-manage db_sync'|>
  Keystone_config<||> ~> Exec<| title == 'keystone-manage pki_setup'|>
  include ::keystone::params

  package { 'keystone':
    ensure => $package_ensure,
    name   => $::keystone::params::package_name,
  }

  group { 'keystone':
    ensure  => present,
    system  => true,
    require => Package['keystone'],
  }

  user { 'keystone':
    ensure  => 'present',
    gid     => 'keystone',
    system  => true,
    require => Package['keystone'],
  }

  file { ['/etc/keystone', '/var/log/keystone', '/var/lib/keystone']:
    ensure  => directory,
    mode    => '0750',
    owner   => 'keystone',
    group   => 'keystone',
    require => Package['keystone'],
    notify  => Service[$service_name],
  }

  file { '/etc/keystone/keystone.conf':
    ensure  => present,
    mode    => '0600',
    owner   => 'keystone',
    group   => 'keystone',
    require => Package['keystone'],
    notify  => Service[$service_name],
  }

  if $bind_host {
    warning('The bind_host parameter is deprecated, use public_bind_host and admin_bind_host instead.')
    $public_bind_host_real = $bind_host
    $admin_bind_host_real  = $bind_host
  } else {
    $public_bind_host_real = $public_bind_host
    $admin_bind_host_real  = $admin_bind_host
  }

  # default config
  keystone_config {
    'DEFAULT/admin_token':      value => $admin_token, secret => true;
    'DEFAULT/public_bind_host': value => $public_bind_host_real;
    'DEFAULT/admin_bind_host':  value => $admin_bind_host_real;
    'DEFAULT/public_port':      value => $public_port;
    'DEFAULT/admin_port':       value => $admin_port;
    'DEFAULT/compute_port':     value => $compute_port;
    'DEFAULT/verbose':          value => $verbose;
    'DEFAULT/debug':            value => $debug;
  }

  # Endpoint configuration
  if $public_endpoint {
    keystone_config {
      'DEFAULT/public_endpoint': value => $public_endpoint;
    }
  } else {
    keystone_config {
      'DEFAULT/public_endpoint': ensure => absent;
    }
  }
  if $admin_endpoint {
    keystone_config {
      'DEFAULT/admin_endpoint': value => $admin_endpoint;
    }
  } else {
    keystone_config {
      'DEFAULT/admin_endpoint': ensure => absent;
    }
  }

  # token driver config
  keystone_config {
    'token/driver':     value => $token_driver;
    'token/expiration': value => $token_expiration;
  }

  # ssl config
  if ($enable_ssl) {
    keystone_config {
      'ssl/enable':              value  => true;
      'ssl/certfile':            value  => $ssl_certfile;
      'ssl/keyfile':             value  => $ssl_keyfile;
      'ssl/ca_certs':            value  => $ssl_ca_certs;
      'ssl/ca_key':              value  => $ssl_ca_key;
      'ssl/cert_subject':        value  => $ssl_cert_subject;
    }
  } else {
    keystone_config {
      'ssl/enable':              value  => false;
    }
  }

  if($database_connection_real =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
    if ($mysql_module >= 2.2) {
      require 'mysql::bindings'
      require 'mysql::bindings::python'
    } else {
      require 'mysql::python'
    }
  } elsif($database_connection_real =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {

  } elsif($database_connection_real =~ /sqlite:\/\//) {

  } else {
    fail("Invalid db connection ${database_connection_real}")
  }

  # memcache connection config
  if $memcache_servers {
    validate_array($memcache_servers)
    keystone_config {
      'memcache/servers': value => join($memcache_servers, ',');
    }
  } else {
    keystone_config {
      'memcache/servers': ensure => absent;
    }
  }

  # db connection config
  keystone_config {
    'database/connection':   value => $database_connection_real, secret => true;
    'database/idle_timeout': value => $database_idle_timeout_real;
  }

  # configure based on the catalog backend
  if $catalog_driver {
    $catalog_driver_real = $catalog_driver
  }
  elsif ($catalog_type == 'template') {
    $catalog_driver_real = 'keystone.catalog.backends.templated.Catalog'
  }
  elsif ($catalog_type == 'sql') {
    $catalog_driver_real = 'keystone.catalog.backends.sql.Catalog'
  }

  keystone_config {
    'catalog/driver':        value => $catalog_driver_real;
    'catalog/template_file': value => $catalog_template_file;
  }

  if $token_format {
    warning('token_format parameter is deprecated. Use token_provider instead.')
  }

  # remove the old format in case of an upgrade
  keystone_config { 'signing/token_format': ensure => absent }

  if ($token_format == false and $token_provider == 'keystone.token.providers.pki.Provider') or $token_format == 'PKI' {
    keystone_config { 'token/provider': value => 'keystone.token.providers.pki.Provider' }
    file { $cache_dir:
      ensure => directory,
    }

    if $enable_pki_setup {
      exec { 'keystone-manage pki_setup':
        path        => '/usr/bin',
        user        => 'keystone',
        refreshonly => true,
        creates     => '/etc/keystone/ssl/private/signing_key.pem',
        notify      => Service[$service_name],
        subscribe   => Package['keystone'],
        require     => User['keystone'],
      }
    }
  } elsif $token_format == 'UUID' {
    keystone_config { 'token/provider': value => 'keystone.token.providers.uuid.Provider' }
  } else {
    keystone_config { 'token/provider': value => $token_provider }
  }

  if $notification_driver {
    keystone_config { 'DEFAULT/notification_driver': value => $notification_driver }
  } else {
    keystone_config { 'DEFAULT/notification_driver': ensure => absent }
  }
  if $notification_topics {
    keystone_config { 'DEFAULT/notification_topics': value => $notification_topics }
  } else {
    keystone_config { 'DEFAULT/notification_topics': ensure => absent }
  }
  if $control_exchange {
    keystone_config { 'DEFAULT/control_exchange': value => $control_exchange }
  } else {
    keystone_config { 'DEFAULT/control_exchange': ensure => absent }
  }

  keystone_config {
    'DEFAULT/rabbit_password':     value => $rabbit_password, secret => true;
    'DEFAULT/rabbit_userid':       value => $rabbit_userid;
    'DEFAULT/rabbit_virtual_host': value => $rabbit_virtual_host;
  }

  if $rabbit_hosts {
    keystone_config { 'DEFAULT/rabbit_hosts':     value => join($rabbit_hosts, ',') }
    keystone_config { 'DEFAULT/rabbit_ha_queues': value => true }
  } else {
    keystone_config { 'DEFAULT/rabbit_host':      value => $rabbit_host }
    keystone_config { 'DEFAULT/rabbit_port':      value => $rabbit_port }
    keystone_config { 'DEFAULT/rabbit_hosts':     value => "${rabbit_host}:${rabbit_port}" }
    keystone_config { 'DEFAULT/rabbit_ha_queues': value => false }
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  if $service_name == 'keystone' {
    service { 'keystone':
      ensure     => $service_ensure,
      name       => $::keystone::params::service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      provider   => $::keystone::params::service_provider,
    }
  }

  if $enabled {
    include ::keystone::db::sync
    Class['::keystone::db::sync'] ~> Service[$service_name]
  }

  # Syslog configuration
  if $use_syslog {
    keystone_config {
      'DEFAULT/use_syslog':           value  => true;
      'DEFAULT/syslog_log_facility':  value  => $log_facility;
    }
  } else {
    keystone_config {
      'DEFAULT/use_syslog':           value => false;
    }
  }

  if $log_file {
    keystone_config {
      'DEFAULT/log_file': value => $log_file;
      'DEFAULT/log_dir':  value => $log_dir;
    }
  } else {
    if $log_dir {
      keystone_config {
        'DEFAULT/log_dir':  value  => $log_dir;
        'DEFAULT/log_file': ensure => absent;
      }
    } else {
      keystone_config {
        'DEFAULT/log_dir':  ensure => absent;
        'DEFAULT/log_file': ensure => absent;
      }
    }
  }

}
