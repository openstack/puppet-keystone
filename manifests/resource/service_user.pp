# == Definition: keystone::resource::service_user
#
# This resource configures Keystone authentication resources to make OpenStack
# services like nova or cinder use service token feature. It will manage the
# [service_user] section in the given config resource.
#
# == Parameters:
#
# [*name*]
#  (Required) The name of the resource corresponding to the config file.
#  For example, keystone::resource::service_user { 'nova_config': ... }
#  Where 'nova_config' is the name of the resource used to manage
#  the nova configuration.
#
# [*username*]
#  (Required) The name of the service user
#
# [*password*]
#  (Required) Password to create for the service user
#
# [*auth_url*]
#  (Optional) The URL to use for authentication.
#  Defaults to 'http://127.0.0.1:5000'
#
# [*project_name*]
#  (Optional) Service project name
#  Defaults to $facts['os_service_default']
#
# [*user_domain_name*]
#  (Optional) Name of domain for $username
#  Defaults to $facts['os_service_default']
#
# [*project_domain_name*]
#  (Optional) Name of domain for $project_name
#  Defaults to $facts['os_service_default']
#
# [*send_service_user_token*]
#  (Optional) The service uses service token feature when this is set as true
#  Defaults to $facts['os_service_default']
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
# [*auth_type*]
#  (Optional) Authentication type to load
#  Defaults to $facts['os_service_default']
#
# [*auth_version*]
#  (Optional) API version of the admin Identity API endpoint.
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
# [*keyfile*]
#  (Optional) Required if identity server requires client certificate
#  Defaults to $facts['os_service_default'].
#
# [*region_name*]
#  (Optional) The region in which the identity server can be found.
#  Defaults to $facts['os_service_default'].
#
define keystone::resource::service_user (
  $username,
  $password,
  $auth_url                = 'http://127.0.0.1:5000',
  $project_name            = $facts['os_service_default'],
  $user_domain_name        = $facts['os_service_default'],
  $project_domain_name     = $facts['os_service_default'],
  $system_scope            = $facts['os_service_default'],
  $send_service_user_token = $facts['os_service_default'],
  $insecure                = $facts['os_service_default'],
  $auth_type               = $facts['os_service_default'],
  $auth_version            = $facts['os_service_default'],
  $cafile                  = $facts['os_service_default'],
  $certfile                = $facts['os_service_default'],
  $keyfile                 = $facts['os_service_default'],
  $region_name             = $facts['os_service_default'],
) {
  if is_service_default($system_scope) {
    $project_name_real        = $project_name
    $project_domain_name_real = $project_domain_name
  } else {
    # When system scope is used, project parameters should be removed otherwise
    # project scope is used.
    $project_name_real        = $facts['os_service_default']
    $project_domain_name_real = $facts['os_service_default']
  }

  $service_user_options = {
    'service_user/auth_type'               => { 'value' => $auth_type },
    'service_user/auth_version'            => { 'value' => $auth_version },
    'service_user/cafile'                  => { 'value' => $cafile },
    'service_user/certfile'                => { 'value' => $certfile },
    'service_user/keyfile'                 => { 'value' => $keyfile },
    'service_user/region_name'             => { 'value' => $region_name },
    'service_user/auth_url'                => { 'value' => $auth_url },
    'service_user/username'                => { 'value' => $username },
    'service_user/password'                => { 'value' => $password, 'secret' => true },
    'service_user/user_domain_name'        => { 'value' => $user_domain_name },
    'service_user/project_name'            => { 'value' => $project_name_real },
    'service_user/project_domain_name'     => { 'value' => $project_domain_name_real },
    'service_user/system_scope'            => { 'value' => $system_scope },
    'service_user/send_service_user_token' => { 'value' => $send_service_user_token },
    'service_user/insecure'                => { 'value' => $insecure },
  }

  create_resources($name, $service_user_options)
}
