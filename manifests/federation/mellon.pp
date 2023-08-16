# == Class: keystone::federation::mellon
#
# == Parameters
#
# [*methods*]
#  A list of methods used for authentication separated by comma or an array.
#  The allowed values are: 'external', 'password', 'token', 'oauth1', 'saml2',
#  and 'openid'
#  (Required) (string or array value).
#  Note: The external value should be dropped to avoid problems.
#
# [*idp_name*]
#  The name name associated with the IdP in Keystone.
#  (Required) String value.
#
# [*protocol_name*]
#  The name for your protocol associated with the IdP.
#  (Required) String value.
#
# [*template_order*]
#  This number indicates the order for the concat::fragment that will apply
#  the shibboleth configuration to Keystone VirtualHost. The value should
#  The value should be greater than 330 an less then 999, according to:
#  https://github.com/puppetlabs/puppetlabs-apache/blob/master/manifests/vhost.pp
#  The value 330 corresponds to the order for concat::fragment  "${name}-filters"
#  and "${name}-limits".
#  The value 999 corresponds to the order for concat::fragment "${name}-file_footer".
#  (Optional) Defaults to 331.
#
# [*enable_websso*]
#   (optional) Whether or not to enable Web Single Sign-On (SSO)
#   Defaults to false
#
class keystone::federation::mellon (
  $methods,
  $idp_name,
  $protocol_name,
  $template_order        = 331,
  Boolean $enable_websso = false,
) {

  include apache
  include apache::mod::auth_mellon
  include keystone::deps
  include keystone::params

  # Note: if puppet-apache modify these values, this needs to be updated
  if $template_order <= 330 or $template_order >= 999 {
    fail('The template order should be greater than 330 and less than 999.')
  }

  if ('external' in $methods ) {
    fail("The external method should be dropped to avoid any interference with some \
Apache + Mellon SP setups, where a REMOTE_USER env variable is always set, even as an empty value.")
  }

  if !('saml2' in $methods ) {
    fail('Methods should contain saml2 as one of the auth methods.')
  }

  keystone_config {
    'auth/methods': value => join(any2array($methods),',');
  }

  if($enable_websso){
    keystone_config {
      'mapped/remote_id_attribute': value => 'MELLON_IDP';
    }
  } else {
    keystone_config {
      'mapped/remote_id_attribute': ensure => absent;
    }
  }

  concat::fragment { 'configure_mellon_keystone':
    target  => "${keystone::wsgi::apache::priority}-keystone_wsgi.conf",
    content => template('keystone/mellon.conf.erb'),
    order   => $template_order,
  }

}
