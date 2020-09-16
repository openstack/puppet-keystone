# == Class: keystone::endpoint
#
# DEPRECATED!
#
# Creates the auth endpoints for keystone
#
# === Parameters
#
# [*service_description*]
#   (optional) The service description for the keystone service.
#   Defaults to undef
#
# [*public_url*]
#   (optional) Public url for keystone endpoint.
#   Defaults to undef
#   This url should *not* contain any version or trailing '/'.
#
# [*internal_url*]
#   (optional) Internal url for keystone endpoint.
#   Defaults to undef
#   This url should *not* contain any version or trailing '/'.
#
# [*admin_url*]
#   (optional) Admin url for keystone endpoint.
#   Defaults to undef
#   This url should *not* contain any version or trailing '/'.
#
# [*region*]
#   (optional) Region for endpoint.
#   Defaults to undef
#
# [*user_domain*]
#   (Optional) Domain for $auth_name
#   Defaults to undef (use the keystone server default domain)
#
# [*project_domain*]
#   (Optional) Domain for $tenant (project)
#   Defaults to undef (use the keystone server default domain)
#
# [*default_domain*]
#   (Optional) Domain for $auth_name and $tenant (project)
#   If keystone_user_domain is not specified, use $keystone_default_domain
#   If keystone_project_domain is not specified, use $keystone_default_domain
#   Defaults to undef
#
# [*version*]
#   (optional) API version for endpoint.
#   Defaults to undef.
#
# === Examples
#
#  class { 'keystone::endpoint':
#    public_url   => 'https://154.10.10.23:5000',
#    internal_url => 'https://11.0.1.7:5000',
#    admin_url    => 'https://10.0.1.7:5000',
#  }
#
class keystone::endpoint (
  $service_description = undef,
  $public_url          = undef,
  $internal_url        = undef,
  $admin_url           = undef,
  $region              = undef,
  $user_domain         = undef,
  $project_domain      = undef,
  $default_domain      = undef,
  $version             = undef,
) {

  warning('The keystone::endpoint class has been replaced with keystone::bootstrap class\
    will try to use the backward compatible approach')

  if !defined('$::keystone::roles::admin::admin_tenant') {
    fail('You are using the backward compatible approach instead of keystone::bootstrap\
      you need to ensure that keystone::roles::admin is defined BEFORE keystone::endpoint in your manifest')
  }

  include keystone::bootstrap
}
