#
# Module for managing keystone config.
#
# == Parameters
#
# [*package_ensure*]
#   (optional) Desired ensure state of packages.
#   accepts latest or specific versions.
#   Defaults to present.
#
# [*client_package_ensure*]
#   (optional) Desired ensure state of the client package.
#   accepts latest or specific versions.
#   Defaults to present.
#
# [*public_port*]
#   (optional) Port that keystone binds to.
#   Defaults to '5000'
#
# [*admin_port*]
#   (optional) Port that can be used for admin tasks.
#   Defaults to '35357'
#
# [*admin_token*]
#   Admin token that can be used to authenticate as a keystone
#   admin. This is not the password for the admin user
#   in the Keystone database. This is a token that bypasses authentication.
#   The admin_token has been deprecated by the Keystone service and this
#   will be deprecated in a future changeset. Required.
#
# [*admin_password*]
#   Keystone password for the admin user. This is not the admin_token.
#   This is the password that the admin user signs into keystone with.
#   Required.
#
# [*debug*]
#   (optional) Rather keystone should log at debug level.
#   Defaults to undef.
#
# [*use_syslog*]
#   (optional) Use syslog for logging.
#   Defaults to undef.
#
# [*use_stderr*]
#   (optional) Use stderr for logging
#   Defaults to undef.
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to undef.
#
# [*catalog_type*]
#   (optional) Type of catalog that keystone uses to store endpoints,services.
#   Defaults to sql. (Also accepts template)
#
# [*catalog_driver*]
#   (optional) Catalog driver used by Keystone to store endpoints and services.
#   Setting this value will override and ignore catalog_type.
#   Defaults to false.
#
# [*catalog_template_file*]
#   (optional) Path to the catalog used if catalog_type equals 'template'.
#   Defaults to '/etc/keystone/default_catalog.templates'
#
# [*token_provider*]
#   (optional) Format keystone uses for tokens.
#   Defaults to 'uuid'
#   Supports pki, pkiz, fernet, and uuid.
#
# [*token_driver*]
#   (optional) Driver to use for managing tokens.
#   Defaults to 'sql'
#
# [*token_expiration*]
#   (optional) Amount of time a token should remain valid (seconds).
#   Defaults to 3600 (1 hour).
#
# [*revoke_driver*]
#   (optional) Driver for token revocation.
#   Defaults to $::os_service_default
#
# [*revoke_by_id*]
#   (optional) Revoke token by token identifier.
#   Setting revoke_by_id to true enables various forms of enumerating tokens.
#   These enumerations are processed to determine the list of tokens to revoke.
#   Only disable if you are switching to using the Revoke extension with a backend
#   other than KVS, which stores events in memory.
#   Defaults to true.
#
# [*cache_dir*]
#   (optional) Directory created when token_provider is pki. This folder is not
#   created unless enable_pki_setup is set to True.
#   Defaults to /var/cache/keystone.
#
# [*memcache_servers*]
#   (optional) List of memcache servers as a comma separated string of
#   'server:port,server:port' or an array of servers ['server:port',
#   'server:port'].
#   Used with token_driver 'memcache'.
#   This configures the memcache/servers for keystone and is used as a default
#   for $cache_memcache_servers if it is not specified.
#   Defaults to $::os_service_default
#
# [*cache_backend*]
#   (optional) Dogpile.cache backend module. It is recommended that Memcache with pooling
#   (keystone.cache.memcache_pool) or Redis (dogpile.cache.redis) be used in production.
#   This has no effects unless 'memcache_servers' is set.
#   Defaults to $::os_service_default
#
# [*cache_backend_argument*]
#   (optional) List of arguments in format of argname:value supplied to the backend module.
#   Specify this option once per argument to be passed to the dogpile.cache backend.
#   This has no effects unless 'memcache_servers' is set.
#   Default to $::os_service_default
#
# [*cache_enabled*]
#   (optional) Setting this will enable the caching backend for Keystone.
#   For legacy purposes, this will be enabled automatically enabled if it is
#   not provided and $memcache_servers (or $cache_memcache_servers) is set and
#   cache_backend is provided as well.
#   Defaults to $::os_service_default
#
# [*cache_memcache_servers*]
#   (optional) List of memcache servers to be used with the caching backend to
#   configure cache/memcache_servers.
#   Specified as a comma separated string of 'server:port,server:port' or an
#   array of servers ['server:port', 'server:port'].
#   By default this will be set to the memcache_servers if that is configured
#   and this is left unconfigured.
#   Default to $::os_service_default
#
# [*debug_cache_backend*]
#   (optional) Extra debugging from the cache backend (cache keys, get/set/delete calls).
#   This has no effects unless 'memcache_servers' is set.
#   Default to $::os_service_default
#
# [*cache_config_prefix*]
#   (Optional) Prefix for building the configuration dictionary for
#   the cache region. This should not need to be changed unless there
#   is another dogpile.cache region with the same configuration name.
#   (string value)
#   Defaults to $::os_service_default
#
# [*cache_expiration_time*]
#   (Optional) Default TTL, in seconds, for any cached item in the
#   dogpile.cache region. This applies to any cached method that
#   doesn't have an explicit cache expiration time defined for it.
#   (integer value)
#   Defaults to $::os_service_default
#
# [*cache_proxies*]
#   (Optional) Proxy classes to import that will affect the way the
#   dogpile.cache backend functions. See the dogpile.cache documentation on
#   changing-backend-behavior. (list value)
#   Defaults to $::os_service_default
#
# [*token_caching*]
#   (optional) Toggle for token system caching. This has no effects unless 'memcache_servers' is set.
#   Default to $::os_service_default
#
# [*manage_service*]
#   (Optional) If Puppet should manage service startup / shutdown.
#   Defaults to true.
#
# [*enabled*]
#  (optional) If the keystone services should be enabled.
#   Default to true.
#
# [*database_connection*]
#   (optional) Url used to connect to database.
#   Defaults to undef.
#
# [*database_idle_timeout*]
#   (optional) Timeout when db connections should be reaped.
#   Defaults to undef.
#
# [*database_max_retries*]
#   (optional) Maximum number of database connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   (Defaults to undef)
#
# [*database_retry_interval*]
#   (optional) Interval between retries of opening a database connection.
#   (Defaults to undef)
#
# [*database_min_pool_size*]
#   (optional) Minimum number of SQL connections to keep open in a pool.
#   Defaults to: undef
#
# [*database_max_pool_size*]
#   (optional) Maximum number of SQL connections to keep open in a pool.
#   Defaults to: undef
#
# [*database_max_overflow*]
#   (optional) If set, use this value for max_overflow with sqlalchemy.
#   Defaults to: undef
#
# [*default_transport_url*]
#    (optional) A URL representing the messaging driver to use and its full
#    configuration. Transport URLs take the form:
#      transport://user:pass@host1:port[,hostN:portN]/virtual_host
#    Defaults to $::os_service_default
#
# [*rabbit_host*]
#   (optional) Location of rabbitmq installation.
#    Defaults to $::os_service_default
#
# [*rabbit_port*]
#   (optional) Port for rabbitmq instance.
#   Defaults to $::os_service_default
#
# [*rabbit_hosts*]
#   (optional) Location of rabbitmq installation.
#   Defaults to $::os_service_default
#
# [*rabbit_ha_queues*]
#   (Optional) Use HA queues in RabbitMQ.
#   Defaults to $::os_service_default
#
# [*rabbit_password*]
#   (optional) Password used to connect to rabbitmq.
#   Defaults to $::os_service_default
#
# [*rabbit_userid*]
#   (optional) User used to connect to rabbitmq.
#   Defaults to $::os_service_default
#
# [*rabbit_virtual_host*]
#   (optional) The RabbitMQ virtual host.
#   Defaults to $::os_service_default
#
# [*rabbit_heartbeat_timeout_threshold*]
#   (optional) Number of seconds after which the RabbitMQ broker is considered
#   down if the heartbeat keepalive fails.  Any value >0 enables heartbeats.
#   Heartbeating helps to ensure the TCP connection to RabbitMQ isn't silently
#   closed, resulting in missed or lost messages from the queue.
#   (Requires kombu >= 3.0.7 and amqp >= 1.4.0)
#   Defaults to $::os_service_default
#
# [*rabbit_heartbeat_rate*]
#   (optional) How often during the rabbit_heartbeat_timeout_threshold period to
#   check the heartbeat on RabbitMQ connection.  (i.e. rabbit_heartbeat_rate=2
#   when rabbit_heartbeat_timeout_threshold=60, the heartbeat will be checked
#   every 30 seconds.
#   Defaults to $::os_service_default
#
# [*rabbit_use_ssl*]
#   (optional) Connect over SSL for RabbitMQ
#   Defaults to $::os_serice_default
#
# [*kombu_ssl_ca_certs*]
#   (optional) SSL certification authority file (valid only if SSL enabled).
#   Defaults to $::os_service_default
#
# [*kombu_ssl_certfile*]
#   (optional) SSL cert file (valid only if SSL enabled).
#   Defaults to $::os_service_default
#
# [*kombu_ssl_keyfile*]
#   (optional) SSL key file (valid only if SSL enabled).
#   Defaults to $::os_service_default
#
# [*kombu_ssl_version*]
#   (optional) SSL version to use (valid only if SSL enabled).
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
#   (optional) Possible values are: gzip, bz2. If not set compression will not
#   be used. This option may notbe available in future versions. EXPERIMENTAL.
#   (string value)
#   Defaults to $::os_service_default
#
# [*notification_driver*]
#   RPC driver. Not enabled by default (list value)
#   Defaults to $::os_service_default
#
# [*notification_topics*]
#   (optional) AMQP topics to publish to when using the RPC notification driver.
#   (list value)
#   Default to $::os_service_default
#
# [*notification_format*]
#   Format for the notifications. Valid values are 'basic' and 'cadf'.
#   Default to undef
#
# [*control_exchange*]
#   (optional) AMQP exchange to connect to if using RabbitMQ
#   (string value)
#   Default to $::os_service_default
#
# [*public_bind_host*]
#   (optional) The IP address of the public network interface to listen on
#   Default to '0.0.0.0'.
#
# [*admin_bind_host*]
#   (optional) The IP address of the public network interface to listen on
#   Default to '0.0.0.0'.
#
# [*log_dir*]
#   (optional) Directory where logs should be stored
#   If set to boolean false, it will not log to any directory
#   Defaults to undef.
#
# [*log_file*]
#   (optional) Where to log
#   Defaults to undef.
#
# [*public_endpoint*]
#   (optional) The base public endpoint URL for keystone that are
#   advertised to clients (NOTE: this does NOT affect how
#   keystone listens for connections) (string value)
#   If set to false, no public_endpoint will be defined in keystone.conf.
#   Sample value: 'http://localhost:5000/'
#   Defaults to $::os_service_default
#
# [*admin_endpoint*]
#   (optional) The base admin endpoint URL for keystone that are
#   advertised to clients (NOTE: this does NOT affect how keystone listens
#   for connections) (string value)
#   If set to false, no admin_endpoint will be defined in keystone.conf.
#   Sample value: 'http://localhost:35357/'
#   Defaults to $::os_service_default
#
# [*enable_ssl*]
#   (optional) Toggle for SSL support on the keystone eventlet servers.
#   (boolean value)
#   Defaults to false
#
# [*ssl_certfile*]
#   (optional) Path of the certfile for SSL. (string value)
#   Defaults to '/etc/keystone/ssl/certs/keystone.pem'
#
# [*ssl_keyfile*]
#   (optional) Path of the keyfile for SSL. (string value)
#   Defaults to '/etc/keystone/ssl/private/keystonekey.pem'
#
# [*ssl_ca_certs*]
#   (optional) Path of the ca cert file for SSL. (string value)
#   Defaults to '/etc/keystone/ssl/certs/ca.pem'
#
# [*ssl_ca_key*]
#   (optional) Path of the CA key file for SSL (string value)
#   Defaults to '/etc/keystone/ssl/private/cakey.pem'
#
# [*ssl_cert_subject*]
#   (optional) SSL Certificate Subject (auto generated certificate)
#   (string value)
#   Defaults to '/C=US/ST=Unset/L=Unset/O=Unset/CN=localhost'
#
# [*validate_service*]
#   (optional) Whether to validate keystone connections after
#   the service is started.
#   Defaults to false
#
# [*validate_insecure*]
#   (optional) Whether to validate keystone connections
#   using the --insecure option with keystone client.
#   Defaults to false
#
# [*validate_cacert*]
#   (optional) Whether to validate keystone connections
#   using the specified argument with the --os-cacert option
#   with keystone client.
#   Defaults to undef
#
# [*validate_auth_url*]
#   (optional) The url to validate keystone against
#   Defaults to undef
#
# [*service_name*]
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
#   Defaults to '$::keystone::params::service_name'
#   NOTE: validate_service only applies if the default value is used.
#
# [*paste_config*]
#   (optional) Name of the paste configuration file that defines the
#   available pipelines. (string value)
#   Defaults to $::os_service_default
#
# [*max_token_size*]
#   (optional) maximum allowable Keystone token size
#   Defaults to $::os_service_default
#
# [*admin_workers*]
#   (optional) The number of worker processes to serve the admin eventlet application.
#   This option is deprecated along with eventlet and will be removed in M.
#   This setting has no affect when using WSGI.
#   Defaults to max($::processorcount, 2)
#
# [*public_workers*]
#   (optional) The number of worker processes to serve the public eventlet application.
#   This option is deprecated along with eventlet and will be removed in M.
#   This setting has no affect when using WSGI.
#   Defaults to max($::processorcount, 2)
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
#   Defaults to false
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
# [*enable_bootstrap*]
#   (Optional) Enable keystone bootstrapping.
#   Per upstream Keystone Mitaka commit 7b7fea7a3fe7677981fbf9bac5121bc15601163
#   keystone no longer creates the default domain during the db_sync. This
#   domain is used as the domain for any users created using the legacy v2.0
#   API. This option to true will automatically bootstrap the default domain
#   user by running 'keystone-manage bootstrap'.
#   Defaults to true

# [*default_domain*]
#   (optional) When Keystone v3 support is enabled, v2 clients will need
#   to have a domain assigned for certain operations.  For example,
#   doing a user create operation must have a domain associated with it.
#   This is the domain which will be used if a domain is needed and not
#   explicitly set in the request.  Using this means that you will have
#   to add it to every user/tenant/user_role you create, as without a domain
#   qualification those resources goes into "Default" domain.  See README.
#   Defaults to undef (will use built-in Keystone default)
#
# [*member_role_id*]
#   (optional) # Similar to the member_role_name option, this represents the
#   default role ID used to associate users with their default projects in the
#   v2 API. This will be used as the explicit role where one is not specified
#   by the v2 API.
#   Defaults to $::os_service_default
#
# [*member_role_name*]
#   (optional) # This is the role name used in combination with the
#   member_role_id option; see that option for more detail.
#   Defaults to $::os_service_default
#
# [*memcache_dead_retry*]
#   (optional) Number of seconds memcached server is considered dead before it
#   is tried again. This is used for the cache memcache_dead_retry and the
#   memcache dead_retry values.
#   Defaults to $::os_service_default
#
# [*memcache_socket_timeout*]
#   (optional) Timeout in seconds for every call to a server.
#   Defaults to $::os_service_default
#
# [*memcache_pool_maxsize*]
#   (optional) Max total number of open connections to every memcached server.
#   Defaults to $::os_service_default
#
# [*memcache_pool_unused_timeout*]
#   (optional) Number of seconds a connection to memcached is held unused in
#   the pool before it is closed.
#   Defaults to $::os_service_default
#
# [*memcache_pool_connection_get_timeout*]
#   (Optional) Number of seconds that an operation will wait to get a memcache
#   client connection. (integer value)
#   Defaults to $::os_service_default
#
# [*policy_driver*]
#   Policy backend driver. (string value)
#   Defaults to $::os_service_default.
#
# [*using_domain_config*]
#   (optional) Eases the use of the keystone_domain_config resource type.
#   It ensures that a directory for holding the domain configuration is present
#   and the associated configuration in keystone.conf is set up right.
#   Defaults to false
#
# [*domain_config_directory*]
#   (optional) Specify a domain configuration directory.
#   For this to work the using_domain_config must be set to true.  Raise an
#   error if it's not the case.
#   Defaults to '/etc/keystone/domains'
#
# [*keystone_user*]
#   (optional) Specify the keystone system user to be used with keystone-manage.
#   Defaults to $::keystone::params::keystone_user
#
# [*keystone_group*]
#   (optional) Specify the keystone system group to be used with keystone-manage.
#   Defaults to $::keystone::params::keystone_group
#
# [*manage_policyrcd*]
#   (optional) Whether to manage the policy-rc.d on debian based systems to
#   prevent keystone eventlet and apache from auto-starting on package install.
#   Defaults to false
#
# [*enable_proxy_headers_parsing*]
#   (Optional) Enable paste middleware to handle SSL requests through
#   HTTPProxyToWSGI middleware.
#   Defaults to $::os_service_default.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the keystone config.
#   Defaults to false.
#
# === DEPRECATED PARAMETERS
#
# [*service_provider*]
#   (optional) Deprecated. Provider, that can be used for keystone service.
#
# [*verbose*]
#   (optional) Deprecated. Rather keystone should log at verbose level.
#   Defaults to undef.
#
# [*enable_pki_setup*]
#   (optional) Deprecated. Enable call to pki_setup to generate the cert for signing pki tokens and
#   revocation lists if it doesn't already exist. This generates a cert and key stored in file
#   locations based on the signing_certfile and signing_keyfile paramters below. If you are
#   providing your own signing cert, make this false.
#   Default to undef.
#
# [*signing_certfile*]
#   (optional) Deprecated. Location of the cert file for signing pki tokens and revocation lists.
#   Note that if this file already exists (i.e. you are providing your own signing cert),
#   the file will not be overwritten, even if enable_pki_setup is set to true.
#   Defaults to $::os_service_default
#
# [*signing_keyfile*]
#   (optional) Deprecated. Location of the key file for signing pki tokens and revocation lists.
#   Note that if this file already exists (i.e. you are providing your own signing cert), the file
#   will not be overwritten, even if enable_pki_setup is set to true.
#   Defaults to $::os_service_default
#
# [*signing_ca_certs*]
#   (optional) Deprecated. Use this CA certs file along with signing_certfile/signing_keyfile for
#   signing pki tokens and revocation lists.
#   Defaults to $::os_service_default
#
# [*signing_ca_key*]
#   (optional) Deprecated. Use this CA key file along with signing_certfile/signing_keyfile for signing
#   pki tokens and revocation lists.
#   Defaults to $::os_service_default
#
# [*signing_cert_subject*]
#   (optional) Deprecated. Certificate subject (auto generated certificate) for token signing.
#   Defaults to $::os_service_default
#
# [*signing_key_size*]
#   (optional) Deprecated. Key size (in bits) for token signing cert (auto generated certificate)
#   Defaults to $::os_service_default
#
# == Dependencies
#  None
#
# == Examples
#
#   class { 'keystone':
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
  $admin_password                       = undef,
  $package_ensure                       = 'present',
  $client_package_ensure                = 'present',
  $public_bind_host                     = '0.0.0.0',
  $admin_bind_host                      = '0.0.0.0',
  $public_port                          = '5000',
  $admin_port                           = '35357',
  $debug                                = undef,
  $log_dir                              = undef,
  $log_file                             = undef,
  $use_syslog                           = undef,
  $use_stderr                           = undef,
  $log_facility                         = undef,
  $catalog_type                         = 'sql',
  $catalog_driver                       = false,
  $catalog_template_file                = '/etc/keystone/default_catalog.templates',
  $token_provider                       = 'uuid',
  $token_driver                         = 'sql',
  $token_expiration                     = 3600,
  $revoke_driver                        = $::os_service_default,
  $revoke_by_id                         = true,
  $public_endpoint                      = $::os_service_default,
  $admin_endpoint                       = $::os_service_default,
  $enable_ssl                           = false,
  $ssl_certfile                         = '/etc/keystone/ssl/certs/keystone.pem',
  $ssl_keyfile                          = '/etc/keystone/ssl/private/keystonekey.pem',
  $ssl_ca_certs                         = '/etc/keystone/ssl/certs/ca.pem',
  $ssl_ca_key                           = '/etc/keystone/ssl/private/cakey.pem',
  $ssl_cert_subject                     = '/C=US/ST=Unset/L=Unset/O=Unset/CN=localhost',
  $cache_dir                            = '/var/cache/keystone',
  $memcache_servers                     = $::os_service_default,
  $manage_service                       = true,
  $cache_backend                        = $::os_service_default,
  $cache_backend_argument               = $::os_service_default,
  $cache_enabled                        = $::os_service_default,
  $cache_memcache_servers               = $::os_service_default,
  $debug_cache_backend                  = $::os_service_default,
  $cache_config_prefix                  = $::os_service_default,
  $cache_expiration_time                = $::os_service_default,
  $cache_proxies                        = $::os_service_default,
  $token_caching                        = $::os_service_default,
  $enabled                              = true,
  $database_connection                  = undef,
  $database_idle_timeout                = undef,
  $database_max_retries                 = undef,
  $database_retry_interval              = undef,
  $database_min_pool_size               = undef,
  $database_max_pool_size               = undef,
  $database_max_overflow                = undef,
  $rabbit_host                          = $::os_service_default,
  $rabbit_hosts                         = $::os_service_default,
  $rabbit_password                      = $::os_service_default,
  $rabbit_port                          = $::os_service_default,
  $rabbit_userid                        = $::os_service_default,
  $rabbit_virtual_host                  = $::os_service_default,
  $rabbit_heartbeat_timeout_threshold   = $::os_service_default,
  $rabbit_heartbeat_rate                = $::os_service_default,
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
  $notification_driver                  = $::os_service_default,
  $notification_topics                  = $::os_service_default,
  $notification_format                  = $::os_service_default,
  $control_exchange                     = $::os_service_default,
  $validate_service                     = false,
  $validate_insecure                    = false,
  $validate_auth_url                    = false,
  $validate_cacert                      = undef,
  $paste_config                         = $::os_service_default,
  $service_name                         = $::keystone::params::service_name,
  $max_token_size                       = $::os_service_default,
  $sync_db                              = true,
  $enable_fernet_setup                  = false,
  $fernet_key_repository                = '/etc/keystone/fernet-keys',
  $fernet_max_active_keys               = $::os_service_default,
  $fernet_keys                          = false,
  $enable_credential_setup              = false,
  $credential_key_repository            = '/etc/keystone/credential-keys',
  $credential_keys                      = false,
  $default_domain                       = undef,
  $member_role_id                       = $::os_service_default,
  $member_role_name                     = $::os_service_default,
  $enable_bootstrap                     = true,
  $memcache_dead_retry                  = $::os_service_default,
  $memcache_socket_timeout              = $::os_service_default,
  $memcache_pool_maxsize                = $::os_service_default,
  $memcache_pool_unused_timeout         = $::os_service_default,
  $memcache_pool_connection_get_timeout = $::os_service_default,
  $policy_driver                        = $::os_service_default,
  $using_domain_config                  = false,
  $domain_config_directory              = '/etc/keystone/domains',
  $keystone_user                        = $::keystone::params::keystone_user,
  $keystone_group                       = $::keystone::params::keystone_group,
  $manage_policyrcd                     = false,
  $enable_proxy_headers_parsing         = $::os_service_default,
  $purge_config                         = false,
  # DEPRECATED PARAMETERS
  $admin_workers                        = max($::processorcount, 2),
  $public_workers                       = max($::processorcount, 2),
  $service_provider                     = undef,
  $verbose                              = undef,
  $enable_pki_setup                     = undef,
  $signing_certfile                     = $::os_service_default,
  $signing_keyfile                      = $::os_service_default,
  $signing_ca_certs                     = $::os_service_default,
  $signing_ca_key                       = $::os_service_default,
  $signing_cert_subject                 = $::os_service_default,
  $signing_key_size                     = $::os_service_default,
) inherits keystone::params {

  include ::keystone::deps
  include ::keystone::logging

  if $token_provider == 'uuid' {
    warning("Fernet token is recommended in Mitaka release. The default for token_provider will be changed to 'fernet' in O release.")
  }

  if $service_provider {
    warning("service_provider is deprecated, does nothing and will be removed in a future release, \
use a Puppet resource collector if you want to modify the service provider.")
  }

  if $verbose {
    warning('verbose is deprecated, has no effect and will be removed after Newton cycle.')
  }

  if ! $catalog_driver {
    validate_re($catalog_type, 'template|sql')
  }

  if ($admin_endpoint and 'v2.0' in $admin_endpoint) {
    warning('Version string /v2.0/ should not be included in keystone::admin_endpoint')
  }

  if ($public_endpoint and 'v2.0' in $public_endpoint) {
    warning('Version string /v2.0/ should not be included in keystone::public_endpoint')
  }

  if $admin_password == undef {
    warning("admin_password is required, please set admin_password to a value != admin_token. \
admin_token will be removed in a later release")
    $admin_password_real = $admin_token
  } else {
    $admin_password_real = $admin_password
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

  include ::keystone::db
  include ::keystone::params

  package { 'keystone':
    ensure => $package_ensure,
    name   => $::keystone::params::package_name,
    tag    => ['openstack', 'keystone-package'],
  }
  if $client_package_ensure == 'present' {
    include '::keystone::client'
  } else {
    class { '::keystone::client':
      ensure => $client_package_ensure,
    }
  }

  resources { 'keystone_config':
    purge  => $purge_config,
  }

  keystone_config {
    'DEFAULT/admin_token':      value => $admin_token, secret => true;
    'DEFAULT/public_bind_host': value => $public_bind_host;
    'DEFAULT/admin_bind_host':  value => $admin_bind_host;
    'DEFAULT/public_port':      value => $public_port;
    'DEFAULT/admin_port':       value => $admin_port;
    'DEFAULT/member_role_id':   value => $member_role_id;
    'DEFAULT/member_role_name': value => $member_role_name;
    'paste_deploy/config_file': value => $paste_config;
  }

  # Endpoint configuration
  keystone_config {
    'DEFAULT/public_endpoint': value => $public_endpoint;
    'DEFAULT/admin_endpoint': value => $admin_endpoint;
  }

  # requirements for memcache token driver
  if ($token_driver =~ /memcache/ ) {
    ensure_packages('python-memcache', {
      ensure => present,
      name   => $::keystone::params::python_memcache_package_name,
      tag    => ['openstack'],
    })
  }

  keystone_config {
    'token/driver':     value => $token_driver;
    'token/expiration': value => $token_expiration;
  }

  keystone_config {
    'revoke/driver':    value => $revoke_driver;
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

  if !is_service_default($memcache_servers) or !is_service_default($cache_memcache_servers) {
    Service<| title == 'memcached' |> -> Anchor['keystone::service::begin']
  }

  # TODO(aschultz): remove in N cycle
  if is_service_default($cache_memcache_servers) and !is_service_default($memcache_servers) {

    warning("The keystone module now provides a \$cache_memcache_servers to be used with caching. \
Please specify it separately to configure cache/memcache_servers for keystone. \
This backwards compatibility will be removed in the N cycle.")

    $cache_memcache_servers_real = $memcache_servers
  } else {
    $cache_memcache_servers_real = $cache_memcache_servers
  }

  # TODO(aschultz): remove in N cycle
  if is_service_default($cache_enabled)
      and (!is_service_default($memcache_servers) or !is_service_default($cache_memcache_servers_real))
      and !is_service_default($cache_backend) {

    warning("cache_enabled has been added to control weither or not to enable caching. \
Please specify it separately to configure caching.
We have enabled caching as a backwards compatibility that will be removed in the N cycle")

    $cache_enabled_real = true
  } else {
    $cache_enabled_real = $cache_enabled
  }

  keystone_config {
    'memcache/dead_retry':                value => $memcache_dead_retry;
    'memcache/pool_maxsize':              value => $memcache_pool_maxsize;
    'memcache/pool_unused_timeout':       value => $memcache_pool_unused_timeout;
    'memcache/servers':                   value => join(any2array($memcache_servers), ',');
    'memcache/socket_timeout':            value => $memcache_socket_timeout;
    'token/caching':                      value => $token_caching;
  }

  oslo::cache { 'keystone_config':
    config_prefix                        => $cache_config_prefix,
    expiration_time                      => $cache_expiration_time,
    backend                              => $cache_backend,
    backend_argument                     => $cache_backend_argument,
    proxies                              => $cache_proxies,
    enabled                              => $cache_enabled_real,
    debug_cache_backend                  => $debug_cache_backend,
    memcache_servers                     => $cache_memcache_servers_real,
    memcache_dead_retry                  => $memcache_dead_retry,
    memcache_socket_timeout              => $memcache_socket_timeout,
    memcache_pool_maxsize                => $memcache_pool_maxsize,
    memcache_pool_unused_timeout         => $memcache_pool_unused_timeout,
    memcache_pool_connection_get_timeout => $memcache_pool_connection_get_timeout,
  }

  oslo::middleware { 'keystone_config':
    enable_proxy_headers_parsing => $enable_proxy_headers_parsing,
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

  # Set the signing key/cert configuration values.
  if (!is_service_default($signing_certfile)) {
    warning("PKI token support has been deprecated in the M release and will be removed in the O release. \
Fernet or UUID tokens are recommended.")
  }

  if (!is_service_default($signing_keyfile)) {
    warning("PKI token support has been deprecated in the M release and will be removed in the O release. \
Fernet or UUID tokens are recommended.")
  }

  if (!is_service_default($signing_ca_certs)) {
    warning("PKI token support has been deprecated in the M release and will be removed in the O release. \
Fernet or UUID tokens are recommended.")
  }

  if (!is_service_default($signing_ca_key)) {
    warning("PKI token support has been deprecated in the M release and will be removed in the O release. \
Fernet or UUID tokens are recommended.")
  }

  if (!is_service_default($signing_cert_subject)) {
    warning("PKI token support has been deprecated in the M release and will be removed in the O release. \
Fernet or UUID tokens are recommended.")
  }

  if (!is_service_default($signing_key_size)) {
    warning("PKI token support has been deprecated in the M release and will be removed in the O release. \
Fernet or UUID tokens are recommended.")
  }

  keystone_config {
    'signing/certfile':     value => $signing_certfile;
    'signing/keyfile':      value => $signing_keyfile;
    'signing/ca_certs':     value => $signing_ca_certs;
    'signing/ca_key':       value => $signing_ca_key;
    'signing/cert_subject': value => $signing_cert_subject;
    'signing/key_size':     value => $signing_key_size;
  }

  # Only do pki_setup if we were asked to do so.  This is needed
  # regardless of the token provider since token revocation lists
  # are always signed.
  if $enable_pki_setup == true {

    if is_service_default($signing_keyfile) {
      fail('Please specify path to key file')
    } else {
    # Create cache directory used for signing.
      file { $cache_dir:
        ensure => directory,
      }

      exec { 'keystone-manage pki_setup':
        command     => "keystone-manage pki_setup --keystone-user ${keystone_user} --keystone-group ${keystone_group}",
        path        => '/usr/bin',
        user        => $keystone_user,
        refreshonly => true,
        creates     => $signing_keyfile,
        notify      => Anchor['keystone::service::begin'],
        subscribe   => [Anchor['keystone::install::end'], Anchor['keystone::config::end']],
        tag         => 'keystone-exec',
      }
    }
  }

  keystone_config {
    'token/provider':              value => $token_provider;
    'DEFAULT/max_token_size':      value => $max_token_size;
    'DEFAULT/notification_format': value => $notification_format;
  }

  oslo::messaging::default { 'keystone_config':
    transport_url    => $default_transport_url,
    control_exchange => $control_exchange,
  }

  oslo::messaging::notifications { 'keystone_config':
    driver => $notification_driver,
    topics => $notification_topics,
  }

  oslo::messaging::rabbit { 'keystone_config':
    kombu_ssl_version           => $kombu_ssl_version,
    kombu_ssl_keyfile           => $kombu_ssl_keyfile,
    kombu_ssl_certfile          => $kombu_ssl_certfile,
    kombu_ssl_ca_certs          => $kombu_ssl_ca_certs,
    kombu_reconnect_delay       => $kombu_reconnect_delay,
    kombu_failover_strategy     => $kombu_failover_strategy,
    kombu_compression           => $kombu_compression,
    rabbit_host                 => $rabbit_host,
    rabbit_port                 => $rabbit_port,
    rabbit_hosts                => $rabbit_hosts,
    rabbit_use_ssl              => $rabbit_use_ssl,
    rabbit_userid               => $rabbit_userid,
    rabbit_password             => $rabbit_password,
    rabbit_virtual_host         => $rabbit_virtual_host,
    rabbit_ha_queues            => $rabbit_ha_queues,
    heartbeat_timeout_threshold => $rabbit_heartbeat_timeout_threshold,
    heartbeat_rate              => $rabbit_heartbeat_rate,
  }

  keystone_config {
    'eventlet_server/admin_workers':  value => $admin_workers;
    'eventlet_server/public_workers': value => $public_workers;
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

  if $service_name == $::keystone::params::service_name {
    $service_name_real = $::keystone::params::service_name
    if $validate_service {
      if $validate_auth_url {
        $v_auth_url = $validate_auth_url
      } else {
        $v_auth_url = $admin_endpoint
      }

      class { '::keystone::service':
        ensure         => $service_ensure,
        service_name   => $service_name,
        enable         => $enabled,
        hasstatus      => true,
        hasrestart     => true,
        validate       => true,
        admin_endpoint => $v_auth_url,
        admin_token    => $admin_token,
        insecure       => $validate_insecure,
        cacert         => $validate_cacert,
      }
    } else {
      class { '::keystone::service':
        ensure       => $service_ensure,
        service_name => $service_name,
        enable       => $enabled,
        hasstatus    => true,
        hasrestart   => true,
        validate     => false,
      }
    }
    warning("Keystone under Eventlet has been deprecated during the Kilo cycle. \
Support for deploying under eventlet will be dropped as of the M-release of OpenStack.")
  } elsif $service_name == 'httpd' {
    include ::apache::params
    $service_name_real = $::apache::params::service_name
  } else {
    fail("Invalid service_name. Either keystone/openstack-keystone for \
running as a standalone service, or httpd for being run by a httpd server")
  }

  if $sync_db {
    include ::keystone::db::sync
  }

  # Fernet tokens support
  if $enable_fernet_setup {
    validate_string($fernet_key_repository)
    ensure_resource('file', $fernet_key_repository, {
      ensure    => 'directory',
      owner     => $keystone_user,
      group     => $keystone_group,
      subscribe => Anchor['keystone::install::end'],
    })

  if $fernet_keys {
      validate_hash($fernet_keys)
      create_resources('file', $fernet_keys, {
          'owner'     => $keystone_user,
          'group'     => $keystone_group,
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
    validate_string($credential_key_repository)
    ensure_resource('file', $credential_key_repository, {
      ensure    => 'directory',
      owner     => $keystone_user,
      group     => $keystone_group,
      subscribe => Anchor['keystone::install::end'],
    })

    if $credential_keys {
      validate_hash($credential_keys)
      create_resources('file', $credential_keys, {
          'owner'     => $keystone_user,
          'group'     => $keystone_group,
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
      notify     => Exec['restart_keystone'],
    }
    anchor { 'default_domain_created':
      require => Keystone_domain[$default_domain],
    }
  }
  if $domain_config_directory != '/etc/keystone/domains' and !$using_domain_config {
    fail('You must activate domain configuration using "using_domain_config" parameter to keystone class.')
  }

  if $enable_bootstrap {
    # this requires the database to be up and running and configured
    # and is only run once, so we don't need to notify the service
    exec { 'keystone-manage bootstrap':
      command     => "keystone-manage bootstrap --bootstrap-password ${admin_password_real}",
      user        => $keystone_user,
      path        => '/usr/bin',
      refreshonly => true,
      notify      => Anchor['keystone::service::begin'],
      subscribe   => Anchor['keystone::dbsync::end'],
      tag         => 'keystone-exec',
    }
  }

  if $using_domain_config {
    validate_absolute_path($domain_config_directory)
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
