#
# Class to serve keystone with apache mod_wsgi in place of keystone service
#
# Serving keystone from apache is the recommended way to go for production
# systems as the current keystone implementation is not multi-processor aware,
# thus limiting the performance for concurrent accesses.
#
# See the following URIs for reference:
#    https://etherpad.openstack.org/havana-keystone-performance
#    http://adam.younglogic.com/2012/03/keystone-should-move-to-apache-httpd/
#
# When using this class you should disable your keystone service.
#
# == Parameters
#
#   [*servername*]
#     The servername for the virtualhost.
#     Optional. Defaults to $::fqdn
#
#   [*public_port*]
#     The public port.
#     Optional. Defaults to 5000
#
#   [*admin_port*]
#     The admin port.
#     Optional. Defaults to 35357
#
#   [*bind_host*]
#     The host/ip address Apache will listen on.
#     Optional. Defaults to undef (listen on all ip addresses).
#
#   [*admin_bind_host*]
#     The host/ip address Apache will listen on for admin API connections.
#     Optional. Defaults to undef or bind_host if only that setting is used.
#
#   [*public_path*]
#     The prefix for the public endpoint.
#     Optional. Defaults to '/'
#
#   [*admin_path*]
#     The prefix for the admin endpoint.
#     Optional. Defaults to '/'
#
#   [*ssl*]
#     Use ssl ? (boolean)
#     Optional. Defaults to true
#
#   [*workers*]
#     Number of WSGI workers to spawn.
#     Optional. Defaults to 1
#
#   [*ssl_cert*]
#     (optional) Path to SSL certificate
#     Default to apache::vhost 'ssl_*' defaults.
#
#   [*ssl_key*]
#     (optional) Path to SSL key
#     Default to apache::vhost 'ssl_*' defaults.
#
#   [*ssl_chain*]
#     (optional) SSL chain
#     Default to apache::vhost 'ssl_*' defaults.
#
#   [*ssl_ca*]
#     (optional) Path to SSL certificate authority
#     Default to apache::vhost 'ssl_*' defaults.
#
#   [*ssl_crl_path*]
#     (optional) Path to SSL certificate revocation list
#     Default to apache::vhost 'ssl_*' defaults.
#
#   [*ssl_crl*]
#     (optional) SSL certificate revocation list name
#     Default to apache::vhost 'ssl_*' defaults.
#
#   [*ssl_certs_dir*]
#     apache::vhost ssl parameters.
#     Optional. Default to apache::vhost 'ssl_*' defaults.
#
#   [*priority*]
#     (optional) The priority for the vhost.
#     Defaults to '10'
#
#   [*threads*]
#     (optional) The number of threads for the vhost.
#     Defaults to $::processorcount
#
#   [*wsgi_application_group*]
#     (optional) The application group of the WSGI script.
#     Defaults to '%{GLOBAL}'
#
#   [*wsgi_pass_authorization*]
#     (optional) Whether HTTP authorisation headers are passed through to a WSGI
#     script when the equivalent HTTP request headers are present.
#     Defaults to 'On'
#
#   [*wsgi_script_ensure*]
#     (optional) File ensure parameter for wsgi scripts.
#     Defaults to undef.
#
#   [*wsgi_admin_script_source*]
#     (optional) Wsgi script source for the admin endpoint. If set to undef
#     $::keystone::params::keystone_wsgi_admin_script_path is used. This source
#     is copied to the apache cgi-bin path as keystone-admin.
#     Defaults to undef.
#
#   [*wsgi_public_script_source*]
#     (optional) Wsgi script source for the public endpoint. If set to undef
#     $::keystone::params::keystone_wsgi_public_script_path is used. This source
#     is copied to the apache cgi-bin path as keystone-admin.
#     Defaults to undef.
#
#   [*access_log_format*]
#     The log format for the virtualhost.
#     Optional. Defaults to false.
#
#   [*headers*]
#     (optional) Headers for the vhost.
#     Defaults to undef.
#
#   [*vhost_custom_fragment*]
#     (optional) Passes a string of custom configuration
#     directives to be placed at the end of the vhost configuration.
#     Defaults to undef.
#
#   [*wsgi_chunked_request*]
#     (optional) apache::vhost wsgi_chunked_request parameter.
#     Defaults to undef
#
#  DEPRECATED OPTIONS
#
#   [*wsgi_script_source*]
#     (optional) Wsgi script source.
#     Defaults to undef.
#
# == Dependencies
#
#   requires Class['apache'] & Class['keystone']
#
# == Examples
#
#   include apache
#
#   class { 'keystone::wsgi::apache': }
#
# == Note about ports & paths
#
#   When using same port for both endpoints (443 anyone ?), you *MUST* use two
#  different public_path & admin_path !
#
# == Authors
#
#   Francois Charlier <francois.charlier@enovance.com>
#
# == Copyright
#
#   Copyright 2013 eNovance <licensing@enovance.com>
#
class keystone::wsgi::apache (
  $servername                = $::fqdn,
  $public_port               = 5000,
  $admin_port                = 35357,
  $bind_host                 = undef,
  $admin_bind_host           = undef,
  $public_path               = '/',
  $admin_path                = '/',
  $ssl                       = true,
  $workers                   = 1,
  $ssl_cert                  = undef,
  $ssl_key                   = undef,
  $ssl_chain                 = undef,
  $ssl_ca                    = undef,
  $ssl_crl_path              = undef,
  $ssl_crl                   = undef,
  $ssl_certs_dir             = undef,
  $threads                   = $::processorcount,
  $priority                  = '10',
  $wsgi_application_group    = '%{GLOBAL}',
  $wsgi_pass_authorization   = 'On',
  $wsgi_chunked_request      = undef,
  $wsgi_admin_script_source  = undef,
  $wsgi_public_script_source = undef,
  $wsgi_script_ensure        = undef,
  $access_log_format         = false,
  $headers                   = undef,
  $vhost_custom_fragment     = undef,
  #DEPRECATED
  $wsgi_script_source        = undef,
) {

  include ::keystone::deps
  include ::keystone::params
  include ::apache
  include ::apache::mod::wsgi
  if $ssl {
    include ::apache::mod::ssl
  }

  # The httpd package is untagged, but needs to have ordering enforced,
  # so handle it here rather than in the deps class.
  Anchor['keystone::install::begin']
  -> Package['httpd']
  -> Anchor['keystone::install::end']

  # Configure apache during the config phase
  Anchor['keystone::config::begin']
  -> Apache::Vhost<||>
  ~> Anchor['keystone::config::end']

  # Start the service during the service phase
  Anchor['keystone::service::begin']
  -> Service['httpd']
  -> Anchor['keystone::service::end']

  # Notify the service when config changes
  Anchor['keystone::config::end']
  ~> Service['httpd']

  ## Sanitize parameters

  # Ensure there's no trailing '/' except if this is also the only character
  $public_path_real = regsubst($public_path, '(^/.*)/$', '\1')
  # Ensure there's no trailing '/' except if this is also the only character
  $admin_path_real = regsubst($admin_path, '(^/.*)/$', '\1')

  if $public_port == $admin_port and $public_path_real == $admin_path_real {
    fail('When using the same port for public & private endpoints, public_path and admin_path should be different.')
  }

  file { $::keystone::params::keystone_wsgi_script_path:
    ensure  => directory,
    owner   => 'keystone',
    group   => 'keystone',
    require => Anchor['keystone::install::end'],
  }


  $wsgi_file_target = $wsgi_script_ensure ? {
    'link'  => 'target',
    default => 'source'
  }

  $wsgi_file_defaults = {
    'ensure'  => $wsgi_script_ensure,
    'owner'   => 'keystone',
    'group'   => 'keystone',
    'mode'    => '0644',
    'require' => File[$::keystone::params::keystone_wsgi_script_path],
  }

  if $wsgi_script_source {
    warning('The single wsgi script source has been deprecated as part of the Mitaka cycle, please switch to $wsgi_admin_script_source and $wsgi_public_script_source')
    $wsgi_admin_source = $wsgi_script_source
    $wsgi_public_source = $wsgi_script_source
  } else {
    $wsgi_admin_source = $::keystone::params::keystone_wsgi_admin_script_path
    $wsgi_public_source = $::keystone::params::keystone_wsgi_public_script_path
  }

  $wsgi_files = {
    'keystone_wsgi_admin' => {
      'path'                => "${::keystone::params::keystone_wsgi_script_path}/keystone-admin",
      "${wsgi_file_target}" => $wsgi_admin_source,
    },
    'keystone_wsgi_main'  => {
      'path'                => "${::keystone::params::keystone_wsgi_script_path}/keystone-public",
      "${wsgi_file_target}" => $wsgi_public_source,
    },
  }

  create_resources('file', $wsgi_files, $wsgi_file_defaults)

  $wsgi_daemon_process_options_main = {
    user         => 'keystone',
    group        => 'keystone',
    processes    => $workers,
    threads      => $threads,
    display-name => 'keystone-main',
  }

  $wsgi_daemon_process_options_admin = {
    user         => 'keystone',
    group        => 'keystone',
    processes    => $workers,
    threads      => $threads,
    display-name => 'keystone-admin',
  }

  $wsgi_script_aliases_main = hash([$public_path_real,"${::keystone::params::keystone_wsgi_script_path}/keystone-public"])
  $wsgi_script_aliases_admin = hash([$admin_path_real, "${::keystone::params::keystone_wsgi_script_path}/keystone-admin"])

  if $public_port == $admin_port {
    $wsgi_script_aliases_main_real = merge($wsgi_script_aliases_main, $wsgi_script_aliases_admin)
  } else {
    $wsgi_script_aliases_main_real = $wsgi_script_aliases_main
  }

  if $admin_bind_host {
    $real_admin_bind_host = $admin_bind_host
  } else {
    # backwards compat before we had admin_bind_host
    $real_admin_bind_host = $bind_host
  }

  ::apache::vhost { 'keystone_wsgi_main':
    ensure                      => 'present',
    servername                  => $servername,
    ip                          => $bind_host,
    port                        => $public_port,
    docroot                     => $::keystone::params::keystone_wsgi_script_path,
    docroot_owner               => 'keystone',
    docroot_group               => 'keystone',
    priority                    => $priority,
    ssl                         => $ssl,
    ssl_cert                    => $ssl_cert,
    ssl_key                     => $ssl_key,
    ssl_chain                   => $ssl_chain,
    ssl_ca                      => $ssl_ca,
    ssl_crl_path                => $ssl_crl_path,
    ssl_crl                     => $ssl_crl,
    ssl_certs_dir               => $ssl_certs_dir,
    wsgi_daemon_process         => 'keystone_main',
    wsgi_daemon_process_options => $wsgi_daemon_process_options_main,
    wsgi_process_group          => 'keystone_main',
    wsgi_script_aliases         => $wsgi_script_aliases_main_real,
    wsgi_application_group      => $wsgi_application_group,
    wsgi_pass_authorization     => $wsgi_pass_authorization,
    headers                     => $headers,
    custom_fragment             => $vhost_custom_fragment,
    wsgi_chunked_request        => $wsgi_chunked_request,
    require                     => File['keystone_wsgi_main'],
    access_log_format           => $access_log_format,
  }

  if $public_port != $admin_port {
    ::apache::vhost { 'keystone_wsgi_admin':
      ensure                      => 'present',
      servername                  => $servername,
      ip                          => $real_admin_bind_host,
      port                        => $admin_port,
      docroot                     => $::keystone::params::keystone_wsgi_script_path,
      docroot_owner               => 'keystone',
      docroot_group               => 'keystone',
      priority                    => $priority,
      ssl                         => $ssl,
      ssl_cert                    => $ssl_cert,
      ssl_key                     => $ssl_key,
      ssl_chain                   => $ssl_chain,
      ssl_ca                      => $ssl_ca,
      ssl_crl_path                => $ssl_crl_path,
      ssl_crl                     => $ssl_crl,
      ssl_certs_dir               => $ssl_certs_dir,
      wsgi_daemon_process         => 'keystone_admin',
      wsgi_daemon_process_options => $wsgi_daemon_process_options_admin,
      wsgi_process_group          => 'keystone_admin',
      wsgi_script_aliases         => $wsgi_script_aliases_admin,
      wsgi_application_group      => $wsgi_application_group,
      wsgi_pass_authorization     => $wsgi_pass_authorization,
      headers                     => $headers,
      custom_fragment             => $vhost_custom_fragment,
      wsgi_chunked_request        => $wsgi_chunked_request,
      require                     => File['keystone_wsgi_admin'],
      access_log_format           => $access_log_format,
    }
  }
}
