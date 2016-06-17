# == Definition: keystone::resource::authtoken
#
# This resource configures Keystone authentication resources for an OpenStack
# service.  It will manage the [keystone_authtoken] section in the given
# config resource.  It supports all of the authentication parameters specified
# at http://www.jamielennox.net/blog/2015/02/17/loading-authentication-plugins/
# with the addition of the default domain for user and project.
#
# The username and project_name parameters may be given in the form
# "name::domainname".  The authtoken resource will use the domains in
# the following order:
# 1) The given domain parameter (user_domain_name or project_domain_name)
# 2) The domain given as the "::domainname" part of username or project_name
# 3) The default_domain_name
#
# For example, instead of doing this::
#
#     glance_api_config {
#       'keystone_authtoken/admin_tenant_name': value => $keystone_tenant;
#       'keystone_authtoken/admin_user'       : value => $keystone_user;
#       'keystone_authtoken/admin_password'   : value => $keystone_password;
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
#       default_domain_name => $keystone_default_domain,
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
#   (Required) The name of the resource corresponding to the config file.  For example,
#   keystone::resource::authtoken { 'glance_api_config': ... }
#   Where 'glance_api_config' is the name of the resource used to manage
#   the glance api configuration. string;
#
# [*username*]
#   (Required) The name of the service user; string;
#
# [*password*]
#   (Required) Password to create for the service user; string;
#
# [*auth_url*]
#   (Required) The URL to use for authentication. string;
#
# [*auth_plugin*]
#   (Optional) The plugin to use for authentication. string;
#   Defaults to 'password'
#
# [*user_id*]
#   (Optional) The ID of the service user;
#   string; Defaults to $::os_service_default
#
# [*user_domain_name*]
#   (Optional) Name of domain for $username
#   Defaults to $::os_service_default
#
# [*user_domain_id*]
#   (Optional) ID of domain for $username
#   Defaults to $::os_service_default
#
# [*project_name*]
#   (Optional) Service project name; string;
#   Defaults to $::os_service_default
#
# [*project_id*]
#   (Optional) Service project ID;
#   string; Defaults to $::os_service_default
#
# [*project_domain_name*]
#   (Optional) Name of domain for $project_name
#   Defaults to $::os_service_default
#
# [*project_domain_id*]
#   (Optional) ID of domain for $project_name
#   Defaults to $::os_service_default
#
# [*domain_name*]
#   (Optional) Use this for auth to obtain a domain-scoped token.
#   If using this option, do not specify $project_name or $project_id.
#   Defaults to $::os_service_default
#
# [*domain_id*]
#   (Optional) Use this for auth to obtain a domain-scoped token.
#   If using this option, do not specify $project_name or $project_id.
#   Defaults to $::os_service_default
#
# [*default_domain_name*]
#   (Optional) Name of domain for $username and $project_name
#   If user_domain_name is not specified, use $default_domain_name
#   If project_domain_name is not specified, use $default_domain_name
#   Defaults to $::os_service_default
#
# [*default_domain_id*]
#   (Optional) ID of domain for $user_id and $project_id
#   If user_domain_id is not specified, use $default_domain_id
#   If project_domain_id is not specified, use $default_domain_id
#   Defaults to $::os_service_default
#
# [*trust_id*]
#   (Optional) Trust ID
#   Defaults to $::os_service_default
#
# [*cacert*]
#   (Optional) CA certificate file for TLS (https)
#   Defaults to $::os_service_default
#
# [*cert*]
#   (Optional) Certificate file for TLS (https)
#   Defaults to $::os_service_default
#
# [*key*]
#   (Optional) Key file for TLS (https)
#   Defaults to $::os_service_default
#
# [*insecure*]
#   If true, explicitly allow TLS without checking server cert against any
#   certificate authorities.  WARNING: not recommended.  Use with caution.
#   boolean; Defaults to false (which means be secure)
#
define keystone::resource::authtoken(
  $username,
  $password,
  $auth_url,
  $auth_plugin         = 'password',
  $user_id             = $::os_service_default,
  $user_domain_name    = $::os_service_default,
  $user_domain_id      = $::os_service_default,
  $project_name        = $::os_service_default,
  $project_id          = $::os_service_default,
  $project_domain_name = $::os_service_default,
  $project_domain_id   = $::os_service_default,
  $domain_name         = $::os_service_default,
  $domain_id           = $::os_service_default,
  $default_domain_name = $::os_service_default,
  $default_domain_id   = $::os_service_default,
  $trust_id            = $::os_service_default,
  $cacert              = $::os_service_default,
  $cert                = $::os_service_default,
  $key                 = $::os_service_default,
  $insecure            = false,
) {

  include ::keystone::deps

  if is_service_default($project_name) and is_service_default($project_id) and
  is_service_default($domain_name) and is_service_default($domain_id) {
    fail('Must specify either a project (project_name or project_id, for a project scoped token) or a domain (domain_name or domain_id, for a domain scoped token)')
  }

  if ( !is_service_default($project_name) or !is_service_default($project_id) ) and
  ( !is_service_default($domain_name) or !is_service_default($domain_id) ) {
    fail('Cannot specify both a project (project_name or project_id) and a domain (domain_name or domain_id)')
  }

  $user_and_domain_array = split($username, '::')
  $real_username = $user_and_domain_array[0]

  if !is_service_default($user_domain_name) {
    $real_user_domain_name = pick($user_domain_name,$user_and_domain_array[1])
  } elsif !is_service_default($default_domain_name) {
    $real_user_domain_name = pick($user_and_domain_array[1], $default_domain_name)
  } else {
    $real_user_domain_name = pick($user_domain_name, $user_and_domain_array[1], $default_domain_name)
  }

  $project_and_domain_array = split($project_name, '::')
  $real_project_name = $project_and_domain_array[0]

  if !is_service_default($project_domain_name) {
    $real_project_domain_name = pick($project_domain_name, $project_and_domain_array[1])
  } elsif !is_service_default($default_domain_name) {
    $real_project_domain_name = pick($project_and_domain_array[1], $default_domain_name)
  } else {
    $real_project_domain_name = pick($project_domain_name, $project_and_domain_array[1], $default_domain_name)
  }

  $real_user_domain_id = pick($user_domain_id,$default_domain_id)
  $real_project_domain_id = pick($project_domain_id, $default_domain_id)

  $authtoken_options = {
    'keystone_authtoken/auth_plugin'         => {'value' => $auth_plugin },
    'keystone_authtoken/auth_url'            => {'value' => $auth_url },
    'keystone_authtoken/username'            => {'value' => $real_username },
    'keystone_authtoken/password'            => {'value' => $password, 'secret' => true },
    'keystone_authtoken/user_id'             => {'value' => $user_id },
    'keystone_authtoken/user_domain_name'    => {'value' => $real_user_domain_name },
    'keystone_authtoken/project_name'        => {'value' => $real_project_name },
    'keystone_authtoken/project_id'          => {'value' => $project_id },
    'keystone_authtoken/domain_name'         => {'value' => $domain_name },
    'keystone_authtoken/project_domain_name' => {'value' => $real_project_domain_name },
    'keystone_authtoken/domain_id'           => {'value' => $domain_id },
    'keystone_authtoken/trust_id'            => {'value' => $trust_id },
    'keystone_authtoken/cacert'              => {'value' => $cacert },
    'keystone_authtoken/cert'                => {'value' => $cert },
    'keystone_authtoken/key'                 => {'value' => $key },
    'keystone_authtoken/insecure'            => {'value' => $insecure },
    'keystone_authtoken/user_domain_id'      => {'value' => $real_user_domain_id },
    'keystone_authtoken/project_domain_id'   => {'value' => $real_project_domain_id },
  }

  create_resources($name, $authtoken_options)

}
