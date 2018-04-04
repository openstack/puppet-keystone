#
# Copyright 2013 eNovance <licensing@enovance.com>
#
# Author: Francois Charlier <francois.charlier@enovance.com>
#
# == Class: keystone::wsgi::apache
#
# Serve keystone with apache mod_wsgi in place of keystone service
# When using this class you should disable your keystone service.
#
# == Parameters
#
# [*servername*]
#   (Optional) The servername for the virtualhost.
#   Defaults to $::fqdn
#
# [*servername_admin*]
#   (Optional) The servername for the admin virtualhost.
#   Defaults to $servername
#
# [*public_port*]
#   (Optional) The public port.
#   Defaults to 5000
#
# [*admin_port*]
#   (Optional) The admin port.
#   Defaults to 35357
#
# [*bind_host*]
#   (Optional) The host/ip address Apache will listen on.
#   Defaults to undef (listen on all ip addresses)
#
# [*admin_bind_host*]
#   (Optional) The host/ip address Apache will listen on for admin API connections.
#   Defaults to undef or bind_host if only that setting is used
#
# [*public_path*]
#   (Optional) The prefix for the public endpoint.
#   Defaults to '/'
#
# [*admin_path*]
#   (Optional) The prefix for the admin endpoint.
#   Defaults to '/'
#
# [*ssl*]
#   (Optional) Use SSL.
#   Defaults to true
#
# [*workers*]
#   (Optional) Number of WSGI workers to spawn.
#   Defaults to $::os_workers
#
# [*ssl_cert*]
#   (Optional) Path to SSL certificate
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_key*]
#   (Optional) Path to SSL key
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_cert_admin*]
#   (Optional) Path to SSL certificate for the admin endpoint.
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_key_admin*]
#   (Optional) Path to SSL key for the admin endpoint.
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_chain*]
#   (Optional) SSL chain.
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_ca*]
#   (Optional) Path to SSL certificate authority.
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_crl_path*]
#   (Optional) Path to SSL certificate revocation list.
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_crl*]
#   (Optional) SSL certificate revocation list name.
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_certs_dir*]
#   (Optional) apache::vhost ssl parameters.
#   Default to apache::vhost 'ssl_*' defaults
#
# [*priority*]
#   (Optional) The priority for the vhost.
#   Defaults to '10'
#
# [*threads*]
#   (Optional) The number of threads for the vhost.
#   Defaults to 1
#
# [*wsgi_application_group*]
#   (Optional) The application group of the WSGI script.
#   Defaults to '%{GLOBAL}'
#
# [*wsgi_pass_authorization*]
#   (Optional) Whether HTTP authorisation headers are passed through to a WSGI
#   script when the equivalent HTTP request headers are present.
#   Defaults to 'On'
#
# [*wsgi_admin_script_source*]
#   (Optional) Wsgi script source for the admin endpoint. If set to undef
#   $::keystone::params::keystone_wsgi_admin_script_path is used. This source
#   is copied to the apache cgi-bin path as keystone-admin.
#   Defaults to undef
#
# [*wsgi_public_script_source*]
#   (Optional) Wsgi script source for the public endpoint. If set to undef
#   $::keystone::params::keystone_wsgi_public_script_path is used. This source
#   is copied to the apache cgi-bin path as keystone-main.
#   Defaults to undef
#
# [*custom_wsgi_process_options_main*]
#   (Optional) gives you the oportunity to add custom process options or to
#   overwrite the default options for the WSGI main process.
#   For example to use a virtual python environment for the WSGI process
#   you could set it to:
#   { python-path => '/my/python/virtualenv' }
#   Defaults to {}
#
# [*custom_wsgi_process_options_admin*]
#   (Optional) gives you the oportunity to add custom process options or to
#   overwrite the default options for the WSGI admin process.
#   eg. to use a virtual python environment for the WSGI process
#   you could set it to:
#   { python-path => '/my/python/virtualenv' }
#   Defaults to {}
#
# [*access_log_file*]
#   (Optional) The log file name for the virtualhost.
#   Defaults to false
#
# [*access_log_pipe*]
#   (Optional) Specifies a pipe where Apache sends access logs for the virtualhost.
#   Defaults to false
#
# [*access_log_syslog*]
#   (Optional) Sends the virtualhost access log messages to syslog.
#   Defaults to false
#
# [*access_log_format*]
#   (Optional) The log format for the virtualhost.
#   Defaults to false
#
# [*error_log_file*]
#   (Optional) The error log file name for the virtualhost.
#   Defaults to undef
#
# [*error_log_pipe*]
#   (Optional) Specifies a pipe where Apache sends error logs for the virtualhost.
#   Defaults to undef
#
# [*error_log_syslog*]
#   (Optional) Sends the virtualhost error log messages to syslog.
#   Defaults to undef
#
# [*headers*]
#   (Optional) Headers for the vhost.
#   Defaults to undef
#
# [*vhost_custom_fragment*]
#   (Optional) Passes a string of custom configuration
#   directives to be placed at the end of the vhost configuration.
#   Defaults to undef
#
# [*wsgi_chunked_request*]
#   (Optional) apache::vhost wsgi_chunked_request parameter.
#   Defaults to undef
#
# DEPRECATED PARAMETERS
#
# [*wsgi_script_ensure*]
#   (Optional) File ensure parameter for wsgi scripts.
#   Defaults to undef
#
class keystone::wsgi::apache (
  $servername                        = $::fqdn,
  $servername_admin                  = undef,
  $public_port                       = 5000,
  $admin_port                        = 35357,
  $bind_host                         = undef,
  $admin_bind_host                   = undef,
  $public_path                       = '/',
  $admin_path                        = '/',
  $ssl                               = true,
  $workers                           = $::os_workers,
  $ssl_cert                          = undef,
  $ssl_key                           = undef,
  $ssl_cert_admin                    = undef,
  $ssl_key_admin                     = undef,
  $ssl_chain                         = undef,
  $ssl_ca                            = undef,
  $ssl_crl_path                      = undef,
  $ssl_crl                           = undef,
  $ssl_certs_dir                     = undef,
  $threads                           = 1,
  $priority                          = '10',
  $wsgi_application_group            = '%{GLOBAL}',
  $wsgi_pass_authorization           = 'On',
  $wsgi_chunked_request              = undef,
  $wsgi_admin_script_source          = $::keystone::params::keystone_wsgi_admin_script_path,
  $wsgi_public_script_source         = $::keystone::params::keystone_wsgi_public_script_path,
  $access_log_file                   = false,
  $access_log_pipe                   = false,
  $access_log_syslog                 = false,
  $access_log_format                 = false,
  $error_log_file                    = undef,
  $error_log_pipe                    = undef,
  $error_log_syslog                  = undef,
  $headers                           = undef,
  $vhost_custom_fragment             = undef,
  $custom_wsgi_process_options_main  = {},
  $custom_wsgi_process_options_admin = {},
  ## DEPRECATED PARAMETERS
  $wsgi_script_ensure                = undef,
) inherits ::keystone::params {

  include ::keystone::deps

  $servername_admin_real = pick_default($servername_admin, $servername)

  if $ssl {
    # Attempt to use the admin cert/key, else default to the public one.
    # Since it's possible that no cert/key were given, we allow this to be empty with pick_default
    $ssl_cert_admin_real = pick_default($ssl_cert_admin, $ssl_cert)
    $ssl_key_admin_real = pick_default($ssl_key_admin, $ssl_key)
  } else {
    $ssl_cert_admin_real = undef
    $ssl_key_admin_real = undef
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

  # Ensure there's no trailing '/' except if this is also the only character
  $public_path_real = regsubst($public_path, '(^/.*)/$', '\1')
  $admin_path_real = regsubst($admin_path, '(^/.*)/$', '\1')

  if $public_port == $admin_port and $public_path_real == $admin_path_real {
    fail('When using the same port for public and admin endpoints, public_path and admin_path should be different.')
  }

  file { $::keystone::params::keystone_wsgi_script_path:
    ensure  => directory,
    owner   => 'keystone',
    group   => 'keystone',
    mode    => '0755',
    require => Anchor['keystone::install::end'],
  }

  # TODO(tobasco): Delete this when wsgi_script_ensure is removed.
  if $wsgi_script_ensure {
    warning('wsgi_script_ensure has NO effect and is deprecated for removal')
  }

  if $public_port == $admin_port {
    $custom_wsgi_script_aliases = { $admin_path_real => "${::keystone::params::keystone_wsgi_script_path}/keystone-admin" }

    # NOTE(tobasco): Create this here since openstacklib::wsgi::apache only handles
    # the keystone-public file if running public and admin on the same port.
    file { 'keystone_wsgi_admin':
      ensure  => present,
      path    => "${::keystone::params::keystone_wsgi_script_path}/keystone-admin",
      owner   => 'keystone',
      group   => 'keystone',
      mode    => '0644',
      source  => $wsgi_admin_script_source,
      require => File[$::keystone::params::keystone_wsgi_script_path],
    }

    $apache_require = [
      File['keystone_wsgi_admin'],
    ]
  } else {
    $custom_wsgi_script_aliases = undef
    $apache_require = []
  }

  if $admin_bind_host {
    $real_admin_bind_host = $admin_bind_host
  } else {
    # backwards compat before we had admin_bind_host
    $real_admin_bind_host = $bind_host
  }

  ::openstacklib::wsgi::apache { 'keystone_wsgi_main':
    servername                  => $servername,
    bind_host                   => $bind_host,
    bind_port                   => $public_port,
    group                       => 'keystone',
    path                        => $public_path_real,
    workers                     => $workers,
    threads                     => $threads,
    user                        => 'keystone',
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
    wsgi_process_display_name   => 'keystone-main',
    wsgi_process_group          => 'keystone_main',
    wsgi_script_dir             => $::keystone::params::keystone_wsgi_script_path,
    wsgi_script_file            => 'keystone-public',
    wsgi_script_source          => $wsgi_public_script_source,
    wsgi_application_group      => $wsgi_application_group,
    wsgi_pass_authorization     => $wsgi_pass_authorization,
    wsgi_chunked_request        => $wsgi_chunked_request,
    headers                     => $headers,
    custom_wsgi_process_options => $custom_wsgi_process_options_main,
    custom_wsgi_script_aliases  => $custom_wsgi_script_aliases,
    vhost_custom_fragment       => $vhost_custom_fragment,
    access_log_file             => $access_log_file,
    access_log_pipe             => $access_log_pipe,
    access_log_syslog           => $access_log_syslog,
    access_log_format           => $access_log_format,
    error_log_file              => $error_log_file,
    error_log_pipe              => $error_log_pipe,
    error_log_syslog            => $error_log_syslog,
    require                     => $apache_require,
  }

  if $public_port != $admin_port {
    ::openstacklib::wsgi::apache { 'keystone_wsgi_admin':
      servername                  => $servername_admin_real,
      bind_host                   => $real_admin_bind_host,
      bind_port                   => $admin_port,
      group                       => 'keystone',
      path                        => $admin_path_real,
      workers                     => $workers,
      threads                     => $threads,
      user                        => 'keystone',
      priority                    => $priority,
      ssl                         => $ssl,
      ssl_cert                    => $ssl_cert_admin_real,
      ssl_key                     => $ssl_key_admin_real,
      ssl_chain                   => $ssl_chain,
      ssl_ca                      => $ssl_ca,
      ssl_crl_path                => $ssl_crl_path,
      ssl_crl                     => $ssl_crl,
      ssl_certs_dir               => $ssl_certs_dir,
      wsgi_daemon_process         => 'keystone_admin',
      wsgi_process_display_name   => 'keystone-admin',
      wsgi_process_group          => 'keystone_admin',
      wsgi_script_dir             => $::keystone::params::keystone_wsgi_script_path,
      wsgi_script_file            => 'keystone-admin',
      wsgi_script_source          => $wsgi_admin_script_source,
      wsgi_application_group      => $wsgi_application_group,
      wsgi_pass_authorization     => $wsgi_pass_authorization,
      custom_wsgi_process_options => $custom_wsgi_process_options_admin,
      vhost_custom_fragment       => $vhost_custom_fragment,
      wsgi_chunked_request        => $wsgi_chunked_request,
      headers                     => $headers,
      access_log_file             => $access_log_file,
      access_log_pipe             => $access_log_pipe,
      access_log_syslog           => $access_log_syslog,
      access_log_format           => $access_log_format,
      error_log_file              => $error_log_file,
      error_log_pipe              => $error_log_pipe,
      error_log_syslog            => $error_log_syslog,
    }
  }
}
