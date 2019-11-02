# == Class: keystone::roles::admin
#
# DEPRECATED!
#
# This class implements some reasonable admin defaults for keystone.
#
# It creates the following keystone objects:
#   * service tenant (tenant used by all service users)
#   * "admin" tenant (defaults to "openstack")
#   * admin user (that defaults to the "admin" tenant)
#   * admin role
#   * adds admin role to admin user on the "admin" tenant
#
# === Parameters:
#
# [*password*]
#   The admin password. Required. In a later release
#   this will default to $keystone::admin_password.
#   Defaults to undef
#
# [*email*]
#   The email address for the admin. Optional.
#   Defaults to undef
#
# [*admin_roles*]
#   The list of the roles with admin privileges. Optional.
#   Defaults to undef
#
# [*admin_tenant*]
#   The name of the tenant to be used for admin privileges. Optional.
#   Defaults to openstack.
#
# [*service_tenant*]
#   The name of service keystone tenant. Optional.
#   Defaults to undef
#
# [*admin*]
#   Admin user. Optional.
#   Defaults to undef
#
# [*admin_tenant_desc*]
#   Optional. Description for admin tenant,
#   Defaults to undef
#
# [*service_tenant_desc*]
#   Optional. Description for admin tenant,
#   Defaults to undef
#
# [*configure_user*]
#   Optional. Should the admin user be created?
#   Defaults to undef
#
# [*configure_user_role*]
#   Optional. Should the admin role be configured for the admin user?
#   Defaults to undef
#
# [*admin_user_domain*]
#   Optional.  Domain of the admin user
#   Defaults to undef (undef will resolve to class keystone $default_domain)
#
# [*target_admin_domain*]
#   Optional.  Domain where the admin user will have the $admin_role
#   Defaults to undef (undef will not associate the $admin_role to any
#   domain, only project)
#
# [*admin_project_domain*]
#   Optional.  Domain of the admin tenant
#   Defaults to undef (undef will resolve to class keystone $default_domain)
#
# [*service_project_domain*]
#   Optional.  Domain for $service_tenant
#   Defaults to undef (undef will resolve to class keystone $default_domain)
#
# == Dependencies
# == Examples
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2012 Puppetlabs Inc, unless otherwise noted.
#
class keystone::roles::admin(
  $password               = undef,
  $email                  = undef,
  $admin                  = undef,
  $admin_tenant           = 'openstack',
  $admin_roles            = undef,
  $service_tenant         = undef,
  $admin_tenant_desc      = undef,
  $service_tenant_desc    = undef,
  $configure_user         = undef,
  $configure_user_role    = undef,
  $admin_user_domain      = undef,
  $admin_project_domain   = undef,
  $service_project_domain = undef,
  $target_admin_domain    = undef,
) {

  warning('The keystone::roles::admin class has been replaced with keystone::bootstrap class')
}
