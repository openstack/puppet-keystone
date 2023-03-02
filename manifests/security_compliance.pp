# == Class: keystone::security_compliance
#
# Security compliance features for keystone, specifically to satisfy
# Payment Card Industry - Data Security Standard (PCI-DSS) v3.1 requirements.
#
# === Parameters:
#
# [*change_password_upon_first_use*]
#   (Optional) Enabling this option requires users to change their password
#   when the user is created, or upon administrative reset. (Boolean value)
#   Defaults to $facts['os_service_default']
#
# [*disable_user_account_days_inactive*]
#   (Optional) The maximum number of days a user can go without authenticating 
#   before being considered "inactive" and automatically disabled (locked).
#   (Integer value)
#   Defaults to $facts['os_service_default']
#
# [*lockout_duration*]
#   (Optional) The number of seconds a user account will be locked when the
#   maximum number of failed authentication attempts (as specified by
#   `[security_compliance] lockout_failure_attempts`) is exceeded.
#   (Integer value)
#   Defaults to $facts['os_service_default']
#
# [*lockout_failure_attempts*]
#   (Optional) The maximum number of times that a user can fail to authenticate 
#   before the user account is locked for the number of seconds specified by
#   `[security_compliance] lockout_duration`. (Integer value)
#   Defaults to $facts['os_service_default']
#
# [*minimum_password_age*]
#   (Optional) The number of days that a password must be used before the user
#   can change it. This prevents users from changing their passwords immediately
#   in order to wipe out their password history and reuse an old password.
#   (Integer value)
#   Defaults to $facts['os_service_default']
#
# [*password_expires_days*]
#   (Optional) The number of days for which a password will be considered valid 
#   before requiring it to be changed. (Integer value)
#   Defaults to $facts['os_service_default']
#
# [*password_regex*]
#   (Optional) The regular expression used to validate password strength requirements.
#   By default, the regular expression will match any password. (String value)
#   Defaults to $facts['os_service_default']
#
# [*password_regex_description*]
#   (Optional) Describe your password regular expression here in language for humans.
#   (String value)
#   Defaults to $facts['os_service_default']
#
# [*unique_last_password_count*]
#   (Optional) This controls the number of previous user password iterations to keep
#   in history, in order to enforce that newly created passwords are unique.
#   (Integer value)
#   Defaults to $facts['os_service_default']
#
class keystone::security_compliance(
  $change_password_upon_first_use     = $facts['os_service_default'],
  $disable_user_account_days_inactive = $facts['os_service_default'],
  $lockout_duration                   = $facts['os_service_default'],
  $lockout_failure_attempts           = $facts['os_service_default'],
  $minimum_password_age               = $facts['os_service_default'],
  $password_expires_days              = $facts['os_service_default'],
  $password_regex                     = $facts['os_service_default'],
  $password_regex_description         = $facts['os_service_default'],
  $unique_last_password_count         = $facts['os_service_default'],
) {

  include keystone::deps

  keystone_config {
    'security_compliance/change_password_upon_first_use':     value => $change_password_upon_first_use;
    'security_compliance/disable_user_account_days_inactive': value => $disable_user_account_days_inactive;
    'security_compliance/lockout_duration':                   value => $lockout_duration;
    'security_compliance/lockout_failure_attempts':           value => $lockout_failure_attempts;
    'security_compliance/minimum_password_age':               value => $minimum_password_age;
    'security_compliance/password_expires_days':              value => $password_expires_days;
    'security_compliance/password_regex':                     value => $password_regex;
    'security_compliance/password_regex_description':         value => $password_regex_description;
    'security_compliance/unique_last_password_count':         value => $unique_last_password_count;
  }
}
