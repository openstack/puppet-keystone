# == Class: keystone::config
#
# This class is used to manage arbitrary keystone configurations.
#
# === Parameters
#
# [*keystone_config*]
#   (optional) Allow configuration of arbitrary keystone configurations.
#   The value is an hash of keystone_config resources. Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   keystone_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
# [*keystone_paste_ini*]
#   (optional) Allow configuration of /etc/keystone/keystone-paste.ini options.
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class keystone::config (
  $keystone_config  = {},
  $keystone_paste_ini = {},
) {

  include ::keystone::deps

  validate_hash($keystone_config)
  validate_hash($keystone_paste_ini)

  create_resources('keystone_config', $keystone_config)
  create_resources('keystone_paste_ini', $keystone_paste_ini)
}
