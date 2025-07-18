# == Definition: keystone::resource::authtoken
#
# This resource configures Keystone authentication resources for an OpenStack
# service.  It will manage the [keystone_authtoken] section in the given
# config resource.  It supports all of the authentication parameters specified
# at http://www.jamielennox.net/blog/2015/02/17/loading-authentication-plugins/
# with the addition of the default domain for user and project.
#
# For example, instead of doing this::
#
#     glance_api_config {
#       'keystone_authtoken/project_name': value => $keystone_tenant;
#       'keystone_authtoken/username'    : value => $keystone_user;
#       'keystone_authtoken/password'    : value => $keystone_password;
#       secret => true;
#       ...
#     }
#
# manifests should do this instead::
#
#     keystone::resource::authtoken { 'glance_api_config':
#       username            => $keystone_user,
#       password            => $keystone_password,
#       auth_url            => $real_identity_uri,
#       project_name        => $keystone_tenant,
#       user_domain_name    => $keystone_user_domain,
#       project_domain_name => $keystone_project_domain,
#       cacert              => $ca_file,
#       ...
#     }
#
# The use of `keystone::resource::authtoken` makes it easy to avoid mistakes,
# and makes it easier to support some of the newer authentication types coming
# with Keystone Kilo and later, such as Kerberos, Federation, etc.
#
# == Parameters:
#
# [*name*]
#   (Required) The name of the resource corresponding to the config file.
#   For example, keystone::resource::authtoken { 'glance_api_config': ... }
#   Where 'glance_api_config' is the name of the resource used to manage
#   the glance api configuration.
#
# [*username*]
#   (Required) The name of the service user
#
# [*password*]
#   (Required) Password to create for the service user
#
# [*auth_url*]
#   (Optional) The URL to use for authentication.
#   Defaults to 'http://127.0.0.1:5000'
#
# [*project_name*]
#   (Optional) Service project name
#   Defaults to $facts['os_service_default']
#
# [*user_domain_name*]
#   (Optional) Name of domain for $username
#   Defaults to $facts['os_service_default']
#
# [*project_domain_name*]
#   (Optional) Name of domain for $project_name
#   Defaults to $facts['os_service_default']
#
# [*system_scope*]
#   (Optional) Scope for system operations
#   Defaults to $facts['os_service_default']
#
# [*insecure*]
#  (Optional) If true, explicitly allow TLS without checking server cert
#  against any certificate authorities.  WARNING: not recommended.  Use with
#  caution.
#  Defaults to $facts['os_service_default']
#
# [*auth_section*]
#  (Optional) Config Section from which to load plugin specific options
#  Defaults to $facts['os_service_default'].
#
# [*auth_type*]
#  (Optional) Authentication type to load
#  Defaults to $facts['os_service_default']
#
# [*www_authenticate_uri*]
#  (Optional) Complete public Identity API endpoint.
#  Defaults to $facts['os_service_default'].
#
# [*auth_version*]
#  (Optional) API version of the admin Identity API endpoint.
#  Defaults to $facts['os_service_default'].
#
# [*cache*]
#  (Optional) Env key for the swift cache.
#  Defaults to $facts['os_service_default'].
#
# [*cafile*]
#  (Optional) A PEM encoded Certificate Authority to use when verifying HTTPs
#  connections.
#  Defaults to $facts['os_service_default'].
#
# [*certfile*]
#  (Optional) Required if identity server requires client certificate
#  Defaults to $facts['os_service_default'].
#
# [*collect_timing*]
#  (Optional) If true, collect per-method timing information for each API call.
#  Defaults to $facts['os_service_default'].
#
# [*delay_auth_decision*]
#  (Optional) Do not handle authorization requests within the middleware, but
#  delegate the authorization decision to downstream WSGI components. Boolean value
#  Defaults to $facts['os_service_default'].
#
# [*enforce_token_bind*]
#  (Optional) Used to control the use and type of token binding. Can be set
#  to: "disabled" to not check token binding. "permissive" (default) to
#  validate binding information if the bind type is of a form known to the
#  server and ignore it if not. "strict" like "permissive" but if the bind
#  type is unknown the token will be rejected. "required" any form of token
#  binding is needed to be allowed. Finally the name of a binding method that
#  must be present in tokens. String value.
#  Defaults to $facts['os_service_default'].
#
# [*http_connect_timeout*]
#  (Optional) Request timeout value for communicating with Identity API server.
#  Defaults to $facts['os_service_default'].
#
# [*http_request_max_retries*]
#  (Optional) How many times are we trying to reconnect when communicating
#  with Identity API Server. Integer value
#  Defaults to $facts['os_service_default'].
#
# [*include_service_catalog*]
#  (Optional) Indicate whether to set the X-Service-Catalog header. If False,
#  middleware will not ask for service catalog on token validation and will not
#  set the X-Service-Catalog header. Boolean value.
#  Defaults to $facts['os_service_default'].
#
# [*keyfile*]
#  (Optional) Required if identity server requires client certificate
#  Defaults to $facts['os_service_default'].
#
# [*memcache_pool_conn_get_timeout*]
#  (Optional) Number of seconds that an operation will wait to get a memcached
#  client connection from the pool. Integer value
#  Defaults to $facts['os_service_default'].
#
# [*memcache_pool_dead_retry*]
#  (Optional) Number of seconds memcached server is considered dead before it
#  is tried again. Integer value
#  Defaults to $facts['os_service_default'].
#
# [*memcache_pool_maxsize*]
#  (Optional) Maximum total number of open connections to every memcached
#  server. Integer value
#  Defaults to $facts['os_service_default'].
#
# [*memcache_pool_socket_timeout*]
#  (Optional) Number of seconds a connection to memcached is held unused in the
#  pool before it is closed. Integer value
#  Defaults to $facts['os_service_default'].
#
# [*memcache_pool_unused_timeout*]
#  (Optional) Number of seconds a connection to memcached is held unused in the
#  pool before it is closed. Integer value
#  Defaults to $facts['os_service_default'].
#
# [*memcache_secret_key*]
#  (Optional, mandatory if memcache_security_strategy is defined) This string
#  is used for key derivation.
#  Defaults to $facts['os_service_default'].
#
# [*memcache_security_strategy*]
#  (Optional) If defined, indicate whether token data should be authenticated or
#  authenticated and encrypted. If MAC, token data is authenticated (with HMAC)
#  in the cache. If ENCRYPT, token data is encrypted and authenticated in the
#  cache. If the value is not one of these options or empty, auth_token will
#  raise an exception on initialization.
#  Defaults to $facts['os_service_default'].
#
# [*memcache_use_advanced_pool*]
#  (Optional)  Use the advanced (eventlet safe) memcached client pool. The
#  advanced pool will only work under python 2.x Boolean value
#  Defaults to $facts['os_service_default'].
#
# [*memcached_servers*]
#  (Optional) Optionally specify a list of memcached server(s) to use for
#  caching. If left undefined, tokens will instead be cached in-process.
#  Defaults to $facts['os_service_default'].
#
# [*region_name*]
#  (Optional) The region in which the identity server can be found.
#  Defaults to $facts['os_service_default'].
#
# [*token_cache_time*]
#  (Optional) In order to prevent excessive effort spent validating tokens,
#  the middleware caches previously-seen tokens for a configurable duration
#  (in seconds). Set to -1 to disable caching completely. Integer value
#  Defaults to $facts['os_service_default'].
#
# [*manage_memcache_package*]
#  (Optional) Whether to install the python-memcache package.
#  Defaults to false.
#
# [*service_token_roles*]
#  (Optional) A choice of roles that must be present in a service token.
#  Service tokens are allowed to request that an expired token
#  can be used and so this check should tightly control that
#  only actual services should be sending this token. Roles
#  here are applied as an ANY check so any role in this list
#  must be present. For backwards compatibility reasons this
#  currently only affects the allow_expired check. (list value)
#  Defaults to $facts['os_service_default'].
#
# [*service_token_roles_required*]
#  (optional) backwards compatibility to ensure that the service tokens are
#  compared against a list of possible roles for validity
#  true/false
#  Defaults to $facts['os_service_default'].
#
# [*service_type*]
#  (Optional) The name or type of the service as it appears in the service
#  catalog. This is used to validate tokens that have restricted access rules.
#  Defaults to $facts['os_service_default'].
#
# [*interface*]
#  (Optional) Interface to use for the Identity API endpoint. Valid values are
#  "public", "internal" or "admin".
#  Defaults to $facts['os_service_default'].
#
define keystone::resource::authtoken(
  $username,
  $password,
  $auth_url                        = 'http://127.0.0.1:5000',
  $project_name                    = $facts['os_service_default'],
  $user_domain_name                = $facts['os_service_default'],
  $project_domain_name             = $facts['os_service_default'],
  $system_scope                    = $facts['os_service_default'],
  $insecure                        = $facts['os_service_default'],
  $auth_section                    = $facts['os_service_default'],
  $auth_type                       = $facts['os_service_default'],
  $www_authenticate_uri            = $facts['os_service_default'],
  $auth_version                    = $facts['os_service_default'],
  $cache                           = $facts['os_service_default'],
  $cafile                          = $facts['os_service_default'],
  $certfile                        = $facts['os_service_default'],
  $collect_timing                  = $facts['os_service_default'],
  $delay_auth_decision             = $facts['os_service_default'],
  $enforce_token_bind              = $facts['os_service_default'],
  $http_connect_timeout            = $facts['os_service_default'],
  $http_request_max_retries        = $facts['os_service_default'],
  $include_service_catalog         = $facts['os_service_default'],
  $keyfile                         = $facts['os_service_default'],
  $memcache_pool_conn_get_timeout  = $facts['os_service_default'],
  $memcache_pool_dead_retry        = $facts['os_service_default'],
  $memcache_pool_maxsize           = $facts['os_service_default'],
  $memcache_pool_socket_timeout    = $facts['os_service_default'],
  $memcache_pool_unused_timeout    = $facts['os_service_default'],
  $memcache_secret_key             = $facts['os_service_default'],
  $memcache_security_strategy      = $facts['os_service_default'],
  $memcache_use_advanced_pool      = $facts['os_service_default'],
  $memcached_servers               = $facts['os_service_default'],
  $region_name                     = $facts['os_service_default'],
  $token_cache_time                = $facts['os_service_default'],
  Boolean $manage_memcache_package = false,
  $service_token_roles             = $facts['os_service_default'],
  $service_token_roles_required    = $facts['os_service_default'],
  $service_type                    = $facts['os_service_default'],
  $interface                       = $facts['os_service_default'],
) {

  include keystone::deps
  include keystone::params

  if !is_service_default($memcache_security_strategy) {
    if !(downcase($memcache_security_strategy) in ['none', 'mac', 'encrypt']){
      fail('memcache_security_strategy can be set only to None, MAC or ENCRYPT')
    }

    if downcase($memcache_security_strategy) != 'none' and is_service_default($memcache_secret_key) {
      fail('memcache_secret_key is required when memcache_security_strategy is not None')
    }
  }

  if !is_service_default($memcached_servers) and !empty($memcached_servers){
    $memcached_servers_array = $memcached_servers ? {
      String  => split($memcached_servers, ','),
      default => $memcached_servers
    }
    $memcached_servers_real = join(any2array(inet6_prefix($memcached_servers_array)), ',')

    if $manage_memcache_package {
      ensure_packages('python-memcache', {
        ensure => present,
        name   => $::keystone::params::python_memcache_package_name,
        tag    => ['openstack'],
      })
    }
  } else {
    $memcached_servers_real = $facts['os_service_default']
  }

  if is_service_default($system_scope) {
    $project_name_real        = $project_name
    $project_domain_name_real = $project_domain_name
  } else {
    # When system scope is used, project parameters should be removed otherwise
    # project scope is used.
    $project_name_real        = $facts['os_service_default']
    $project_domain_name_real = $facts['os_service_default']
  }

  $keystonemiddleware_options = {
    'keystone_authtoken/auth_section'                   => {'value' => $auth_section},
    'keystone_authtoken/www_authenticate_uri'           => {'value' => $www_authenticate_uri},
    'keystone_authtoken/auth_type'                      => {'value' => $auth_type},
    'keystone_authtoken/auth_version'                   => {'value' => $auth_version},
    'keystone_authtoken/cache'                          => {'value' => $cache},
    'keystone_authtoken/cafile'                         => {'value' => $cafile},
    'keystone_authtoken/certfile'                       => {'value' => $certfile},
    'keystone_authtoken/collect_timing'                 => {'value' => $collect_timing},
    'keystone_authtoken/delay_auth_decision'            => {'value' => $delay_auth_decision},
    'keystone_authtoken/enforce_token_bind'             => {'value' => $enforce_token_bind},
    'keystone_authtoken/http_connect_timeout'           => {'value' => $http_connect_timeout},
    'keystone_authtoken/http_request_max_retries'       => {'value' => $http_request_max_retries},
    'keystone_authtoken/include_service_catalog'        => {'value' => $include_service_catalog},
    'keystone_authtoken/keyfile'                        => {'value' => $keyfile},
    'keystone_authtoken/memcache_pool_conn_get_timeout' => {'value' => $memcache_pool_conn_get_timeout},
    'keystone_authtoken/memcache_pool_dead_retry'       => {'value' => $memcache_pool_dead_retry},
    'keystone_authtoken/memcache_pool_maxsize'          => {'value' => $memcache_pool_maxsize},
    'keystone_authtoken/memcache_pool_socket_timeout'   => {'value' => $memcache_pool_socket_timeout},
    'keystone_authtoken/memcache_pool_unused_timeout'   => {'value' => $memcache_pool_unused_timeout},
    'keystone_authtoken/memcache_secret_key'            => {'value' => $memcache_secret_key, 'secret' => true},
    'keystone_authtoken/memcache_security_strategy'     => {'value' => $memcache_security_strategy},
    'keystone_authtoken/memcache_use_advanced_pool'     => {'value' => $memcache_use_advanced_pool},
    'keystone_authtoken/memcached_servers'              => {'value' => $memcached_servers_real},
    'keystone_authtoken/region_name'                    => {'value' => $region_name},
    'keystone_authtoken/token_cache_time'               => {'value' => $token_cache_time},
    'keystone_authtoken/auth_url'                       => {'value' => $auth_url},
    'keystone_authtoken/username'                       => {'value' => $username},
    'keystone_authtoken/password'                       => {'value' => $password, 'secret' => true},
    'keystone_authtoken/user_domain_name'               => {'value' => $user_domain_name},
    'keystone_authtoken/project_name'                   => {'value' => $project_name_real},
    'keystone_authtoken/project_domain_name'            => {'value' => $project_domain_name_real},
    'keystone_authtoken/system_scope'                   => {'value' => $system_scope},
    'keystone_authtoken/insecure'                       => {'value' => $insecure},
    'keystone_authtoken/service_token_roles'            => {'value' => join(any2array($service_token_roles), ',')},
    'keystone_authtoken/service_token_roles_required'   => {'value' => $service_token_roles_required},
    'keystone_authtoken/service_type'                   => {'value' => $service_type},
    'keystone_authtoken/interface'                      => {'value' => $interface},
  }

  create_resources($name, $keystonemiddleware_options)
}
