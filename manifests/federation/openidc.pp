# == class: keystone::federation::openidc [70/1473]
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
# [*openidc_provider_metadata_url*]
#  The url that points to your OpenID Connect metadata provider
#  (Required) String value.
#
# [*openidc_client_id*]
#  The client ID to use when handshaking with your OpenID Connect provider
#  (Required) String value.
#
# [*openidc_client_secret*]
#  The client secret to use when handshaking with your OpenID Connect provider
#  (Required) String value.
#
# [*openidc_crypto_passphrase*]
#  Secret passphrase to use when encrypting data for OpenID Connect handshake
#  (Optional) String value.
#  Defaults to 'openstack'
#
# [*admin_port*]
#  A boolean value to ensure that you want to configure openidc Federation
#  using Keystone VirtualHost on port 35357.
#  (Optional) Defaults to false.
#
# [*main_port*]
#  A boolean value to ensure that you want to configure openidc Federation
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
class keystone::federation::openidc (
  $methods,
  $idp_name,
  $openidc_provider_metadata_url,
  $openidc_client_id,
  $openidc_client_secret,
  $openidc_crypto_passphrase   = 'openstack',
  $admin_port                  = false,
  $main_port                   = true,
  $module_plugin               = 'keystone.auth.plugins.mapped.Mapped',
  $template_order              = 331,
  $package_ensure              = present,
) {

  include ::apache
  include ::keystone::deps
  include ::keystone::params

  # Note: if puppet-apache modify these values, this needs to be updated
  if $template_order <= 330 or $template_order >= 999 {
    fail('The template order should be greater than 330 and less than 999.')
  }

  if ('external' in $methods ) {
    fail('The external method should be dropped to avoid any interference with openidc')
  }

  if !('openidc' in $methods ) {
    fail('Methods should contain openidc as one of the auth methods.')
  } else {
    if ($module_plugin != 'keystone.auth.plugins.mapped.Mapped') {
      fail('Other plugins are not currently supported for openidc')
    }
  }

  validate_bool($admin_port)
  validate_bool($main_port)

  if( !$admin_port and !$main_port){
    fail('No VirtualHost port to configure, please choose at least one.')
  }

  keystone_config {
    'auth/methods': value => join(any2array($methods),',');
    'auth/openidc': value => $module_plugin;
  }

  ensure_packages([$::keystone::params::openidc_package_name], {
    ensure => $package_ensure,
    tag    => 'keystone-support-package',
  })

  if $admin_port {
    keystone::federation::openidc_httpd_configuration{ 'admin':
      port              => $::keystone::admin_port,
      keystone_endpoint => $::keystone::admin_endpoint,
    }
  }

  if $main_port {
    keystone::federation::openidc_httpd_configuration{ 'main':
      port              => $::keystone::public_port,
      keystone_endpoint => $::keystone::public_endpoint,
    }
  }

}
