#
# Module for managing keystone config.
#
# == Parameters
#
# [*package_ensure*]
#   (Optional) Desired ensure state of packages.
#   accepts latest or specific versions.
#   Defaults to present.
#
# [*client_package_ensure*]
#   (Optional) Desired ensure state of the client package.
#   accepts latest or specific versions.
#   Defaults to present.
#
# [*catalog_driver*]
#   (Optional) Catalog driver used by Keystone to store endpoints and services.
#   Defaults to false.
#
# [*catalog_template_file*]
#   (Optional) Path to the catalog used if 'templated' catalog driver is used.
#   Defaults to '/etc/keystone/default_catalog.templates'
#
# [*token_provider*]
#   (Optional) Format keystone uses for tokens.
#   Defaults to 'fernet'
#   Supports fernet or uuid.
#
# [*token_expiration*]
#   (Optional) Amount of time a token should remain valid (seconds).
#   Defaults to 3600 (1 hour).
#
# [*password_hash_algorithm*]
#   (Optional) The password hash algorithm to use.
#   Defaults to $::os_service_default
#
# [*password_hash_rounds*]
#   (Optional) The amount of rounds to do on the hash.
#   Defaults to $::os_service_default
#
# [*revoke_driver*]
#   (Optional) Driver for token revocation.
#   Defaults to $::os_service_default
#
# [*revoke_by_id*]
#   (Optional) Revoke token by token identifier.
#   Setting revoke_by_id to true enables various forms of enumerating tokens.
#   These enumerations are processed to determine the list of tokens to revoke.
#   Only disable if you are switching to using the Revoke extension with a backend
#   other than KVS, which stores events in memory.
#   Defaults to true.
#
# [*manage_service*]
#   (Optional) If Puppet should manage service startup / shutdown.
#   Defaults to true.
#
# [*enabled*]
#   (Optional) If the keystone services should be enabled.
#   Default to true.
#
# [*default_transport_url*]
#   (Optional) A URL representing the messaging driver to use and its full
#   configuration. Transport URLs take the form:
#     transport://user:pass@host1:port[,hostN:portN]/virtual_host
#   Defaults to $::os_service_default
#
# [*rabbit_ha_queues*]
#   (Optional) Use HA queues in RabbitMQ.
#   Defaults to $::os_service_default
#
# [*rabbit_heartbeat_timeout_threshold*]
#   (Optional) Number of seconds after which the RabbitMQ broker is considered
#   down if the heartbeat keepalive fails.  Any value >0 enables heartbeats.
#   Heartbeating helps to ensure the TCP connection to RabbitMQ isn't silently
#   closed, resulting in missed or lost messages from the queue.
#   (Requires kombu >= 3.0.7 and amqp >= 1.4.0)
#   Defaults to $::os_service_default
#
# [*rabbit_heartbeat_rate*]
#   (Optional) How often during the rabbit_heartbeat_timeout_threshold period to
#   check the heartbeat on RabbitMQ connection.  (i.e. rabbit_heartbeat_rate=2
#   when rabbit_heartbeat_timeout_threshold=60, the heartbeat will be checked
#   every 30 seconds.
#   Defaults to $::os_service_default
#
# [*rabbit_heartbeat_in_pthread*]
#   (Optional) EXPERIMENTAL: Run the health check heartbeat thread
#   through a native python thread. By default if this
#   option isn't provided the  health check heartbeat will
#   inherit the execution model from the parent process. By
#   example if the parent process have monkey patched the
#   stdlib by using eventlet/greenlet then the heartbeat
#   will be run through a green thread.
#   Defaults to $::os_service_default
#
# [*rabbit_use_ssl*]
#   (Optional) Connect over SSL for RabbitMQ
#   Defaults to $::os_serice_default
#
# [*kombu_ssl_ca_certs*]
#   (Optional) SSL certification authority file (valid only if SSL enabled).
#   Defaults to $::os_service_default
#
# [*kombu_ssl_certfile*]
#   (Optional) SSL cert file (valid only if SSL enabled).
#   Defaults to $::os_service_default
#
# [*kombu_ssl_keyfile*]
#   (Optional) SSL key file (valid only if SSL enabled).
#   Defaults to $::os_service_default
#
# [*kombu_ssl_version*]
#   (Optional) SSL version to use (valid only if SSL enabled).
#   Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be
#   available on some distributions.
#   Defaults to $::os_service_default
#
# [*kombu_reconnect_delay*]
#   (Optional) How long to wait before reconnecting in response
#   to an AMQP consumer cancel notification. (floating point value)
#   Defaults to $::os_service_default
#
# [*kombu_failover_strategy*]
#   (Optional) Determines how the next RabbitMQ node is chosen in case the one
#   we are currently connected to becomes unavailable. Takes effect only if
#   more than one RabbitMQ node is provided in config. (string value)
#   Defaults to $::os_service_default
#
# [*kombu_compression*]
#   (Optional) Possible values are: gzip, bz2. If not set compression will not
#   be used. This option may notbe available in future versions. EXPERIMENTAL.
#   (string value)
#   Defaults to $::os_service_default
#
# [*notification_transport_url*]
#   (Optional) A URL representing the messaging driver to use for notifications
#   and its full configuration. Transport URLs take the form:
#     transport://user:pass@host1:port[,hostN:portN]/virtual_host
#   Defaults to $::os_service_default
#
# [*notification_driver*]
#   RPC driver. Not enabled by default (list value)
#   Defaults to $::os_service_default
#
# [*notification_topics*]
#   (Optional) AMQP topics to publish to when using the RPC notification driver.
#   (list value)
#   Default to $::os_service_default
#
# [*notification_format*]
#   (Optional) Define the notification format for identity service events.
#   Valid values are 'basic' and 'cadf'.
#   Default to $::os_service_default
#
# [*notification_opt_out*]
#   (Optional) Opt out notifications that match the patterns expressed in this
#   list.
#   Defaults to $::os_service_default
#
# [*control_exchange*]
#   (Optional) AMQP exchange to connect to if using RabbitMQ
#   (string value)
#   Default to $::os_service_default
#
# [*rpc_response_timeout*]
#   (Optional) Seconds to wait for a response from a call.
#   Defaults to $::os_service_default
#
# [*public_endpoint*]
#   (Optional) The base public endpoint URL for keystone that are
#   advertised to clients (NOTE: this does NOT affect how
#   keystone listens for connections) (string value)
#   Defaults to $::os_service_default
#
# [*service_name*]
#   (Optional) Name of the service that will be providing the
#   server functionality of keystone.  For example, the default
#   is just 'keystone', which means keystone will be run as a
#   standalone service, and will able to be managed separately
#   by the operating system's service manager. For example,
#   under Red Hat based systems, you will be able to use:
#   systemctl restart openstack-keystone
#   to restart the service. Under Debian, which uses uwsgi
#   (as opposed to eventlet), the service name is simply
#   keystone, so this will work:
#   systemctl restart keystone
#   If the value is 'httpd', this means keystone will be a web
#   service, and you must use another class to configure that
#   web service.  After calling class {'keystone'...}
#   use class { 'keystone::wsgi::apache'...} to make keystone be
#   a web app using apache mod_wsgi.
#   Defaults to '$::keystone::params::service_name'
#
# [*max_token_size*]
#   (Optional) maximum allowable Keystone token size
#   Defaults to $::os_service_default
#
# [*sync_db*]
#   (Optional) Run db sync on the node.
#   Defaults to true
#
# [*enable_fernet_setup*]
#   (Optional) Setup keystone for fernet tokens. This is typically only
#   run on a single node, then the keys are replicated to the other nodes
#   in a cluster. You would typically also pair this with a fernet token
#   provider setting.
#   Defaults to true
#
# [*fernet_key_repository*]
#   (Optional) Location for the fernet key repository. This value must
#   be set if enable_fernet_setup is set to true.
#   Defaults to '/etc/keystone/fernet-keys'
#
# [*fernet_max_active_keys*]
#   (Optional) Number of maximum active Fernet keys. Integer > 0.
#   Defaults to $::os_service_default
#
# [*fernet_keys*]
#   (Optional) Hash of Keystone fernet keys
#   If you enable this parameter, make sure enable_fernet_setup is set to True.
#   Example of valid value:
#   fernet_keys:
#     /etc/keystone/fernet-keys/0:
#       content: c_aJfy6At9y-toNS9SF1NQMTSkSzQ-OBYeYulTqKsWU=
#     /etc/keystone/fernet-keys/1:
#       content: zx0hNG7CStxFz5KXZRsf7sE4lju0dLYvXdGDIKGcd7k=
#   Puppet will create a file per key in $fernet_key_repository.
#   Note: defaults to false so keystone-manage fernet_setup will be executed.
#   Otherwise Puppet will manage keys with File resource.
#   Defaults to false
#
# [*fernet_replace_keys*]
#   (Optional) Whether or not to replace the fernet keys if they are already in
#   the filesystem
#   Defaults to true
#
# [*enable_credential_setup*]
#   (Optional) Setup keystone for credentials.
#   In a cluster environment where multiple Keystone nodes are running, you might
#   need the same keys everywhere; so you'll have to set credential_keys parameter in
#   order to let Puppet manage Keystone keys in a consistent way, otherwise
#   keystone-manage will generate different set of keys on keystone nodes and the
#   service won't work.
#   Defaults to False
#
# [*credential_key_repository*]
#   (Optional) Location for the Credential key repository. This value must
#   be set if enable_credential_setup is set to true.
#   Defaults to '/etc/keystone/credential-keys'
#
# [*credential_keys*]
#   (Optional) Hash of Keystone credential keys
#   If you enable this parameter, make sure enable_credential_setup is set to True.
#   Example of valid value:
#   credential_keys:
#     /etc/keystone/credential-keys/0:
#       content: t-WdduhORSqoyAykuqWAQSYjg2rSRuJYySgI2xh48CI=
#     /etc/keystone/credential-keys/1:
#       content: GLlnyygEVJP4-H2OMwClXn3sdSQUZsM5F194139Unv8=
#   Puppet will create a file per key in $credential_key_repository.
#   Note: defaults to false so keystone-manage credential_setup will be executed.
#   Otherwise Puppet will manage keys with File resource.
#   Defaults to false
#
# [*default_domain*]
#   (Optional) When Keystone v3 support is enabled, v2 clients will need
#   to have a domain assigned for certain operations.  For example,
#   doing a user create operation must have a domain associated with it.
#   This is the domain which will be used if a domain is needed and not
#   explicitly set in the request.  Using this means that you will have
#   to add it to every user/tenant/user_role you create, as without a domain
#   qualification those resources goes into "Default" domain.  See README.
#   Defaults to undef (will use built-in Keystone default)
#
# [*policy_driver*]
#   Policy backend driver. (string value)
#   Defaults to $::os_service_default.
#
# [*using_domain_config*]
#   (Optional) Eases the use of the keystone_domain_config resource type.
#   It ensures that a directory for holding the domain configuration is present
#   and the associated configuration in keystone.conf is set up right.
#   Defaults to false
#
# [*domain_config_directory*]
#   (Optional) Specify a domain configuration directory.
#   For this to work the using_domain_config must be set to true.  Raise an
#   error if it's not the case.
#   Defaults to '/etc/keystone/domains'
#
# [*keystone_user*]
#   (Optional) Specify the keystone system user to be used with keystone-manage.
#   Defaults to $::keystone::params::keystone_user
#
# [*keystone_group*]
#   (Optional) Specify the keystone system group to be used with keystone-manage.
#   Defaults to $::keystone::params::keystone_group
#
# [*manage_policyrcd*]
#   (Optional) Whether to manage the policy-rc.d on debian based systems to
#   prevent keystone eventlet and apache from auto-starting on package install.
#   Defaults to false
#
# [*enable_proxy_headers_parsing*]
#   (Optional) Enable oslo middleware to parse proxy headers.
#   Defaults to $::os_service_default.
#
# [*max_request_body_size*]
#   (Optional) Set max request body size
#   Defaults to $::os_service_default.
#
# [*purge_config*]
#   (Optional) Whether to set only the specified config options
#   in the keystone config.
#   Defaults to false.
#
# [*amqp_durable_queues*]
#   (Optional) Whether to use durable queues in AMQP.
#   Defaults to $::os_service_default.
#
# DEPRECATED PARAMETERS
#
# [*member_role_id*]
#   (Optional) Similar to the member_role_name option, this represents the
#   default role ID used to associate users with their default projects in the
#   v2 API. This will be used as the explicit role where one is not specified
#   by the v2 API.
#   Defaults to undef
#
# [*member_role_name*]
#   (Optional) # This is the role name used in combination with the
#   member_role_id option; see that option for more detail.
#   Defaults to undef
#
# [*admin_endpoint*]
#   (Optional) The base admin endpoint URL for keystone that are
#   advertised to clients (NOTE: this does NOT affect how keystone listens
#   for connections) (string value)
#   If set to false, no admin_endpoint will be defined in keystone.conf.
#   Sample value: 'http://localhost:5000/'
#   Defaults to undef
#
# [*catalog_type*]
#   (Optional) Type of catalog that keystone uses to store endpoints, services.
#   This accepts sql or template.
#   Defaults to undef.
#
# [*log_dir*]
#   (Optional) Directory where logs should be stored
#   If set to $::os_service_default, it will not log to any directory
#   Defaults to undef.
#
# [*log_file*]
#   (Optional) Where to log
#   Defaults to undef.
#
# [*enable_ssl*]
#   (Optional) Toggle for SSL support on the keystone eventlet servers.
#   (boolean value)
#   Defaults to undef
#
# [*ssl_certfile*]
#   (Optional) Path of the certfile for SSL. (string value)
#   Defaults to undef
#
# [*ssl_keyfile*]
#   (Optional) Path of the keyfile for SSL. (string value)
#   Defaults to undef
#
# [*ssl_ca_certs*]
#   (Optional) Path of the ca cert file for SSL. (string value)
#   Defaults to undef
#
# [*ssl_ca_key*]
#   (Optional) Path of the CA key file for SSL (string value)
#   Defaults to undef
#
# [*ssl_cert_subject*]
#   (Optional) SSL Certificate Subject (auto generated certificate)
#   (string value)
#   Defaults to undef
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
  $package_ensure                       = 'present',
  $client_package_ensure                = 'present',
  $catalog_driver                       = false,
  $catalog_template_file                = '/etc/keystone/default_catalog.templates',
  $token_provider                       = 'fernet',
  $token_expiration                     = 3600,
  $password_hash_algorithm              = $::os_service_default,
  $password_hash_rounds                 = $::os_service_default,
  $revoke_driver                        = $::os_service_default,
  $revoke_by_id                         = true,
  $public_endpoint                      = $::os_service_default,
  $manage_service                       = true,
  $enabled                              = true,
  $rabbit_heartbeat_timeout_threshold   = $::os_service_default,
  $rabbit_heartbeat_rate                = $::os_service_default,
  $rabbit_heartbeat_in_pthread          = $::os_service_default,
  $rabbit_use_ssl                       = $::os_service_default,
  $default_transport_url                = $::os_service_default,
  $rabbit_ha_queues                     = $::os_service_default,
  $kombu_ssl_ca_certs                   = $::os_service_default,
  $kombu_ssl_certfile                   = $::os_service_default,
  $kombu_ssl_keyfile                    = $::os_service_default,
  $kombu_ssl_version                    = $::os_service_default,
  $kombu_reconnect_delay                = $::os_service_default,
  $kombu_failover_strategy              = $::os_service_default,
  $kombu_compression                    = $::os_service_default,
  $notification_transport_url           = $::os_service_default,
  $notification_driver                  = $::os_service_default,
  $notification_topics                  = $::os_service_default,
  $notification_format                  = $::os_service_default,
  $notification_opt_out                 = $::os_service_default,
  $control_exchange                     = $::os_service_default,
  $rpc_response_timeout                 = $::os_service_default,
  $service_name                         = $::keystone::params::service_name,
  $max_token_size                       = $::os_service_default,
  $sync_db                              = true,
  $enable_fernet_setup                  = true,
  $fernet_key_repository                = '/etc/keystone/fernet-keys',
  $fernet_max_active_keys               = $::os_service_default,
  $fernet_keys                          = false,
  $fernet_replace_keys                  = true,
  $enable_credential_setup              = true,
  $credential_key_repository            = '/etc/keystone/credential-keys',
  $credential_keys                      = false,
  $default_domain                       = undef,
  $policy_driver                        = $::os_service_default,
  $using_domain_config                  = false,
  $domain_config_directory              = '/etc/keystone/domains',
  $keystone_user                        = $::keystone::params::keystone_user,
  $keystone_group                       = $::keystone::params::keystone_group,
  $manage_policyrcd                     = false,
  $enable_proxy_headers_parsing         = $::os_service_default,
  $max_request_body_size                = $::os_service_default,
  $purge_config                         = false,
  $amqp_durable_queues                  = $::os_service_default,
  # DEPRECATED PARAMETERS
  $member_role_id                       = undef,
  $member_role_name                     = undef,
  $admin_endpoint                       = undef,
  $catalog_type                         = undef,
  $log_dir                              = undef,
  $log_file                             = undef,
  $enable_ssl                           = undef,
  $ssl_certfile                         = undef,
  $ssl_keyfile                          = undef,
  $ssl_ca_certs                         = undef,
  $ssl_ca_key                           = undef,
  $ssl_cert_subject                     = undef,
) inherits keystone::params {

  include keystone::deps
  include keystone::logging
  include keystone::policy

  if $catalog_type != undef {
    warning('The catalog_type parameter is deprecated. Use the catalog_driver parameter instead.')
    if ! $catalog_driver {
      validate_legacy(Enum['template', 'sql'], 'validate_re', $catalog_type)
    }
  }

  [
    'enable_ssl',
    'ssl_certfile',
    'ssl_ca_certs',
    'ssl_ca_key',
    'ssl_cert_subject'
  ].each |String $ssl_opt| {
    if getvar($ssl_opt) != undef {
      warning("The ${ssl_opt} parameter has been deprecated and has no effect.")
    }
  }

  if $manage_policyrcd {
    # openstacklib policy_rcd only affects debian based systems.
    Policy_rcd <| title == 'keystone' |> -> Package['keystone']
    Policy_rcd['apache2'] -> Package['httpd']
    # we don't have keystone service anymore starting from Newton
    if ($::operatingsystem == 'Ubuntu') and (versioncmp($::operatingsystemmajrelease, '16') >= 0) {
      $policy_services = 'apache2'
    } else {
      $policy_services = ['keystone', 'apache2']
    }
    ensure_resource('policy_rcd', $policy_services, { ensure => present, 'set_code' => '101' })
  }

  include keystone::db
  include keystone::params

  if $member_role_id != undef {
    warning('The keystone::member_role_id parameter is deprecated and has no effect')
  }

  if $member_role_name != undef {
    warning('The keystone::member_role_name parameter is deprecated and has no effect')
  }

  if $log_dir != undef {
    warning('The keystone::log_dir parameter is deprecated and has no effect.')
  }

  if $log_file != undef {
    warning('The keystone::log_file parameter is deprecated and has no effect.')
  }

  # TODO(tkajinam): Remove this when removing member_role_* parameters
  keystone_config {
    'DEFAULT/member_role_id':   ensure => absent;
    'DEFAULT/member_role_name': ensure => absent;
  }

  if $admin_endpoint != undef {
    warning('The keystone::admin_endpoint parameter is deprecated. This parameter has no effect')
  }

  package { 'keystone':
    ensure => $package_ensure,
    name   => $::keystone::params::package_name,
    tag    => ['openstack', 'keystone-package'],
  }
  if $client_package_ensure == 'present' {
    include keystone::client
  } else {
    class { 'keystone::client':
      ensure => $client_package_ensure,
    }
  }

  resources { 'keystone_config':
    purge  => $purge_config,
  }

  # Endpoint configuration
  keystone_config {
    'DEFAULT/public_endpoint': value => $public_endpoint;
  }

  keystone_config {
    'token/expiration': value => $token_expiration;
  }

  keystone_config {
    'identity/password_hash_algorithm': value => $password_hash_algorithm;
    'identity/password_hash_rounds':    value => $password_hash_rounds;
  }

  keystone_config {
    'revoke/driver': value => $revoke_driver;
  }

  keystone_config {
    'policy/driver': value => $policy_driver;
  }

  # TODO(tkajinam): Remove this after Z-release
  keystone_config {
    'ssl/enable':       ensure => absent;
    'ssl/certfile':     ensure => absent;
    'ssl/keyfile':      ensure => absent;
    'ssl/ca_certs':     ensure => absent;
    'ssl/ca_key':       ensure => absent;
    'ssl/cert_subject': ensure => absent;
  }

  oslo::middleware { 'keystone_config':
    enable_proxy_headers_parsing => $enable_proxy_headers_parsing,
    max_request_body_size        => $max_request_body_size,
  }

  # configure based on the catalog backend
  if $catalog_driver {
    $catalog_driver_real = $catalog_driver
  }
  elsif ($catalog_type == 'template') {
    $catalog_driver_real = 'templated'
  }
  else {
    $catalog_driver_real = 'sql'
  }

  keystone_config {
    'catalog/driver':        value => $catalog_driver_real;
    'catalog/template_file': value => $catalog_template_file;
  }

  keystone_config {
    'token/provider':              value => $token_provider;
    'DEFAULT/max_token_size':      value => $max_token_size;
  }

  keystone_config {
    'DEFAULT/notification_format':  value => $notification_format;
    'DEFAULT/notification_opt_out': value => $notification_opt_out;
  }

  oslo::messaging::default { 'keystone_config':
    transport_url        => $default_transport_url,
    control_exchange     => $control_exchange,
    rpc_response_timeout => $rpc_response_timeout,
  }

  oslo::messaging::notifications { 'keystone_config':
    transport_url => $notification_transport_url,
    driver        => $notification_driver,
    topics        => $notification_topics,
  }

  oslo::messaging::rabbit { 'keystone_config':
    kombu_ssl_version           => $kombu_ssl_version,
    kombu_ssl_keyfile           => $kombu_ssl_keyfile,
    kombu_ssl_certfile          => $kombu_ssl_certfile,
    kombu_ssl_ca_certs          => $kombu_ssl_ca_certs,
    kombu_reconnect_delay       => $kombu_reconnect_delay,
    kombu_failover_strategy     => $kombu_failover_strategy,
    kombu_compression           => $kombu_compression,
    rabbit_use_ssl              => $rabbit_use_ssl,
    rabbit_ha_queues            => $rabbit_ha_queues,
    heartbeat_timeout_threshold => $rabbit_heartbeat_timeout_threshold,
    heartbeat_rate              => $rabbit_heartbeat_rate,
    heartbeat_in_pthread        => $rabbit_heartbeat_in_pthread,
    amqp_durable_queues         => $amqp_durable_queues,
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    case $service_name {
      $::keystone::params::service_name: {
        $service_name_real = $::keystone::params::service_name

        class { 'keystone::service':
          ensure       => $service_ensure,
          service_name => $service_name,
          enable       => $enabled,
          hasstatus    => true,
          hasrestart   => true,
        }

        # Note: Debian uses uwsgi if using keystone service, which isn't deprecated
        # and therefore, no warning should be displayed.
        if $service_name == $::keystone::params::service_name and $::operatingsystem != 'Debian'{
          warning("Keystone under Eventlet has been deprecated during the Kilo cycle. \
Support for deploying under eventlet will be dropped as of the M-release of OpenStack.")
        }
      }
      'httpd': {
        include apache::params
        $service_name_real = $::apache::params::service_name
        Service <| title == 'httpd' |> { tag +> 'keystone-service' }
      }
      default: {
        fail("Invalid service_name. Either keystone/openstack-keystone for \
running as a standalone service, or httpd for being run by a httpd server")
      }
    }
  } else {
    warning('Execution of db_sync does not depend on $enabled anymore. Please use sync_db instead.')
  }


  if $sync_db {
    include keystone::db::sync
  }

  # Fernet tokens support
  if $enable_fernet_setup {
    validate_legacy(String, 'validate_string', $fernet_key_repository)
    ensure_resource('file', $fernet_key_repository, {
      ensure    => 'directory',
      owner     => $keystone_user,
      group     => $keystone_group,
      mode      => '0600',
      subscribe => Anchor['keystone::install::end'],
    })

  if $fernet_keys {
      validate_legacy(Hash, 'validate_hash', $fernet_keys)
      create_resources('file', $fernet_keys, {
          'owner'     => $keystone_user,
          'group'     => $keystone_group,
          'mode'      => '0600',
          'replace'   => $fernet_replace_keys,
          'subscribe' => 'Anchor[keystone::install::end]',
          'tag'       => 'keystone-fernet-key',
        }
      )
    } else {
      exec { 'keystone-manage fernet_setup':
        command     => "keystone-manage fernet_setup --keystone-user ${keystone_user} --keystone-group ${keystone_group}",
        path        => '/usr/bin',
        user        => $keystone_user,
        refreshonly => true,
        creates     => "${fernet_key_repository}/0",
        notify      => Anchor['keystone::service::begin'],
        subscribe   => [Anchor['keystone::install::end'], Anchor['keystone::config::end']],
        require     => File[$fernet_key_repository],
        tag         => 'keystone-exec',
      }
    }
  }

  # Credential support
  if $enable_credential_setup {
    validate_legacy(String, 'validate_string', $credential_key_repository)
    ensure_resource('file', $credential_key_repository, {
      ensure    => 'directory',
      owner     => $keystone_user,
      group     => $keystone_group,
      mode      => '0600',
      subscribe => Anchor['keystone::install::end'],
    })

    if $credential_keys {
      validate_legacy(Hash, 'validate_hash', $credential_keys)
      create_resources('file', $credential_keys, {
          'owner'     => $keystone_user,
          'group'     => $keystone_group,
          'mode'      => '0600',
          'subscribe' => 'Anchor[keystone::install::end]',
        }
      )
    } else {
      exec { 'keystone-manage credential_setup':
        command     => "keystone-manage credential_setup --keystone-user ${keystone_user} --keystone-group ${keystone_group}",
        path        => '/usr/bin',
        user        => $keystone_user,
        refreshonly => true,
        creates     => "${credential_key_repository}/0",
        notify      => Anchor['keystone::service::begin'],
        subscribe   => [Anchor['keystone::install::end'], Anchor['keystone::config::end']],
        require     => File[$credential_key_repository],
        tag         => 'keystone-exec',
      }
    }
  }

  if $fernet_key_repository {
    keystone_config {
      'fernet_tokens/key_repository': value => $fernet_key_repository;
    }
  } else {
    keystone_config {
      'fernet_tokens/key_repository': ensure => absent;
    }
  }

  keystone_config {
    'token/revoke_by_id':            value => $revoke_by_id;
    'fernet_tokens/max_active_keys': value => $fernet_max_active_keys;
    'credential/key_repository':     value => $credential_key_repository;
  }

  # Update this code when https://bugs.launchpad.net/keystone/+bug/1472285 is addressed.
  # 1/ Keystone needs to be started before creating the default domain
  # 2/ Once the default domain is created, we can query Keystone to get the default domain ID
  # 3/ The Keystone_domain provider has in charge of doing the query and configure keystone.conf
  # 4/ After such a change, we need to restart Keystone service.
  # restart_keystone exec is doing 4/, it restart Keystone if we have a new default domain setted
  # and if we manage the service to be enabled.
  if $manage_service and $enabled {
    exec { 'restart_keystone':
      path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin/'],
      command     => "systemctl restart ${service_name_real}",
      refreshonly => true,
    }
  }

  if $default_domain {
    keystone_domain { $default_domain:
      ensure     => present,
      enabled    => true,
      is_default => true,
    } ~> Exec<| title == 'restart_keystone' |>

    if $manage_service {
      Service[$service_name] -> Keystone_domain[$default_domain]
    }

    anchor { 'default_domain_created':
      require => Keystone_domain[$default_domain],
    }
  }
  if $domain_config_directory != '/etc/keystone/domains' and !$using_domain_config {
    fail('You must activate domain configuration using "using_domain_config" parameter to keystone class.')
  }

  if $using_domain_config {
    validate_legacy(Stdlib::Absolutepath, 'validate_absolute_path', $domain_config_directory)

    # Better than ensure resource.  We don't want to conflict with any
    # user definition even if they don't match exactly our parameters.
    # The error catching mechanism in the provider will remind them if
    # they did something silly, like defining a file rather than a
    # directory.  For the permission it's their choice.
    if (!defined(File[$domain_config_directory])) {
      file { $domain_config_directory:
        ensure  => directory,
        owner   => $keystone_user,
        group   => $keystone_group,
        mode    => '0750',
        require => Anchor['keystone::install::end'],
      }
      if $manage_service {
        File[$domain_config_directory] ~> Service[$service_name]
      }
    }
    # Here we want the creation to fail if the user has created those
    # resources with different values. That means that the user
    # wrongly uses using_domain_config parameter.
    ensure_resource(
      'keystone_config',
      'identity/domain_specific_drivers_enabled',
      {'value' => true}
    )
    ensure_resource(
      'keystone_config',
      'identity/domain_config_dir',
      {'value' => $domain_config_directory}
    )
  }
}
