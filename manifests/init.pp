#
# Module for managing keystone config.
#
# == Parameters
#
# [*manage_package*]
#   (Optional) Manage package resources.
#   Defaults to true.
#
# [*package_ensure*]
#   (Optional) Desired ensure state of packages.
#   accepts latest or specific versions.
#   Defaults to present.
#
# [*catalog_driver*]
#   (Optional) Catalog driver used by Keystone to store endpoints and services.
#   Defaults to $facts['os_service_default'].
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
#   Defaults to $facts['os_service_default']
#
# [*password_hash_rounds*]
#   (Optional) The amount of rounds to do on the hash.
#   Defaults to $facts['os_service_default']
#
# [*max_password_length*]
#   (Optional) Maximum allowed length for user passwords.
#   Defaults to $facts['os_service_default']
#
# [*revoke_driver*]
#   (Optional) Driver for token revocation.
#   Defaults to $facts['os_service_default']
#
# [*revoke_by_id*]
#   (Optional) Revoke token by token identifier.
#   Setting revoke_by_id to true enables various forms of enumerating tokens.
#   These enumerations are processed to determine the list of tokens to revoke.
#   Only disable if you are switching to using the Revoke extension with a backend
#   other than KVS, which stores events in memory.
#   Defaults to $facts['os_service_default']
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
#   Defaults to $facts['os_service_default']
#
# [*rabbit_ha_queues*]
#   (Optional) Use HA queues in RabbitMQ.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_heartbeat_timeout_threshold*]
#   (Optional) Number of seconds after which the RabbitMQ broker is considered
#   down if the heartbeat keepalive fails.  Any value >0 enables heartbeats.
#   Heartbeating helps to ensure the TCP connection to RabbitMQ isn't silently
#   closed, resulting in missed or lost messages from the queue.
#   (Requires kombu >= 3.0.7 and amqp >= 1.4.0)
#   Defaults to $facts['os_service_default']
#
# [*rabbit_heartbeat_rate*]
#   (Optional) How often during the rabbit_heartbeat_timeout_threshold period to
#   check the heartbeat on RabbitMQ connection.  (i.e. rabbit_heartbeat_rate=2
#   when rabbit_heartbeat_timeout_threshold=60, the heartbeat will be checked
#   every 30 seconds.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_heartbeat_in_pthread*]
#   (Optional) EXPERIMENTAL: Run the health check heartbeat thread
#   through a native python thread. By default if this
#   option isn't provided the  health check heartbeat will
#   inherit the execution model from the parent process. By
#   example if the parent process have monkey patched the
#   stdlib by using eventlet/greenlet then the heartbeat
#   will be run through a green thread.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_qos_prefetch_count*]
#   (Optional) Specifies the number of messages to prefetch.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_quorum_queue*]
#   (Optional) Use quorum queues in RabbitMQ.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_transient_quorum_queue*]
#   (Optional) Use quorum queues for transients queues in RabbitMQ.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_quorum_delivery_limit*]
#   (Optional) Each time a message is rdelivered to a consumer, a counter is
#   incremented. Once the redelivery count exceeds the delivery limit
#   the message gets dropped or dead-lettered.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_quorum_max_memory_length*]
#   (Optional) Limit the number of messages in the quorum queue.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_quorum_max_memory_bytes*]
#   (Optional) Limit the number of memory bytes used by the quorum queue.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_enable_cancel_on_failover*]
#   (Optional) Enable x-cancel-on-ha-failover flag so that rabbitmq server will
#   cancel and notify consumers when queue is down.
#   Defaults to $facts['os_service_default']
#
# [*rabbit_use_ssl*]
#   (Optional) Connect over SSL for RabbitMQ
#   Defaults to $facts['os_service_default']
#
# [*kombu_ssl_ca_certs*]
#   (Optional) SSL certification authority file (valid only if SSL enabled).
#   Defaults to $facts['os_service_default']
#
# [*kombu_ssl_certfile*]
#   (Optional) SSL cert file (valid only if SSL enabled).
#   Defaults to $facts['os_service_default']
#
# [*kombu_ssl_keyfile*]
#   (Optional) SSL key file (valid only if SSL enabled).
#   Defaults to $facts['os_service_default']
#
# [*kombu_ssl_version*]
#   (Optional) SSL version to use (valid only if SSL enabled).
#   Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be
#   available on some distributions.
#   Defaults to $facts['os_service_default']
#
# [*kombu_reconnect_delay*]
#   (Optional) How long to wait before reconnecting in response
#   to an AMQP consumer cancel notification. (floating point value)
#   Defaults to $facts['os_service_default']
#
# [*kombu_failover_strategy*]
#   (Optional) Determines how the next RabbitMQ node is chosen in case the one
#   we are currently connected to becomes unavailable. Takes effect only if
#   more than one RabbitMQ node is provided in config. (string value)
#   Defaults to $facts['os_service_default']
#
# [*kombu_compression*]
#   (Optional) Possible values are: gzip, bz2. If not set compression will not
#   be used. This option may notbe available in future versions. EXPERIMENTAL.
#   (string value)
#   Defaults to $facts['os_service_default']
#
# [*notification_transport_url*]
#   (Optional) A URL representing the messaging driver to use for notifications
#   and its full configuration. Transport URLs take the form:
#     transport://user:pass@host1:port[,hostN:portN]/virtual_host
#   Defaults to $facts['os_service_default']
#
# [*notification_driver*]
#   RPC driver. Not enabled by default (list value)
#   Defaults to $facts['os_service_default']
#
# [*notification_topics*]
#   (Optional) AMQP topics to publish to when using the RPC notification driver.
#   (list value)
#   Default to $facts['os_service_default']
#
# [*notification_retry*]
#   (Optional) The maximum number of attempts to re-sent a notification
#   message, which failed to be delivered due to a recoverable error.
#   Defaults to $facts['os_service_default'].
#
# [*notification_format*]
#   (Optional) Define the notification format for identity service events.
#   Valid values are 'basic' and 'cadf'.
#   Default to $facts['os_service_default']
#
# [*notification_opt_out*]
#   (Optional) Opt out notifications that match the patterns expressed in this
#   list.
#   Defaults to $facts['os_service_default']
#
# [*control_exchange*]
#   (Optional) AMQP exchange to connect to if using RabbitMQ
#   (string value)
#   Default to $facts['os_service_default']
#
# [*rpc_response_timeout*]
#   (Optional) Seconds to wait for a response from a call.
#   Defaults to $facts['os_service_default']
#
# [*executor_thread_pool_size*]
#   (Optional) Size of executor thread pool when executor is threading or eventlet.
#   Defaults to $facts['os_service_default'].
#
# [*public_endpoint*]
#   (Optional) The base public endpoint URL for keystone that are
#   advertised to clients (NOTE: this does NOT affect how
#   keystone listens for connections) (string value)
#   Defaults to $facts['os_service_default']
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
#   Defaults to $facts['os_service_default']
#
# [*list_limit*]
#   (Optional) The maximum number of entities that will be returned in
#   a collection.
#   Defaults to $facts['os_service_default']
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
#   Defaults to $facts['os_service_default']
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
#   Defaults to undef
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
#   Defaults to undef
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
#   Defaults to $facts['os_service_default'].
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
#   Defaults to $::keystone::params::user
#
# [*keystone_group*]
#   (Optional) Specify the keystone system group to be used with keystone-manage.
#   Defaults to $::keystone::params::group
#
# [*manage_policyrcd*]
#   (Optional) Whether to manage the policy-rc.d on debian based systems to
#   prevent keystone eventlet and apache from auto-starting on package install.
#   Defaults to false
#
# [*enable_proxy_headers_parsing*]
#   (Optional) Enable oslo middleware to parse proxy headers.
#   Defaults to $facts['os_service_default'].
#
# [*max_request_body_size*]
#   (Optional) Set max request body size
#   Defaults to $facts['os_service_default'].
#
# [*purge_config*]
#   (Optional) Whether to set only the specified config options
#   in the keystone config.
#   Defaults to false.
#
# [*amqp_durable_queues*]
#   (Optional) Whether to use durable queues in AMQP.
#   Defaults to $facts['os_service_default'].
#
# DEPRECATED PARAMETERS
#
# [*client_package_ensure*]
#   (Optional) Desired ensure state of the client package.
#   accepts latest or specific versions.
#   Defaults to present.
#
# [*catalog_template_file*]
#   (Optional) Path to the catalog used if 'templated' catalog driver is used.
#   Defaults to '/etc/keystone/default_catalog.templates'
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
  Boolean $manage_package                         = true,
  $package_ensure                                 = 'present',
  $catalog_driver                                 = $facts['os_service_default'],
  $token_provider                                 = 'fernet',
  $token_expiration                               = 3600,
  $password_hash_algorithm                        = $facts['os_service_default'],
  $password_hash_rounds                           = $facts['os_service_default'],
  $max_password_length                            = $facts['os_service_default'],
  $revoke_driver                                  = $facts['os_service_default'],
  $revoke_by_id                                   = $facts['os_service_default'],
  $public_endpoint                                = $facts['os_service_default'],
  Boolean $manage_service                         = true,
  Boolean $enabled                                = true,
  $rabbit_heartbeat_timeout_threshold             = $facts['os_service_default'],
  $rabbit_heartbeat_rate                          = $facts['os_service_default'],
  $rabbit_heartbeat_in_pthread                    = $facts['os_service_default'],
  $rabbit_qos_prefetch_count                      = $facts['os_service_default'],
  $rabbit_use_ssl                                 = $facts['os_service_default'],
  $default_transport_url                          = $facts['os_service_default'],
  $rabbit_ha_queues                               = $facts['os_service_default'],
  $rabbit_quorum_queue                            = $facts['os_service_default'],
  $rabbit_transient_quorum_queue                  = $facts['os_service_default'],
  $rabbit_quorum_delivery_limit                   = $facts['os_service_default'],
  $rabbit_quorum_max_memory_length                = $facts['os_service_default'],
  $rabbit_quorum_max_memory_bytes                 = $facts['os_service_default'],
  $rabbit_enable_cancel_on_failover               = $facts['os_service_default'],
  $kombu_ssl_ca_certs                             = $facts['os_service_default'],
  $kombu_ssl_certfile                             = $facts['os_service_default'],
  $kombu_ssl_keyfile                              = $facts['os_service_default'],
  $kombu_ssl_version                              = $facts['os_service_default'],
  $kombu_reconnect_delay                          = $facts['os_service_default'],
  $kombu_failover_strategy                        = $facts['os_service_default'],
  $kombu_compression                              = $facts['os_service_default'],
  $notification_transport_url                     = $facts['os_service_default'],
  $notification_driver                            = $facts['os_service_default'],
  $notification_topics                            = $facts['os_service_default'],
  $notification_retry                             = $facts['os_service_default'],
  $notification_format                            = $facts['os_service_default'],
  $notification_opt_out                           = $facts['os_service_default'],
  $control_exchange                               = $facts['os_service_default'],
  $executor_thread_pool_size                      = $facts['os_service_default'],
  $rpc_response_timeout                           = $facts['os_service_default'],
  $service_name                                   = $::keystone::params::service_name,
  $max_token_size                                 = $facts['os_service_default'],
  $list_limit                                     = $facts['os_service_default'],
  Boolean $sync_db                                = true,
  Boolean $enable_fernet_setup                    = true,
  Stdlib::Absolutepath $fernet_key_repository     = '/etc/keystone/fernet-keys',
  $fernet_max_active_keys                         = $facts['os_service_default'],
  Optional[Hash] $fernet_keys                     = undef,
  Boolean $fernet_replace_keys                    = true,
  Boolean $enable_credential_setup                = true,
  Stdlib::Absolutepath $credential_key_repository = '/etc/keystone/credential-keys',
  Optional[Hash] $credential_keys                 = undef,
  $default_domain                                 = undef,
  $policy_driver                                  = $facts['os_service_default'],
  Boolean $using_domain_config                    = false,
  Stdlib::Absolutepath $domain_config_directory   = '/etc/keystone/domains',
  $keystone_user                                  = $::keystone::params::user,
  $keystone_group                                 = $::keystone::params::group,
  Boolean $manage_policyrcd                       = false,
  $enable_proxy_headers_parsing                   = $facts['os_service_default'],
  $max_request_body_size                          = $facts['os_service_default'],
  Boolean $purge_config                           = false,
  $amqp_durable_queues                            = $facts['os_service_default'],
  # DEPRECATED PARAMETERS
  $client_package_ensure                          = undef,
  $catalog_template_file                          = undef,
) inherits keystone::params {

  include keystone::deps
  include keystone::logging
  include keystone::policy

  if $client_package_ensure != undef {
    warning('The client_package_ensure parameter is deprecated and has no effect.')
  }

  if $catalog_template_file != undef {
    warning('The catalog_template_file parameter is deprecated and will be removed in a future release')
    $catalog_template_file_real = $catalog_template_file
  } else {
    $catalog_template_file_real = '/etc/keystone/default_catalog.templates'
  }

  if $manage_policyrcd {
    # openstacklib policy_rcd only affects debian based systems.
    if ($facts['os']['name'] == 'Ubuntu') {
      $policy_services = 'apache2'
      Policy_rcd['apache2'] -> Package['httpd']
    } else {
      $policy_services = ['keystone', 'apache2']
      Policy_rcd['keystone'] -> Package['keystone']
      Policy_rcd['apache2'] -> Package<| title == 'httpd' |>
    }
    ensure_resource('policy_rcd', $policy_services, { ensure => present, 'set_code' => '101' })
  }

  include keystone::db
  include keystone::params

  if $manage_package {
    package { 'keystone':
      ensure => $package_ensure,
      name   => $::keystone::params::package_name,
      tag    => ['openstack', 'keystone-package'],
    }
    include openstacklib::openstackclient
  }

  resources { 'keystone_config':
    purge  => $purge_config,
  }

  # Endpoint configuration
  keystone_config {
    'DEFAULT/public_endpoint': value => $public_endpoint;
  }

  keystone_config {
    'token/provider':   value => $token_provider;
    'token/expiration': value => $token_expiration;
  }

  keystone_config {
    'identity/password_hash_algorithm': value => $password_hash_algorithm;
    'identity/password_hash_rounds':    value => $password_hash_rounds;
    'identity/max_password_length':     value => $max_password_length;
  }

  keystone_config {
    'revoke/driver': value => $revoke_driver;
  }

  keystone_config {
    'policy/driver': value => $policy_driver;
  }

  oslo::middleware { 'keystone_config':
    enable_proxy_headers_parsing => $enable_proxy_headers_parsing,
    max_request_body_size        => $max_request_body_size,
  }

  keystone_config {
    'catalog/driver':        value => $catalog_driver;
    'catalog/template_file': value => $catalog_template_file_real;
  }

  keystone_config {
    'DEFAULT/max_token_size':      value => $max_token_size;
    'DEFAULT/list_limit':          value => $list_limit;
  }

  keystone_config {
    'DEFAULT/notification_format':  value => $notification_format;
    'DEFAULT/notification_opt_out': value => $notification_opt_out;
  }

  oslo::messaging::default { 'keystone_config':
    executor_thread_pool_size => $executor_thread_pool_size,
    transport_url             => $default_transport_url,
    control_exchange          => $control_exchange,
    rpc_response_timeout      => $rpc_response_timeout,
  }

  oslo::messaging::notifications { 'keystone_config':
    transport_url => $notification_transport_url,
    driver        => $notification_driver,
    topics        => $notification_topics,
    retry         => $notification_retry,
  }

  oslo::messaging::rabbit { 'keystone_config':
    kombu_ssl_version               => $kombu_ssl_version,
    kombu_ssl_keyfile               => $kombu_ssl_keyfile,
    kombu_ssl_certfile              => $kombu_ssl_certfile,
    kombu_ssl_ca_certs              => $kombu_ssl_ca_certs,
    kombu_reconnect_delay           => $kombu_reconnect_delay,
    kombu_failover_strategy         => $kombu_failover_strategy,
    kombu_compression               => $kombu_compression,
    rabbit_use_ssl                  => $rabbit_use_ssl,
    rabbit_ha_queues                => $rabbit_ha_queues,
    heartbeat_timeout_threshold     => $rabbit_heartbeat_timeout_threshold,
    heartbeat_rate                  => $rabbit_heartbeat_rate,
    heartbeat_in_pthread            => $rabbit_heartbeat_in_pthread,
    rabbit_qos_prefetch_count       => $rabbit_qos_prefetch_count,
    amqp_durable_queues             => $amqp_durable_queues,
    rabbit_quorum_queue             => $rabbit_quorum_queue,
    rabbit_transient_quorum_queue   => $rabbit_transient_quorum_queue,
    rabbit_quorum_delivery_limit    => $rabbit_quorum_delivery_limit,
    rabbit_quorum_max_memory_length => $rabbit_quorum_max_memory_length,
    rabbit_quorum_max_memory_bytes  => $rabbit_quorum_max_memory_bytes,
    enable_cancel_on_failover       => $rabbit_enable_cancel_on_failover,
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    case $service_name {
      $::keystone::params::service_name: {
        if $facts['os']['name'] != 'Debian' {
          # TODO(tkajinam): Make this hard-fail
          warning('Keystone under Eventlet is no longer supported by this operating system')
        }

        $service_name_real = $::keystone::params::service_name

        service { 'keystone':
          ensure     => $service_ensure,
          name       => $service_name,
          enable     => $enabled,
          hasstatus  => true,
          hasrestart => true,
          tag        => 'keystone-service',
        }

        # On any uwsgi config change, we must restart Keystone.
        Keystone_uwsgi_config<||> ~> Service['keystone']
      }
      'httpd': {
        include apache::params
        $service_name_real = $::apache::params::service_name
        Service <| title == 'httpd' |> { tag +> 'keystone-service' }

        if $facts['os']['name'] == 'Debian' {
          service { 'keystone':
            ensure => 'stopped',
            name   => $::keystone::params::service_name,
            enable => false,
            tag    => 'keystone-service',
          }
          # we need to make sure keystone/eventlet is stopped before trying to start apache
          Service['keystone'] -> Service[$service_name]
        }
      }
      default: {
        fail('Invalid service_name.')
      }
    }
  }

  if $sync_db {
    include keystone::db::sync
  }

  # Fernet tokens support
  if $enable_fernet_setup {
    ensure_resource('file', $fernet_key_repository, {
      ensure    => 'directory',
      owner     => $keystone_user,
      group     => $keystone_group,
      mode      => '0600',
      subscribe => Anchor['keystone::install::end'],
    })

    if $fernet_keys {
      create_resources('file', $fernet_keys, {
          'owner'     => $keystone_user,
          'group'     => $keystone_group,
          'mode'      => '0600',
          'replace'   => $fernet_replace_keys,
          'show_diff' => false,
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
    ensure_resource('file', $credential_key_repository, {
      ensure    => 'directory',
      owner     => $keystone_user,
      group     => $keystone_group,
      mode      => '0600',
      subscribe => Anchor['keystone::install::end'],
    })

    if $credential_keys {
      create_resources('file', $credential_keys, {
          'owner'     => $keystone_user,
          'group'     => $keystone_group,
          'mode'      => '0600',
          'show_diff' => false,
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

  keystone_config {
    'token/revoke_by_id':            value => $revoke_by_id;
    'fernet_tokens/key_repository':  value => $fernet_key_repository;
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

    keystone_config {
      'identity/domain_specific_drivers_enabled': value => true;
      'identity/domain_config_dir':               value => $domain_config_directory;
    }
  } else {
    keystone_config {
      'identity/domain_specific_drivers_enabled': ensure => absent;
      'identity/domain_config_dir':               ensure => absent;
    }
  }
}
