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
# [*catalog_type*]
#   (Optional) Type of catalog that keystone uses to store endpoints,services.
#   Defaults to sql. (Also accepts template)
#
# [*catalog_driver*]
#   (Optional) Catalog driver used by Keystone to store endpoints and services.
#   Setting this value will override and ignore catalog_type.
#   Defaults to false.
#
# [*catalog_template_file*]
#   (Optional) Path to the catalog used if catalog_type equals 'template'.
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
# [*database_connection*]
#   (Optional) Url used to connect to database.
#   Defaults to undef.
#
# [*database_idle_timeout*]
#   (Optional) Timeout when db connections should be reaped.
#   Defaults to undef.
#
# [*database_max_retries*]
#   (Optional) Maximum number of database connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   (Defaults to undef)
#
# [*database_retry_interval*]
#   (Optional) Interval between retries of opening a database connection.
#   (Defaults to undef)
#
# [*database_max_pool_size*]
#   (Optional) Maximum number of SQL connections to keep open in a pool.
#   Defaults to: undef
#
# [*database_max_overflow*]
#   (Optional) If set, use this value for max_overflow with sqlalchemy.
#   Defaults to: undef
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
#   Format for the notifications. Valid values are 'basic' and 'cadf'.
#   Default to undef
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
# [*log_dir*]
#   (Optional) Directory where logs should be stored
#   If set to $::os_service_default, it will not log to any directory
#   Defaults to undef.
#
# [*log_file*]
#   (Optional) Where to log
#   Defaults to undef.
#
# [*admin_endpoint*]
#   (Optional) The base admin endpoint URL for keystone that are
#   advertised to clients (NOTE: this does NOT affect how keystone listens
#   for connections) (string value)
#   If set to false, no admin_endpoint will be defined in keystone.conf.
#   Sample value: 'http://localhost:5000/'
#   Defaults to $::os_service_default
#
# [*public_endpoint*]
#   (Optional) The base public endpoint URL for keystone that are
#   advertised to clients (NOTE: this does NOT affect how
#   keystone listens for connections) (string value)
#   If set to false, public_endpoint will be set from public_bind_host and
#   public_port, or default to http://127.0.0.1:5000
#   Sample value: 'http://localhost:5000/'
#   Defaults to undef
#
# [*enable_ssl*]
#   (Optional) Toggle for SSL support on the keystone eventlet servers.
#   (boolean value)
#   Defaults to false
#
# [*ssl_certfile*]
#   (Optional) Path of the certfile for SSL. (string value)
#   Defaults to '/etc/keystone/ssl/certs/keystone.pem'
#
# [*ssl_keyfile*]
#   (Optional) Path of the keyfile for SSL. (string value)
#   Defaults to '/etc/keystone/ssl/private/keystonekey.pem'
#
# [*ssl_ca_certs*]
#   (Optional) Path of the ca cert file for SSL. (string value)
#   Defaults to '/etc/keystone/ssl/certs/ca.pem'
#
# [*ssl_ca_key*]
#   (Optional) Path of the CA key file for SSL (string value)
#   Defaults to '/etc/keystone/ssl/private/cakey.pem'
#
# [*ssl_cert_subject*]
#   (Optional) SSL Certificate Subject (auto generated certificate)
#   (string value)
#   Defaults to '/C=US/ST=Unset/L=Unset/O=Unset/CN=localhost'
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
#   This feature was added at the end of Newton. The default value is now False
#   by default but will switch to True once UCA will have latest Keystone version.
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
# [*member_role_id*]
#   (Optional) Similar to the member_role_name option, this represents the
#   default role ID used to associate users with their default projects in the
#   v2 API. This will be used as the explicit role where one is not specified
#   by the v2 API.
#   Defaults to $::os_service_default
#
# [*member_role_name*]
#   (Optional) # This is the role name used in combination with the
#   member_role_id option; see that option for more detail.
#   Defaults to $::os_service_default
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
# === DEPRECATED PARAMETERS
#
# [*admin_bind_host*]
#   (Optional) The IP address of the public network interface to listen on.
#   Default to undef
#
# [*public_bind_host*]
#   (Optional) The IP address of the public network interface to listen on.
#   Default to '0.0.0.0'
#
# [*admin_port*]
#   (Optional) Port that can be used for admin tasks.
#   Defaults to undef
#
# [*public_port*]
#   (Optional) Port that keystone binds to.
#   Defaults to '5000'
#
# [*admin_workers*]
#   (Optional) The number of worker processes to serve the admin eventlet application.
#   This option is deprecated along with eventlet and will be removed in M.
#   This setting has no affect when using WSGI.
#   Defaults to undef
#
# [*public_workers*]
#   (Optional) The number of worker processes to serve the public eventlet application.
#   This option is deprecated along with eventlet and will be removed in M.
#   This setting has no affect when using WSGI.
#   Defaults to undef
#
# [*token_driver*]
#   (Optional) Driver to use for managing tokens.
#   Defaults to undef
#
# [*validate_service*]
#   (Optional) Whether to validate keystone connections after
#   the service is started.
#   Defaults to undef
#
# [*validate_insecure*]
#   (Optional) Whether to validate keystone connections
#   using the --insecure option with keystone client.
#   Defaults to undef
#
# [*validate_cacert*]
#   (Optional) Whether to validate keystone connections
#   using the specified argument with the --os-cacert option
#   with keystone client.
#   Defaults to undef
#
# [*validate_auth_url*]
#   (Optional) The url to validate keystone against
#   Defaults to undef
#
# [*admin_token*]
#   Admin token that can be used to authenticate as a keystone
#   admin. This is not the password for the admin user
#   in the Keystone database. This is a token that bypasses authentication.
#   Defaults to undef
#
# [*admin_password*]
#   Keystone password for the admin user. This is not the admin_token.
#   This is the password that the admin user signs into keystone with.
#   Defaults to undef
#
# [*enable_bootstrap*]
#   (Optional) Enable keystone bootstrapping.
#   This option to true will automatically bootstrap the default domain
#   user by running 'keystone-manage bootstrap'.
#   Defaults to undef
#
# [*database_min_pool_size*]
#   (Optional) Minimum number of SQL connections to keep open in a pool.
#   Defaults to: undef
#
# [*cache_backend*]
#   (Optional) Dogpile.cache backend module. It is recommended that Memcache with pooling
#   (keystone.cache.memcache_pool) or Redis (dogpile.cache.redis) be used in production.
#   This has no effect unless cache_enabled is true and cache_memcache_servers is set.
#   Defaults to undef
#
# [*cache_backend_argument*]
#   (Optional) List of arguments in format of argname:value supplied to the backend module.
#   Specify this option once per argument to be passed to the dogpile.cache backend.
#   This has no effect unless cache_backend and cache_enabled is set.
#   Default to undef
#
# [*cache_enabled*]
#   (Optional) Setting this boolean will enable the caching backend for Keystone.
#   Defaults to undef
#
# [*cache_memcache_servers*]
#   (Optional) List of memcache servers to be used with the caching backend to
#   configure cache/memcache_servers. This has no effect unless cache_backend
#   is set and cache_enabled is true.
#   Specified as a comma separated string of 'server:port,server:port' or an
#   array of servers ['server:port', 'server:port'].
#   Default to undef
#
# [*debug_cache_backend*]
#   (Optional) Extra debugging from the cache backend (cache keys, get/set/delete calls).
#   Default to undef
#
# [*cache_config_prefix*]
#   (Optional) Prefix for building the configuration dictionary for
#   the cache region. This should not need to be changed unless there
#   is another dogpile.cache region with the same configuration name.
#   (string value)
#   Defaults to undef
#
# [*cache_expiration_time*]
#   (Optional) Default TTL, in seconds, for any cached item in the
#   dogpile.cache region. This applies to any cached method that
#   doesn't have an explicit cache expiration time defined for it.
#   (integer value)
#   Defaults to undef
#
# [*cache_proxies*]
#   (Optional) Proxy classes to import that will affect the way the
#   dogpile.cache backend functions. See the dogpile.cache documentation on
#   changing-backend-behavior. (list value)
#   Defaults to undef
#
# [*token_caching*]
#   (Optional) Toggle for token system caching. This has no effect unless
#   cache_backend, cache_enabled and cache_memcache_servers is set.
#   Default to undef
#
# [*memcache_dead_retry*]
#   (Optional) Number of seconds memcached server is considered dead before it
#   is tried again. This is used for the cache memcache_dead_retry and the
#   memcache dead_retry values.
#   Defaults to undef
#
# [*memcache_socket_timeout*]
#   (Optional) Timeout in seconds for every call to a server.
#   (floating point value)
#   Defaults to undef
#
# [*memcache_pool_maxsize*]
#   (Optional) Max total number of open connections to every memcached server.
#   Defaults to undef
#
# [*memcache_pool_unused_timeout*]
#   (Optional) Number of seconds a connection to memcached is held unused in
#   the pool before it is closed.
#   Defaults to undef
#
# [*memcache_pool_connection_get_timeout*]
#   (Optional) Number of seconds that an operation will wait to get a memcache
#   client connection. (integer value)
#   Defaults to undef
#
# [*manage_backend_package*]
#   (Optional) (Optional) Whether to install the backend package for the cache.
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
  $log_dir                              = undef,
  $log_file                             = undef,
  $catalog_type                         = 'sql',
  $catalog_driver                       = false,
  $catalog_template_file                = '/etc/keystone/default_catalog.templates',
  $token_provider                       = 'fernet',
  $token_expiration                     = 3600,
  $password_hash_algorithm              = $::os_service_default,
  $password_hash_rounds                 = $::os_service_default,
  $revoke_driver                        = $::os_service_default,
  $revoke_by_id                         = true,
  $admin_endpoint                       = $::os_service_default,
  $public_endpoint                      = undef,
  $enable_ssl                           = false,
  $ssl_certfile                         = '/etc/keystone/ssl/certs/keystone.pem',
  $ssl_keyfile                          = '/etc/keystone/ssl/private/keystonekey.pem',
  $ssl_ca_certs                         = '/etc/keystone/ssl/certs/ca.pem',
  $ssl_ca_key                           = '/etc/keystone/ssl/private/cakey.pem',
  $ssl_cert_subject                     = '/C=US/ST=Unset/L=Unset/O=Unset/CN=localhost',
  $manage_service                       = true,
  $enabled                              = true,
  $database_connection                  = undef,
  $database_idle_timeout                = undef,
  $database_max_retries                 = undef,
  $database_retry_interval              = undef,
  $database_max_pool_size               = undef,
  $database_max_overflow                = undef,
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
  $enable_credential_setup              = false,
  $credential_key_repository            = '/etc/keystone/credential-keys',
  $credential_keys                      = false,
  $default_domain                       = undef,
  $member_role_id                       = $::os_service_default,
  $member_role_name                     = $::os_service_default,
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
  $admin_bind_host                      = undef,
  $public_bind_host                     = undef,
  $admin_port                           = undef,
  $public_port                          = undef,
  $admin_workers                        = undef,
  $public_workers                       = undef,
  $token_driver                         = undef,
  $validate_service                     = undef,
  $validate_insecure                    = undef,
  $validate_auth_url                    = undef,
  $validate_cacert                      = undef,
  $admin_token                          = undef,
  $admin_password                       = undef,
  $enable_bootstrap                     = undef,
  $database_min_pool_size               = undef,
  $cache_backend                        = undef,
  $cache_backend_argument               = undef,
  $cache_enabled                        = undef,
  $cache_memcache_servers               = undef,
  $debug_cache_backend                  = undef,
  $cache_config_prefix                  = undef,
  $cache_expiration_time                = undef,
  $cache_proxies                        = undef,
  $token_caching                        = undef,
  $memcache_dead_retry                  = undef,
  $memcache_socket_timeout              = undef,
  $memcache_pool_maxsize                = undef,
  $memcache_pool_unused_timeout         = undef,
  $memcache_pool_connection_get_timeout = undef,
  $manage_backend_package               = undef,
) inherits keystone::params {

  include keystone::deps
  include keystone::logging
  include keystone::policy
  include keystone::cache

  if $token_driver {
    warning('keystone::token_driver is deprecated, has no effect and will be removed in a later release')
  }

  if $admin_bind_host {
    warning('keystone::admin_bond_host is deprecated, has not effect and will be removed in a later relase')
  }

  if $admin_port {
    warning('keystone::admin_port is deprecated, has not effect and will be removed in a later relase')
  }

  if $admin_workers {
    warning('keystone::admin_workers is deprecated, has no effect and will be removed in a later release')
  }

  if $public_workers {
    warning('keystone::public_workers is deprecated, has no effect and will be removed in a later release')
  }

  if ! $catalog_driver {
    validate_legacy(Enum['template', 'sql'], 'validate_re', $catalog_type)
  }

  if $public_bind_host {
    warning('keystone::public_bind_host is deprecated, and will have no effect and be removed in a later release.')
    case $public_bind_host {
      '0.0.0.0': {
        $public_host = '127.0.0.1'
      }
      '::0': {
        $public_host = '[::1]'
      }
      default: {
        $public_host = normalize_ip_for_uri($public_bind_host)
      }
    }
  } else {
    $public_host = '127.0.0.1'
  }

  if $public_port {
    warning('keystone::public_port is deprecated, and will have no effect and be removed in a later release')
    $public_port_real = $public_port
  } else {
    $public_port_real = '5000'
  }

  if ! $public_endpoint {
    warning('keystone::public_endpoint is not set, but will be required in a later release')

    if $enable_ssl {
      $public_protocol = 'https'
    } else {
      $public_protocol = 'http'
    }
    $public_endpoint_real = "${public_protocol}://${public_host}:${$public_port_real}"
  } else {
    if ('v2.0' in $public_endpoint) {
      warning('Version string /v2.0/ should not be included in keystone::public_endpoint')
    }
    $public_endpoint_real = $public_endpoint
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

  package { 'keystone':
    ensure => $package_ensure,
    name   => $::keystone::params::package_name,
    tag    => ['openstack', 'keystone-package'],
  }
  if $client_package_ensure == 'present' {
    include '::keystone::client'
  } else {
    class { 'keystone::client':
      ensure => $client_package_ensure,
    }
  }

  resources { 'keystone_config':
    purge  => $purge_config,
  }

  # TODO(tobias-urdin): Remove this when admin_token is removed.
  keystone_config {
    'DEFAULT/admin_token': ensure => 'absent', secret => true;
  }

  keystone_config {
    'DEFAULT/member_role_id':   value => $member_role_id;
    'DEFAULT/member_role_name': value => $member_role_name;
  }

  # Endpoint configuration
  keystone_config {
    'DEFAULT/public_endpoint': value => $public_endpoint_real;
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
  elsif ($catalog_type == 'sql') {
    $catalog_driver_real = 'sql'
  }

  keystone_config {
    'catalog/driver':        value => $catalog_driver_real;
    'catalog/template_file': value => $catalog_template_file;
  }

  keystone_config {
    'token/provider':              value => $token_provider;
    'DEFAULT/max_token_size':      value => $max_token_size;
    'DEFAULT/notification_format': value => $notification_format;
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
  } else {
    warning('Execution of db_sync does not depend on $enabled anymore. Please use sync_db instead.')
  }

  if ($service_name == 'keystone-public-keystone-admin') {
    warning('The value keystone-public-keystone-admin for the Keystone service name is deprecated. \
Use keystone instead')
  }


  case $service_name {
    $::keystone::params::service_name, 'keystone-public-keystone-admin' : {
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
      if $service_name == $::keystone::params::service_name and $::os_package_type != 'debian'{
        warning("Keystone under Eventlet has been deprecated during the Kilo cycle. \
Support for deploying under eventlet will be dropped as of the M-release of OpenStack.")
      }
    }
    'httpd': {
      include apache::params
      $service_name_real = $::apache::params::service_name
    }
    default: {
      fail("Invalid service_name. Either keystone/openstack-keystone for \
running as a standalone service, or httpd for being run by a httpd server")
    }
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
      command     => "service ${service_name_real} restart",
      refreshonly => true,
    }
  }

  if $default_domain {
    keystone_domain { $default_domain:
      ensure     => present,
      enabled    => true,
      is_default => true,
      require    => Service[$service_name],
    } ~> Exec<| title == 'restart_keystone' |>
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
        notify  => Service[$service_name],
        require => Anchor['keystone::install::end'],
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
