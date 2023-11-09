# == Class: keystone::federation::shibboleth
#
# == Parameters
#
# [*methods*]
#  A list of methods used for authentication separated by comma or an array.
#  The allowed values are: 'external', 'password', 'token', 'oauth1', 'saml2'
#  (Required) (string or array value).
#  Note: The external value should be dropped to avoid problems.
#
# [*suppress_warning*]
#  A boolean value to disable the warning about not installing shibboleth on RedHat.
#  (Optional) Defaults to false.
#
# [*template_order*]
#  This number indicates the order for the concat::fragment that will apply
#  the shibboleth configuration to Keystone VirtualHost. The value should
#  The value should be greater than 330 and less than 999, according to:
#  https://github.com/puppetlabs/puppetlabs-apache/blob/master/manifests/vhost.pp
#  The value 330 corresponds to the order for concat::fragment  "${name}-filters"
#  and "${name}-limits".
#  The value 999 corresponds to the order for concat::fragment "${name}-file_footer".
#  (Optional) Defaults to 331.
#
# [*yum_repo_name*]
#  This is the name of repo where one can find the shibboleth package on rhel
#  platform.  See the note below.  For instance this snippet would enable the
#  full configuration on RedHat platform:
#
#    yumrepo { 'shibboleth':
#      name     => 'Shibboleth',
#      baseurl  => 'http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/',
#      descr    => 'Shibboleth repo for RedHat',
#      gpgcheck => 1,
#      gpgkey   => 'http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/repodata/repomd.xml.key',
#      enabled  => 1,
#      require  => Anchor['openstack_extras_redhat']
#    }
#
# == Note about Redhat osfamily
#    According to puppet-apache we need to enable a new repo, but in puppet-openstack
#    we won't enable any external third party repo.
#    http://wiki.aaf.edu.au/tech-info/sp-install-guide.  We provide some helpers but
#    as the packaging is lacking official support, we cannot guaranty it will work.
#
class keystone::federation::shibboleth (
  $methods,
  Boolean $suppress_warning = false,
  $template_order           = 331,
  $yum_repo_name            = 'shibboleth',
) {

  include apache
  include keystone::deps

  # Note: if puppet-apache modify these values, this needs to be updated
  if $template_order <= 330 or $template_order >= 999 {
    fail('The template order should be greater than 330 and less than 999.')
  }

  if ('external' in $methods ) {
    fail("The external method should be dropped to avoid any interference with some \
Apache + Shibboleth SP setups, where a REMOTE_USER env variable is always set, even as an empty value.")
  }

  if !('saml2' in $methods ) {
    fail('Methods should contain saml2 as one of the auth methods.')
  }

  keystone_config {
    'auth/methods': value => join(any2array($methods),',');
  }

  case $facts['os']['family'] {
    'Debian': {
      include apache::mod::shib
      include apache::mod::authn_core

      concat::fragment { 'configure_shibboleth_keystone':
        target  => "${keystone::wsgi::apache::priority}-keystone_wsgi.conf",
        content => template('keystone/shibboleth.conf.erb'),
        order   => $template_order,
      }
    }
    'RedHat': {
      if defined(Yumrepo[$yum_repo_name]) or defined(Package['shibboleth']) {
        warning('The platform is not officially supported, use at your own risk.  Check manifest documentation for more.')
        apache::mod { 'shib2':
          id   => 'mod_shib',
          path => '/usr/lib64/shibboleth/mod_shib_24.so'
        }

        concat::fragment { 'configure_shibboleth_keystone':
          target  => "${keystone::wsgi::apache::priority}-keystone_wsgi.conf",
          content => template('keystone/shibboleth.conf.erb'),
          order   => $template_order,
        }
      } else {
        if !$suppress_warning {
          warning( 'Can not configure Shibboleth in Apache on RedHat OS. Read the Note on this federation/shibboleth.pp' )
        }
      }
    }
    default: {
      fail('Unsupported platform')
    }
  }
}
