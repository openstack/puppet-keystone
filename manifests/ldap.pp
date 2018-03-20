# == class: keystone::ldap
#
# Implements ldap configuration for keystone.
#
# === parameters:
#
# [*url*]
#   URL for connecting to the LDAP server. (string value)
#   Defaults to 'undef'
#
# [*user*]
#   User BindDN to query the LDAP server. (string value)
#   Defaults to 'undef'
#
# [*password*]
#   Password for the BindDN to query the LDAP server. (string value)
#   Defaults to 'undef'
#
# [*suffix*]
#   LDAP server suffix (string value)
#   Defaults to 'undef'
#
# [*query_scope*]
#   The LDAP scope for queries, this can be either "one"
#   (onelevel/singleLevel) or "sub" (subtree/wholeSubtree). (string value)
#   Defaults to 'undef'
#
# [*page_size*]
#   Maximum results per page; a value of zero ("0") disables paging. (integer value)
#   Defaults to 'undef'
#
# [*user_tree_dn*]
#   Search base for users. (string value)
#   Defaults to 'undef'
#
# [*user_filter*]
#   LDAP search filter for users. (string value)
#   Defaults to 'undef'
#
# [*user_objectclass*]
#   LDAP objectclass for users. (string value)
#   Defaults to 'undef'
#
# [*user_id_attribute*]
#   LDAP attribute mapped to user id. WARNING: must not be a multivalued attribute. (string value)
#   Defaults to 'undef'
#
# [*user_name_attribute*]
#   LDAP attribute mapped to user name. (string value)
#   Defaults to 'undef'
#
# [*user_description_attribute*]
#   LDAP attribute mapped to user description. (string value)
#   Defaults to 'undef'
#
# [*user_mail_attribute*]
#   LDAP attribute mapped to user email. (string value)
#
# [*user_enabled_attribute*]
#   LDAP attribute mapped to user enabled flag. (string value)
#   Defaults to 'undef'
#
# [*user_enabled_mask*]
#   Bitmask integer to indicate the bit that the enabled value is stored in if
#   the LDAP server represents "enabled" as a bit on an integer rather than a
#   boolean. A value of "0" indicates the mask is not used. If this is not set
#   to "0" the typical value is "2". This is typically used when
#   "user_enabled_attribute = userAccountControl". (integer value)
#   Defaults to 'undef'
#
# [*user_enabled_default*]
#   Default value to enable users. This should match an appropriate int value
#   if the LDAP server uses non-boolean (bitmask) values to indicate if a user
#   is enabled or disabled. If this is not set to "True" the typical value is
#   "512". This is typically used when "user_enabled_attribute =
#   userAccountControl". (string value)
#   Defaults to 'undef'
#
# [*user_enabled_invert*]
#   Invert the meaning of the boolean enabled values. Some LDAP servers use a
#   boolean lock attribute where "true" means an account is disabled. Setting
#   "user_enabled_invert = true" will allow these lock attributes to be used.
#   This setting will have no effect if "user_enabled_mask" or
#   "user_enabled_emulation" settings are in use. (boolean value)
#   Defaults to 'undef'
#
# [*user_attribute_ignore*]
#   List of attributes stripped off the user on update. (list value)
#   Defaults to 'undef'
#
# [*user_default_project_id_attribute*]
#   LDAP attribute mapped to default_project_id for users. (string value)
#   Defaults to 'undef'
#
# [*user_pass_attribute*]
#   LDAP attribute mapped to password. (string value)
#   Defaults to 'undef'
#
# [*user_enabled_emulation*]
#   If true, Keystone uses an alternative method to determine if
#   a user is enabled or not by checking if they are a member of
#   the "user_enabled_emulation_dn" group. (boolean value)
#   Defaults to 'undef'
#
# [*user_enabled_emulation_dn*]
#   DN of the group entry to hold enabled users when using enabled emulation.
#   (string value)
#   Defaults to 'undef'
#
# [*user_additional_attribute_mapping*]
#   List of additional LDAP attributes used for mapping
#   additional attribute mappings for users. Attribute mapping
#   format is <ldap_attr>:<user_attr>, where ldap_attr is the
#   attribute in the LDAP entry and user_attr is the Identity
#   API attribute. (list value)
#   Defaults to 'undef'
#
# [*project_tree_dn*]
#   Search base for projects (string value)
#   Defaults to 'undef'
#
# [*project_filter*]
#   LDAP search filter for projects. (string value)
#   Defaults to 'undef'
#
# [*project_objectclass*]
#   LDAP objectclass for projects. (string value)
#   Defaults to 'undef'
#
# [*project_id_attribute*]
#   LDAP attribute mapped to project id. (string value)
#   Defaults to 'undef'
#
# [*project_member_attribute*]
#   LDAP attribute mapped to project membership for user. (string value)
#   Defaults to 'undef'
#
# [*project_name_attribute*]
#   LDAP attribute mapped to project name. (string value)
#   Defaults to 'undef'
#
# [*project_desc_attribute*]
#   LDAP attribute mapped to project description. (string value)
#   Defaults to 'undef'
#
# [*project_enabled_attribute*]
#   LDAP attribute mapped to project enabled. (string value)
#   Defaults to 'undef'
#
# [*project_domain_id_attribute*]
#   LDAP attribute mapped to project domain_id. (string value)
#   Defaults to 'undef'
#
# [*project_attribute_ignore*]
#   List of attributes stripped off the project on update. (list value)
#   Defaults to 'undef'
#
# [*project_allow_create*]
#   Allow project creation in LDAP backend. (boolean value)
#   Defaults to 'undef'
#
# [*project_allow_update*]
#   Allow project update in LDAP backend. (boolean value)
#   Defaults to 'undef'
#
# [*project_allow_delete*]
#   Allow project deletion in LDAP backend. (boolean value)
#   Defaults to 'undef'
#
# [*project_enabled_emulation*]
#   If true, Keystone uses an alternative method to determine if
#   a project is enabled or not by checking if they are a member
#   of the "project_enabled_emulation_dn" group. (boolean value)
#   Defaults to 'undef'
#
# [*project_enabled_emulation_dn*]
#   DN of the group entry to hold enabled projects when using
#   enabled emulation. (string value)
#   Defaults to 'undef'
#
# [*project_additional_attribute_mapping*]
#   Additional attribute mappings for projects. Attribute
#   mapping format is <ldap_attr>:<user_attr>, where ldap_attr
#   is the attribute in the LDAP entry and user_attr is the
#   Identity API attribute. (list value)
#   Defaults to 'undef'
#
# [*role_tree_dn*]
#   Search base for roles. (string value)
#   Defaults to 'undef'
#
# [*role_filter*]
#   LDAP search filter for roles. (string value)
#   Defaults to 'undef'
#
# [*role_objectclass*]
#   LDAP objectclass for roles. (string value)
#   Defaults to 'undef'
#
# [*role_id_attribute*]
#   LDAP attribute mapped to role id. (string value)
#   Defaults to 'undef'
#
# [*role_name_attribute*]
#   LDAP attribute mapped to role name. (string value)
#   Defaults to 'undef'
#
# [*role_member_attribute*]
#   LDAP attribute mapped to role membership. (string value)
#   Defaults to 'undef'
#
# [*role_attribute_ignore*]
#   List of attributes stripped off the role on update. (list value)
#   Defaults to 'undef'
#
# [*role_allow_create*]
#   Allow role creation in LDAP backend. (boolean value)
#   Defaults to 'undef'
#
# [*role_allow_update*]
#   Allow role update in LDAP backend. (boolean value)
#   Defaults to 'undef'
#
# [*role_allow_delete*]
#   Allow role deletion in LDAP backend. (boolean value)
#   Defaults to 'undef'
#
# [*role_additional_attribute_mapping*]
#   Additional attribute mappings for roles. Attribute mapping
#   format is <ldap_attr>:<user_attr>, where ldap_attr is the
#   attribute in the LDAP entry and user_attr is the Identity
#   API attribute. (list value)
#   Defaults to 'undef'
#
# [*group_tree_dn*]
#   Search base for groups. (string value)
#   Defaults to 'undef'
#
# [*group_filter*]
#   LDAP search filter for groups. (string value)
#   Defaults to 'undef'
#
# [*group_objectclass*]
#   LDAP objectclass for groups. (string value)
#   Defaults to 'undef'
#
# [*group_id_attribute*]
#   LDAP attribute mapped to group id. (string value)
#   Defaults to 'undef'
#
# [*group_name_attribute*]
#   LDAP attribute mapped to group name. (string value)
#   Defaults to 'undef'
#
# [*group_member_attribute*]
#   LDAP attribute mapped to show group membership. (string value)
#   Defaults to 'undef'
#
# [*group_desc_attribute*]
#   LDAP attribute mapped to group description. (string value)
#   Defaults to 'undef'
#
# [*group_attribute_ignore*]
#   List of attributes stripped off the group on update. (list value)
#   Defaults to 'undef'
#
# [*group_additional_attribute_mapping*]
#   Additional attribute mappings for groups. Attribute mapping
#   format is <ldap_attr>:<user_attr>, where ldap_attr is the
#   attribute in the LDAP entry and user_attr is the Identity
#   API attribute. (list value)
#   Defaults to 'undef'
#
# [*chase_referrals*]
#   Whether or not to chase returned referrals. (boolean value)
#   Defaults to 'undef'
#
# [*use_tls*]
#   Enable TLS for communicating with LDAP servers. (boolean value)
#   Defaults to 'undef'
#
# [*tls_cacertfile*]
#   CA certificate file path for communicating with LDAP servers. (string value)
#   Defaults to 'undef'
#
# [*tls_cacertdir*]
#   CA certificate directory path for communicating with LDAP servers. (string value)
#   Defaults to 'undef'
#
# [*tls_req_cert*]
#   Valid options for tls_req_cert are demand, never, and allow. (string value)
#   Defaults to 'undef'
#
# [*identity_driver*]
#   Identity backend driver. (string value)
#   Defaults to 'undef'
#
# [*credential_driver*]
#   Credential backend driver. (string value)
#   Defaults to 'undef'
#
# [*assignment_driver*]
#   Assignment backend driver. (string value)
#   Defaults to 'undef'
#
# [*use_pool*]
#   Enable LDAP connection pooling. (boolean value)
#   Defaults to false
#
# [*pool_size*]
#   Connection pool size. (integer value)
#   Defaults to '10'
#
# [*pool_retry_max*]
#   Maximum count of reconnect trials. (integer value)
#   Defaults to '3'
#
# [*pool_retry_delay*]
#   Time span in seconds to wait between two reconnect trials. (floating point value)
#   Defaults to '0.1'
#
# [*pool_connection_timeout*]
#   Connector timeout in seconds. Value -1 indicates indefinite wait for response. (integer value)
#   Defaults to '-1'
#
# [*pool_connection_lifetime*]
#   Connection lifetime in seconds. (integer value)
#   Defaults to '600'
#
# [*use_auth_pool*]
#   Enable LDAP connection pooling for end user authentication.
#   If use_pool is disabled, then this setting is meaningless and is not used at all. (boolean value)
#   Defaults to false
#
# [*auth_pool_size*]
#   End user auth connection pool size. (integer value)
#   Defaults to '100'
#
# [*auth_pool_connection_lifetime*]
#   End user auth connection lifetime in seconds. (integer value)
#   Defaults to '60'
#
# [*package_ensure*]
#   (optional) Desired ensure state of packages.
#   accepts latest or specific versions.
#   Defaults to present.
#
# [*manage_packages*]
#   (optional) Whether or not this module should manage
#   LDAP support packages.
#   Defaults to true.
#
# == Dependencies
# == Examples
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#   Matt Fischer matt@mattfischer.com
#
# == Copyright
#
# Copyright 2012 Puppetlabs Inc, unless otherwise noted.
#
class keystone::ldap(
  $url                                  = undef,
  $user                                 = undef,
  $password                             = undef,
  $suffix                               = undef,
  $query_scope                          = undef,
  $page_size                            = undef,
  $user_tree_dn                         = undef,
  $user_filter                          = undef,
  $user_objectclass                     = undef,
  $user_id_attribute                    = undef,
  $user_name_attribute                  = undef,
  $user_description_attribute           = undef,
  $user_mail_attribute                  = undef,
  $user_enabled_attribute               = undef,
  $user_enabled_mask                    = undef,
  $user_enabled_default                 = undef,
  $user_enabled_invert                  = undef,
  $user_attribute_ignore                = undef,
  $user_default_project_id_attribute    = undef,
  $user_pass_attribute                  = undef,
  $user_enabled_emulation               = undef,
  $user_enabled_emulation_dn            = undef,
  $user_additional_attribute_mapping    = undef,
  $project_tree_dn                      = undef,
  $project_filter                       = undef,
  $project_objectclass                  = undef,
  $project_id_attribute                 = undef,
  $project_member_attribute             = undef,
  $project_desc_attribute               = undef,
  $project_name_attribute               = undef,
  $project_enabled_attribute            = undef,
  $project_domain_id_attribute          = undef,
  $project_attribute_ignore             = undef,
  $project_allow_create                 = undef,
  $project_allow_update                 = undef,
  $project_allow_delete                 = undef,
  $project_enabled_emulation            = undef,
  $project_enabled_emulation_dn         = undef,
  $project_additional_attribute_mapping = undef,
  $role_tree_dn                         = undef,
  $role_filter                          = undef,
  $role_objectclass                     = undef,
  $role_id_attribute                    = undef,
  $role_name_attribute                  = undef,
  $role_member_attribute                = undef,
  $role_attribute_ignore                = undef,
  $role_allow_create                    = undef,
  $role_allow_update                    = undef,
  $role_allow_delete                    = undef,
  $role_additional_attribute_mapping    = undef,
  $group_tree_dn                        = undef,
  $group_filter                         = undef,
  $group_objectclass                    = undef,
  $group_id_attribute                   = undef,
  $group_name_attribute                 = undef,
  $group_member_attribute               = undef,
  $group_desc_attribute                 = undef,
  $group_attribute_ignore               = undef,
  $group_additional_attribute_mapping   = undef,
  $chase_referrals                      = undef,
  $use_tls                              = undef,
  $tls_cacertdir                        = undef,
  $tls_cacertfile                       = undef,
  $tls_req_cert                         = undef,
  $identity_driver                      = undef,
  $assignment_driver                    = undef,
  $credential_driver                    = undef,
  $use_pool                             = false,
  $pool_size                            = 10,
  $pool_retry_max                       = 3,
  $pool_retry_delay                     = 0.1,
  $pool_connection_timeout              = -1,
  $pool_connection_lifetime             = 600,
  $use_auth_pool                        = false,
  $auth_pool_size                       = 100,
  $auth_pool_connection_lifetime        = 60,
  $package_ensure                       = present,
  $manage_packages                      = true,
) {

  include ::keystone::deps

  if $manage_packages {
    ensure_resource('package', 'python-ldappool', { ensure => $package_ensure,
      tag => 'keystone-package' })
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
    'ldap/user_description_attribute':           value => $user_description_attribute;
    'ldap/user_mail_attribute':                  value => $user_mail_attribute;
    'ldap/user_enabled_attribute':               value => $user_enabled_attribute;
    'ldap/user_enabled_mask':                    value => $user_enabled_mask;
    'ldap/user_enabled_default':                 value => $user_enabled_default;
    'ldap/user_enabled_invert':                  value => $user_enabled_invert;
    'ldap/user_attribute_ignore':                value => $user_attribute_ignore;
    'ldap/user_default_project_id_attribute':    value => $user_default_project_id_attribute;
    'ldap/user_pass_attribute':                  value => $user_pass_attribute;
    'ldap/user_enabled_emulation':               value => $user_enabled_emulation;
    'ldap/user_enabled_emulation_dn':            value => $user_enabled_emulation_dn;
    'ldap/user_additional_attribute_mapping':    value => $user_additional_attribute_mapping;
    'ldap/project_tree_dn':                      value => $project_tree_dn;
    'ldap/project_filter':                       value => $project_filter;
    'ldap/project_objectclass':                  value => $project_objectclass;
    'ldap/project_id_attribute':                 value => $project_id_attribute;
    'ldap/project_member_attribute':             value => $project_member_attribute;
    'ldap/project_desc_attribute':               value => $project_desc_attribute;
    'ldap/project_name_attribute':               value => $project_name_attribute;
    'ldap/project_enabled_attribute':            value => $project_enabled_attribute;
    'ldap/project_attribute_ignore':             value => $project_attribute_ignore;
    'ldap/project_domain_id_attribute':          value => $project_domain_id_attribute;
    'ldap/project_allow_create':                 value => $project_allow_create;
    'ldap/project_allow_update':                 value => $project_allow_update;
    'ldap/project_allow_delete':                 value => $project_allow_delete;
    'ldap/project_enabled_emulation':            value => $project_enabled_emulation;
    'ldap/project_enabled_emulation_dn':         value => $project_enabled_emulation_dn;
    'ldap/project_additional_attribute_mapping': value => $project_additional_attribute_mapping;
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
    'ldap/group_additional_attribute_mapping':   value => $group_additional_attribute_mapping;
    'ldap/chase_referrals':                      value => $chase_referrals;
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
    'credential/driver':                         value => $credential_driver;
    'assignment/driver':                         value => $assignment_driver;
  }
}
