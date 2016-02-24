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
# [*module_plugin*]
#  The plugin for authentication acording to the choice made with protocol and
#  module.
#  (Optional) Defaults to 'keystone.auth.plugins.mapped.Mapped' (string value)
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
class keystone::federation::mellon (
  $methods,
  $idp_name,
  $protocol_name,
  $admin_port     = false,
  $main_port      = true,
  $module_plugin  = 'keystone.auth.plugins.mapped.Mapped',
  $template_order = 331,
  $package_ensure = present,
) {

  include ::apache
  include ::keystone::deps
  include ::keystone::params

  # Note: if puppet-apache modify these values, this needs to be updated
  if $template_order <= 330 or $template_order >= 999 {
    fail('The template order should be greater than 330 and less than 999.')
  }

  if ('external' in $methods ) {
    fail('The external method should be dropped to avoid any interference with some Apache + Mellon SP setups, where a REMOTE_USER env variable is always set, even as an empty value.')
  }

  if !('saml2' in $methods ) {
    fail('Methods should contain saml2 as one of the auth methods.')
  }else{
    if ($module_plugin != 'keystone.auth.plugins.mapped.Mapped') {
      fail('The plugin for saml and mellon should be keystone.auth.plugins.mapped.Mapped')
    }
  }

  validate_bool($admin_port)
  validate_bool($main_port)

  if( !$admin_port and !$main_port){
    fail('No VirtualHost port to configure, please choose at least one.')
  }

  keystone_config {
    'auth/methods': value => join(any2array($methods),',');
    'auth/saml2':   value => $module_plugin;
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
