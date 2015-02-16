#
# Implements ldap configuration for keystone.
#
# == Dependencies
# == Examples
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#   Matt Fischer matt.fischer@twcable.com
#
# == Copyright
#
# Copyright 2012 Puppetlabs Inc, unless otherwise noted.
#
class keystone::ldap(
  $url                                 = undef,
  $user                                = undef,
  $password                            = undef,
  $suffix                              = undef,
  $query_scope                         = undef,
  $page_size                           = undef,
  $user_tree_dn                        = undef,
  $user_filter                         = undef,
  $user_objectclass                    = undef,
  $user_id_attribute                   = undef,
  $user_name_attribute                 = undef,
  $user_mail_attribute                 = undef,
  $user_enabled_attribute              = undef,
  $user_enabled_mask                   = undef,
  $user_enabled_default                = undef,
  $user_enabled_invert                 = undef,
  $user_attribute_ignore               = undef,
  $user_default_project_id_attribute   = undef,
  $user_allow_create                   = undef,
  $user_allow_update                   = undef,
  $user_allow_delete                   = undef,
  $user_pass_attribute                 = undef,
  $user_enabled_emulation              = undef,
  $user_enabled_emulation_dn           = undef,
  $user_additional_attribute_mapping   = undef,
  $tenant_tree_dn                      = undef,   #DEPRECATED
  $project_tree_dn                     = undef,
  $tenant_filter                       = undef,   #DEPRECATED
  $project_filter                      = undef,
  $tenant_objectclass                  = undef,   #DEPRECATED
  $project_objectclass                 = undef,
  $tenant_id_attribute                 = undef,   #DEPRECATED
  $project_id_attribute                = undef,
  $tenant_member_attribute             = undef,   #DEPRECATED
  $project_member_attribute            = undef,
  $tenant_desc_attribute               = undef,   #DEPRECATED
  $project_desc_attribute              = undef,
  $tenant_name_attribute               = undef,   #DEPRECATED
  $project_name_attribute              = undef,
  $tenant_enabled_attribute            = undef,   #DEPRECATED
  $project_enabled_attribute           = undef,
  $tenant_domain_id_attribute          = undef,   #DEPRECATED
  $project_domain_id_attribute         = undef,
  $tenant_attribute_ignore             = undef,   #DEPRECATED
  $project_attribute_ignore            = undef,
  $tenant_allow_create                 = undef,   #DEPRECATED
  $project_allow_create                = undef,
  $tenant_allow_update                 = undef,   #DEPRECATED
  $project_allow_update                = undef,
  $tenant_allow_delete                 = undef,   #DEPRECATED
  $project_allow_delete                = undef,
  $tenant_enabled_emulation            = undef,   #DEPRECATED
  $project_enabled_emulation           = undef,
  $tenant_enabled_emulation_dn         = undef,   #DEPRECATED
  $project_enabled_emulation_dn        = undef,
  $tenant_additional_attribute_mapping = undef,   #DEPRECATED
  $project_additional_attribute_mapping= undef,
  $role_tree_dn                        = undef,
  $role_filter                         = undef,
  $role_objectclass                    = undef,
  $role_id_attribute                   = undef,
  $role_name_attribute                 = undef,
  $role_member_attribute               = undef,
  $role_attribute_ignore               = undef,
  $role_allow_create                   = undef,
  $role_allow_update                   = undef,
  $role_allow_delete                   = undef,
  $role_additional_attribute_mapping   = undef,
  $group_tree_dn                       = undef,
  $group_filter                        = undef,
  $group_objectclass                   = undef,
  $group_id_attribute                  = undef,
  $group_name_attribute                = undef,
  $group_member_attribute              = undef,
  $group_desc_attribute                = undef,
  $group_attribute_ignore              = undef,
  $group_allow_create                  = undef,
  $group_allow_update                  = undef,
  $group_allow_delete                  = undef,
  $group_additional_attribute_mapping  = undef,
  $use_tls                             = undef,
  $tls_cacertdir                       = undef,
  $tls_cacertfile                      = undef,
  $tls_req_cert                        = undef,
  $identity_driver                     = undef,
  $assignment_driver                   = undef,
  $use_pool                            = false,
  $pool_size                           = 10,
  $pool_retry_max                      = 3,
  $pool_retry_delay                    = 0.1,
  $pool_connection_timeout             = -1,
  $pool_connection_lifetime            = 600,
  $use_auth_pool                       = false,
  $auth_pool_size                      = 100,
  $auth_pool_connection_lifetime       = 60,
) {

  # In Juno the term "tenant" was deprecated in the config in favor of "project"
  # Let's assume project_ is being used and warning otherwise. If both are set we will
  # fail, because having both set may cause unexpected results in Keystone.
  if ($tenant_tree_dn) {
    $project_tree_dn_real = $tenant_tree_dn
    warning ('tenant_tree_dn is deprecated in Juno. switch to project_tree_dn')
    if ($project_tree_dn) {
      fail ('tenant_tree_dn and project_tree_dn are both set. results may be unexpected')
    }
  }
  else {
    $project_tree_dn_real = $project_tree_dn
  }

  if ($tenant_filter) {
    $project_filter_real = $tenant_filter
    warning ('tenant_filter is deprecated in Juno. switch to project_filter')
    if ($project_filter) {
      fail ('tenant_filter and project_filter are both set. results may be unexpected')
    }
  }
  else {
    $project_filter_real = $project_filter
  }

  if ($tenant_objectclass) {
    $project_objectclass_real = $tenant_objectclass
    warning ('tenant_objectclass is deprecated in Juno. switch to project_objectclass')
    if ($project_objectclass) {
      fail ('tenant_objectclass and project_objectclass are both set. results may be unexpected')
    }
  }
  else {
    $project_objectclass_real = $project_objectclass
  }

  if ($tenant_id_attribute) {
    $project_id_attribute_real = $tenant_id_attribute
    warning ('tenant_id_attribute is deprecated in Juno. switch to project_id_attribute')
    if ($project_id_attribute) {
      fail ('tenant_id_attribute and project_id_attribute are both set. results may be unexpected')
    }
  }
  else {
    $project_id_attribute_real = $project_id_attribute
  }

  if ($tenant_member_attribute) {
    $project_member_attribute_real = $tenant_member_attribute
    warning ('tenant_member_attribute is deprecated in Juno. switch to project_member_attribute')
    if ($project_member_attribute) {
      fail ('tenant_member_attribute and project_member_attribute are both set. results may be unexpected')
    }
  }
  else {
    $project_member_attribute_real = $project_member_attribute
  }

  if ($tenant_desc_attribute) {
    $project_desc_attribute_real = $tenant_desc_attribute
    warning ('tenant_desc_attribute is deprecated in Juno. switch to project_desc_attribute')
    if ($project_desc_attribute) {
      fail ('tenant_desc_attribute and project_desc_attribute are both set. results may be unexpected')
    }
  }
  else {
    $project_desc_attribute_real = $project_desc_attribute
  }

  if ($tenant_name_attribute) {
    $project_name_attribute_real = $tenant_name_attribute
    warning ('tenant_name_attribute is deprecated in Juno. switch to project_name_attribute')
    if ($project_name_attribute) {
      fail ('tenant_name_attribute and project_name_attribute are both set. results may be unexpected')
    }
  }
  else {
    $project_name_attribute_real = $project_name_attribute
  }

  if ($tenant_enabled_attribute) {
    $project_enabled_attribute_real = $tenant_enabled_attribute
    warning ('tenant_enabled_attribute is deprecated in Juno. switch to project_enabled_attribute')
    if ($project_enabled_attribute) {
      fail ('tenant_enabled_attribute and project_enabled_attribute are both set. results may be unexpected')
    }
  }
  else {
    $project_enabled_attribute_real = $project_enabled_attribute
  }

  if ($tenant_attribute_ignore) {
    $project_attribute_ignore_real = $tenant_attribute_ignore
    warning ('tenant_attribute_ignore is deprecated in Juno. switch to project_attribute_ignore')
    if ($project_attribute_ignore) {
      fail ('tenant_attribute_ignore and project_attribute_ignore are both set. results may be unexpected')
    }
  }
  else {
    $project_attribute_ignore_real = $project_attribute_ignore
  }

  if ($tenant_domain_id_attribute) {
    $project_domain_id_attribute_real = $tenant_domain_id_attribute
    warning ('tenant_domain_id_attribute is deprecated in Juno. switch to project_domain_id_attribute')
    if ($project_domain_id_attribute) {
      fail ('tenant_domain_id_attribute and project_domain_id_attribute are both set. results may be unexpected')
    }
  }
  else {
    $project_domain_id_attribute_real = $project_domain_id_attribute
  }

  if ($tenant_allow_create) {
    $project_allow_create_real = $tenant_allow_create
    warning ('tenant_allow_create is deprecated in Juno. switch to project_allow_create')
    if ($project_allow_create) {
      fail ('tenant_allow_create and project_allow_create are both set. results may be unexpected')
    }
  }
  else {
    $project_allow_create_real = $project_allow_create
  }

  if ($tenant_allow_update) {
    $project_allow_update_real = $tenant_allow_update
    warning ('tenant_allow_update is deprecated in Juno. switch to project_allow_update')
    if ($project_allow_update) {
      fail ('tenant_allow_update and project_allow_update are both set. results may be unexpected')
    }
  }
  else {
    $project_allow_update_real = $project_allow_update
  }

  if ($tenant_allow_delete) {
    $project_allow_delete_real = $tenant_allow_delete
    warning ('tenant_allow_delete is deprecated in Juno. switch to project_allow_delete')
    if ($project_allow_delete) {
      fail ('tenant_allow_delete and project_allow_delete are both set. results may be unexpected')
    }
  }
  else {
    $project_allow_delete_real = $project_allow_delete
  }

  if ($tenant_enabled_emulation) {
    $project_enabled_emulation_real = $tenant_enabled_emulation
    warning ('tenant_enabled_emulation is deprecated in Juno. switch to project_enabled_emulation')
    if ($project_enabled_emulation) {
      fail ('tenant_enabled_emulation and project_enabled_emulation are both set. results may be unexpected')
    }
  }
  else {
    $project_enabled_emulation_real = $project_enabled_emulation
  }

  if ($tenant_enabled_emulation_dn) {
    $project_enabled_emulation_dn_real = $tenant_enabled_emulation_dn
    warning ('tenant_enabled_emulation_dn is deprecated in Juno. switch to project_enabled_emulation_dn')
    if ($project_enabled_emulation_dn) {
      fail ('tenant_enabled_emulation_dn and project_enabled_emulation_dn are both set. results may be unexpected')
    }
  }
  else {
    $project_enabled_emulation_dn_real = $project_enabled_emulation_dn
  }

  if ($tenant_additional_attribute_mapping) {
    $project_additional_attribute_mapping_real = $tenant_additional_attribute_mapping
    warning ('tenant_additional_attribute_mapping is deprecated in Juno. switch to project_additional_attribute_mapping')
    if ($project_additional_attribute_mapping) {
      fail ('tenant_additional_attribute_mapping and project_additional_attribute_mapping are both set. results may be unexpected')
    }
  }
  else {
    $project_additional_attribute_mapping_real = $project_additional_attribute_mapping
  }

  $ldap_packages = ['python-ldap', 'python-ldappool']
  package { $ldap_packages:
      ensure => present,
  }

  # check for some common driver name mistakes
  if ($assignment_driver != undef) {
      if ! ($assignment_driver =~ /^keystone.assignment.backends.*Assignment$/) {
          fail('assigment driver should be of the form \'keystone.assignment.backends.*Assignment\'')
      }
  }

  if ($identity_driver != undef) {
      if ! ($identity_driver =~ /^keystone.identity.backends.*Identity$/) {
          fail('identity driver should be of the form \'keystone.identity.backends.*Identity\'')
      }
  }

  if ($tls_cacertdir != undef) {
    file { $tls_cacertdir:
      ensure => directory
    }
  }

  keystone_config {
    'ldap/url':                                  value => $url;
    'ldap/user':                                 value => $user;
    'ldap/password':                             value => $password, secret => true;
    'ldap/suffix':                               value => $suffix;
    'ldap/query_scope':                          value => $query_scope;
    'ldap/page_size':                            value => $page_size;
    'ldap/user_tree_dn':                         value => $user_tree_dn;
    'ldap/user_filter':                          value => $user_filter;
    'ldap/user_objectclass':                     value => $user_objectclass;
    'ldap/user_id_attribute':                    value => $user_id_attribute;
    'ldap/user_name_attribute':                  value => $user_name_attribute;
    'ldap/user_mail_attribute':                  value => $user_mail_attribute;
    'ldap/user_enabled_attribute':               value => $user_enabled_attribute;
    'ldap/user_enabled_mask':                    value => $user_enabled_mask;
    'ldap/user_enabled_default':                 value => $user_enabled_default;
    'ldap/user_enabled_invert':                  value => $user_enabled_invert;
    'ldap/user_attribute_ignore':                value => $user_attribute_ignore;
    'ldap/user_default_project_id_attribute':    value => $user_default_project_id_attribute;
    'ldap/user_allow_create':                    value => $user_allow_create;
    'ldap/user_allow_update':                    value => $user_allow_update;
    'ldap/user_allow_delete':                    value => $user_allow_delete;
    'ldap/user_pass_attribute':                  value => $user_pass_attribute;
    'ldap/user_enabled_emulation':               value => $user_enabled_emulation;
    'ldap/user_enabled_emulation_dn':            value => $user_enabled_emulation_dn;
    'ldap/user_additional_attribute_mapping':    value => $user_additional_attribute_mapping;
    'ldap/project_tree_dn':                      value => $project_tree_dn_real;
    'ldap/project_filter':                       value => $project_filter_real;
    'ldap/project_objectclass':                  value => $project_objectclass_real;
    'ldap/project_id_attribute':                 value => $project_id_attribute_real;
    'ldap/project_member_attribute':             value => $project_member_attribute_real;
    'ldap/project_desc_attribute':               value => $project_desc_attribute_real;
    'ldap/project_name_attribute':               value => $project_name_attribute_real;
    'ldap/project_enabled_attribute':            value => $project_enabled_attribute_real;
    'ldap/project_attribute_ignore':             value => $project_attribute_ignore_real;
    'ldap/project_domain_id_attribute':          value => $project_domain_id_attribute_real;
    'ldap/project_allow_create':                 value => $project_allow_create_real;
    'ldap/project_allow_update':                 value => $project_allow_update_real;
    'ldap/project_allow_delete':                 value => $project_allow_delete_real;
    'ldap/project_enabled_emulation':            value => $project_enabled_emulation_real;
    'ldap/project_enabled_emulation_dn':         value => $project_enabled_emulation_dn_real;
    'ldap/project_additional_attribute_mapping': value => $project_additional_attribute_mapping_real;
    'ldap/role_tree_dn':                         value => $role_tree_dn;
    'ldap/role_filter':                          value => $role_filter;
    'ldap/role_objectclass':                     value => $role_objectclass;
    'ldap/role_id_attribute':                    value => $role_id_attribute;
    'ldap/role_name_attribute':                  value => $role_name_attribute;
    'ldap/role_member_attribute':                value => $role_member_attribute;
    'ldap/role_attribute_ignore':                value => $role_attribute_ignore;
    'ldap/role_allow_create':                    value => $role_allow_create;
    'ldap/role_allow_update':                    value => $role_allow_update;
    'ldap/role_allow_delete':                    value => $role_allow_delete;
    'ldap/role_additional_attribute_mapping':    value => $role_additional_attribute_mapping;
    'ldap/group_tree_dn':                        value => $group_tree_dn;
    'ldap/group_filter':                         value => $group_filter;
    'ldap/group_objectclass':                    value => $group_objectclass;
    'ldap/group_id_attribute':                   value => $group_id_attribute;
    'ldap/group_name_attribute':                 value => $group_name_attribute;
    'ldap/group_member_attribute':               value => $group_member_attribute;
    'ldap/group_desc_attribute':                 value => $group_desc_attribute;
    'ldap/group_attribute_ignore':               value => $group_attribute_ignore;
    'ldap/group_allow_create':                   value => $group_allow_create;
    'ldap/group_allow_update':                   value => $group_allow_update;
    'ldap/group_allow_delete':                   value => $group_allow_delete;
    'ldap/group_additional_attribute_mapping':   value => $group_additional_attribute_mapping;
    'ldap/use_tls':                              value => $use_tls;
    'ldap/tls_cacertdir':                        value => $tls_cacertdir;
    'ldap/tls_cacertfile':                       value => $tls_cacertfile;
    'ldap/tls_req_cert':                         value => $tls_req_cert;
    'ldap/use_pool':                             value => $use_pool;
    'ldap/pool_size':                            value => $pool_size;
    'ldap/pool_retry_max':                       value => $pool_retry_max;
    'ldap/pool_retry_delay':                     value => $pool_retry_delay;
    'ldap/pool_connection_timeout':              value => $pool_connection_timeout;
    'ldap/pool_connection_lifetime':             value => $pool_connection_lifetime;
    'ldap/use_auth_pool':                        value => $use_auth_pool;
    'ldap/auth_pool_size':                       value => $auth_pool_size;
    'ldap/auth_pool_connection_lifetime':        value => $auth_pool_connection_lifetime;
    'identity/driver':                           value => $identity_driver;
    'assignment/driver':                         value => $assignment_driver;
  }
}
