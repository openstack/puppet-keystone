# == class: keystone::federation::mellon
#
# == Parameters
#
# [*methods*]
#  A list of methods used for authentication separated by comma or an array.
#  The allowed values are: 'external', 'password', 'token', 'oauth1', 'saml2'
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
# [*admin_port*]
#  A boolean value to ensure that you want to configure K2K Federation
#  using Keystone VirtualHost on port 35357.
#  (Optional) Defaults to false.
#
# [*main_port*]
#  A boolean value to ensure that you want to configure K2K Federation
#  using Keystone VirtualHost on port 5000.
#  (Optional) Defaults to true.
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
# [*package_ensure*]
#   (optional) Desired ensure state of packages.
#   accepts latest or specific versions.
#   Defaults to present.
#
# [*enable_websso*]
#   (optional) Wheater or not to enable Web Single Sign-On (SSO)
#   Defaults to false
#
# [*trusted_dashboards*]
#   (optional) URL list of trusted horizon servers.
#   This setting ensures that keystone only sends token data back to trusted
#   servers. This is performed as a precaution, specifically to prevent man-in-
#   the-middle (MITM) attacks.
#   Defaults to undef
#
# === DEPRECATED
#
# [*module_plugin*]
#  The plugin for authentication acording to the choice made with protocol and
#  module.
#  (Optional) Defaults to 'keystone.auth.plugins.mapped.Mapped' (string value)
#
class keystone::federation::mellon (
  $methods,
  $idp_name,
  $protocol_name,
  $admin_port         = false,
  $main_port          = true,
  $template_order     = 331,
  $package_ensure     = present,
  $enable_websso      = false,
  $trusted_dashboards = undef,
  # DEPRECATED
  $module_plugin      = undef,
) {

  include ::apache
  include ::keystone::deps
  include ::keystone::params

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

  validate_bool($admin_port)
  validate_bool($main_port)
  validate_bool($enable_websso)

  if( !$admin_port and !$main_port){
    fail('No VirtualHost port to configure, please choose at least one.')
  }

  keystone_config {
    'auth/methods': value  => join(any2array($methods),',');
    'auth/saml2':   ensure => absent;
  }

  if($enable_websso){
    if( !trusted_dashboards){
      fail('No trusted dashboard specified, please add at least one.')
    }
    keystone_config {
      'mapped/remote_id_attribute': value => 'MELLON_IDP';
      'federation/trusted_dashboard': value => join(any2array($trusted_dashboards),',');
    }
  }

  ensure_packages([$::keystone::params::mellon_package_name], {
    ensure => $package_ensure,
    tag    => 'keystone-support-package',
  })

  if $admin_port {
    concat::fragment { 'configure_mellon_on_port_35357':
      target  => "${keystone::wsgi::apache::priority}-keystone_wsgi_admin.conf",
      content => template('keystone/mellon.conf.erb'),
      order   => $template_order,
    }
  }

  if $main_port {
    concat::fragment { 'configure_mellon_on_port_5000':
      target  => "${keystone::wsgi::apache::priority}-keystone_wsgi_main.conf",
      content => template('keystone/mellon.conf.erb'),
      order   => $template_order,
    }
  }

}
