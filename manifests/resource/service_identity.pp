#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Definition: keystone::resource::service_identity
#
# This resource configures Keystone resources for an OpenStack service.
#
# == Parameters:
#
# [*ensure*]
#   Ensure parameter for the types used in resource.
#   string; optional: default to 'present'
#
# [*password*]
#   Password to create for the service user;
#   string; optional;
#
# [*auth_name*]
#   The name of the service user;
#   string; optional; default to the $title of the resource, i.e. 'nova'
#
# [*service_name*]
#   Name of the service;
#   string; optional;
#
# [*service_type*]
#   Type of the service;
#   string; optional;
#
# [*service_description*]
#   Description of the service;
#   string; optional: default to '$name service'
#
# [*public_url*]
#   Public endpoint URL;
#   string; optional;
#
# [*internal_url*]
#   Internal endpoint URL;
#   string; optional;
#
# [*admin_url*]
#   Admin endpoint URL;
#   string; optional;
#
# [*region*]
#   Endpoint region;
#   string; optional: default to 'RegionOne'
#
# [*tenant*]
#   Service tenant;
#   string; optional: default to 'services'
#
# [*roles*]
#   List of roles;
#   array of strings; optional: default to ['admin']
#
# [*system_scope*]
#   Scope for system operations
#   string; optional: default to 'all'
#
# [*system_roles*]
#   List of system roles;
#   array of strings; optional: default to []
#
# [*email*]
#   Service email;
#   string; optional: default to '$auth_name@localhost'
#
# [*configure_endpoint*]
#   Whether to create the endpoint.
#   boolean; optional: default to True
#
# [*configure_user*]
#   Whether to create the user.
#   boolean; optional: default to True
#
# [*configure_user_role*]
#   Whether to create the user role.
#   boolean; optional: default to True
#
# [*configure_service*]
#   Whether to create the service.
#   boolean; optional: default to True
#
# [*default_domain*]
#   (Optional) Domain for $auth_name and $tenant (project)
#   Defaults to undef
#
# [*user_domain*]
#   (Optional) Domain for $auth_name.
#   Defaults to undef (use the keystone server default domain)
#
# [*project_domain*]
#   (Optional) Domain for $tenant (project)
#   Defaults to undef (use the keystone server default domain)
#
define keystone::resource::service_identity (
  Enum['present', 'absent'] $ensure                 = 'present',
  Optional[Keystone::EndpointUrl] $admin_url        = undef,
  Optional[Keystone::EndpointUrl] $internal_url     = undef,
  Optional[String[1]] $password                     = undef,
  Optional[Keystone::PublicEndpointUrl] $public_url = undef,
  String[1] $auth_name                              = $name,
  Optional[String[1]] $service_name                 = $auth_name,
  Optional[String[1]] $service_type                 = undef,
  Boolean $configure_endpoint                       = true,
  Boolean $configure_user                           = true,
  Boolean $configure_user_role                      = true,
  Boolean $configure_service                        = true,
  String $email                                     = "${name}@localhost",
  String[1] $region                                 = 'RegionOne',
  String $service_description                       = "${name} service",
  String[1] $tenant                                 = 'services',
  Array[String[1]] $roles                           = ['admin'],
  String[1] $system_scope                           = 'all',
  Array[String[1]] $system_roles                    = [],
  Optional[String[1]] $default_domain               = undef,
  Optional[String[1]] $user_domain                  = $default_domain,
  Optional[String[1]] $project_domain               = $default_domain,
) {
  include keystone::deps

  $user_domain_real = $user_domain ? {
    undef   => $default_domain,
    default => $user_domain,
  }
  $project_domain_real = $project_domain ? {
    undef   => $default_domain,
    default => $project_domain,
  }

  if $configure_user {
    ['password', 'auth_name', 'email'].each |String $userprop| {
      if getvar($userprop) == undef {
        fail("The ${userprop} parameter is required to configure a user.")
      }
    }

    if $user_domain_real {
      # We have to use ensure_resource here and hope for the best, because we have
      # no way to know if the $user_domain is the same domain passed as the
      # $default_domain parameter to class keystone.
      ensure_resource('keystone_domain', $user_domain_real, {
        'ensure'  => $ensure,
        'enabled' => true,
      })
    }

    ensure_resource('keystone_user', $auth_name, {
      'ensure'   => $ensure,
      'enabled'  => true,
      'password' => $password,
      'email'    => $email,
      'domain'   => $user_domain_real,
    })
  }

  if $configure_user_role {
    if $ensure == 'present' {
      # NOTE(jaosorior): We only handle ensure 'present' here, since deleting a
      # role might be conflicting in some cases. e.g. the deployer removing a
      # role from one service but adding it to another in the same puppet run.
      # So role deletion should be handled elsewhere.
      ensure_resource('keystone_role', $roles, { 'ensure' => 'present' })
      ensure_resource('keystone_role', $system_roles, { 'ensure' => 'present' })
    }

    unless empty($roles) {
      ensure_resource('keystone_user_role', "${auth_name}@${tenant}", {
        'ensure'         => $ensure,
        'roles'          => $roles,
        'user_domain'    => $user_domain_real,
        'project_domain' => $project_domain_real,
      })
    }
    unless empty($system_roles) {
      ensure_resource('keystone_user_role', "${auth_name}@::::${system_scope}", {
        'ensure'      => $ensure,
        'roles'       => $system_roles,
        'user_domain' => $user_domain_real,
      })
    }
  }

  if $configure_service {
    if ! $service_type {
      fail('The service_type parameter is required to configure a service.')
    }

    ensure_resource('keystone_service', "${service_name}::${service_type}", {
      'ensure'      => $ensure,
      'description' => $service_description,
    })
  }

  if $configure_endpoint {
    if ! $service_type {
      fail('The service_type parameter is required to configure a service.')
    }
    if ! $public_url {
      fail('The public_url parameter is required to configure endpoints.')
    }
    ensure_resource('keystone_endpoint', "${region}/${service_name}::${service_type}", {
      'ensure'       => $ensure,
      'public_url'   => $public_url,
      'admin_url'    => $admin_url,
      'internal_url' => $internal_url,
    })
  }
}
