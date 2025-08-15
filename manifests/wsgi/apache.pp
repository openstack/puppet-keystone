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
#   Defaults to $facts['networking']['fqdn']
#
# [*bind_host*]
#   (Optional) The host/ip address Apache will listen on.
#   Defaults to undef (listen on all ip addresses)
#
# [*port*]
#   (Optional) The keystone Port.
#   Defaults to 5000
#
# [*path*]
#   (Optional) The prefix for the API endpoint.
#   Defaults to '/'
#
# [*ssl*]
#   (Optional) Use SSL.
#   Defaults to false
#
# [*workers*]
#   (Optional) Number of WSGI workers to spawn.
#   Defaults to $facts['os_workers_keystone']
#
# [*ssl_cert*]
#   (Optional) Path to SSL certificate
#   Default to apache::vhost 'ssl_*' defaults
#
# [*ssl_key*]
#   (Optional) Path to SSL key
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
#   Defaults to 10
#
# [*threads*]
#   (Optional) The number of threads for the vhost.
#   Defaults to 1
#
# [*wsgi_process_display_name*]
#   (Optional) Name of the WSGI process display-name.
#   Defaults to 'keystone'
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
# [*wsgi_script_source*]
#   (Optional) The wsgi script source for the API.
#   This source is copied to the apache cgi-bin path as keystone-public.
#   Defaults to '/usr/bin/keystone-wsgi-public'
#
# [*custom_wsgi_process_options*]
#   (Optional) gives you the opportunity to add custom process options or to
#   overwrite the default options for the WSGI process.
#   For example to use a virtual python environment for the WSGI process
#   you could set it to:
#   { python-path => '/my/python/virtualenv' }
#   Defaults to {}
#
# [*access_log_file*]
#   (Optional) The log file name for the virtualhost.
#   Defaults to undef
#
# [*access_log_pipe*]
#   (Optional) Specifies a pipe where Apache sends access logs for the virtualhost.
#   Defaults to undef
#
# [*access_log_syslog*]
#   (Optional) Sends the virtualhost access log messages to syslog.
#   Defaults to undef
#
# [*access_log_format*]
#   (Optional) The log format for the virtualhost.
#   Defaults to undef
#
# [*access_log_env_var*]
#   (Optional) Specifies that only requests with particular
#   environment variables be logged.
#   Defaults to undef
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
# [*request_headers*]
#   (optional) Modifies collected request headers in various ways.
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
class keystone::wsgi::apache (
  $servername                        = $facts['networking']['fqdn'],
  $bind_host                         = undef,
  $port                              = 5000,
  $path                              = '/',
  $ssl                               = false,
  $workers                           = $facts['os_workers_keystone'],
  $ssl_cert                          = undef,
  $ssl_key                           = undef,
  $ssl_chain                         = undef,
  $ssl_ca                            = undef,
  $ssl_crl_path                      = undef,
  $ssl_crl                           = undef,
  $ssl_certs_dir                     = undef,
  $wsgi_process_display_name         = 'keystone',
  $threads                           = 1,
  $priority                          = '10',
  $wsgi_application_group            = '%{GLOBAL}',
  $wsgi_pass_authorization           = 'On',
  $wsgi_chunked_request              = undef,
  $wsgi_script_source                = '/usr/bin/keystone-wsgi-public',
  $access_log_file                   = undef,
  $access_log_pipe                   = undef,
  $access_log_syslog                 = undef,
  $access_log_format                 = undef,
  $access_log_env_var                = undef,
  $error_log_file                    = undef,
  $error_log_pipe                    = undef,
  $error_log_syslog                  = undef,
  $headers                           = undef,
  $request_headers                   = undef,
  $vhost_custom_fragment             = undef,
  $custom_wsgi_process_options       = {},
) {

  include keystone::deps
  include keystone::params

  Anchor['keystone::install::end'] -> Class['apache']

  openstacklib::wsgi::apache { 'keystone_wsgi':
    servername                  => $servername,
    bind_host                   => $bind_host,
    bind_port                   => $port,
    group                       => $keystone::params::group,
    path                        => $path,
    workers                     => $workers,
    threads                     => $threads,
    user                        => $keystone::params::user,
    priority                    => $priority,
    ssl                         => $ssl,
    ssl_cert                    => $ssl_cert,
    ssl_key                     => $ssl_key,
    ssl_chain                   => $ssl_chain,
    ssl_ca                      => $ssl_ca,
    ssl_crl_path                => $ssl_crl_path,
    ssl_crl                     => $ssl_crl,
    ssl_certs_dir               => $ssl_certs_dir,
    wsgi_daemon_process         => 'keystone',
    wsgi_process_display_name   => $wsgi_process_display_name,
    wsgi_process_group          => 'keystone',
    wsgi_script_dir             => $keystone::params::keystone_wsgi_script_path,
    wsgi_script_file            => 'keystone',
    wsgi_script_source          => $wsgi_script_source,
    wsgi_application_group      => $wsgi_application_group,
    wsgi_pass_authorization     => $wsgi_pass_authorization,
    wsgi_chunked_request        => $wsgi_chunked_request,
    headers                     => $headers,
    request_headers             => $request_headers,
    custom_wsgi_process_options => $custom_wsgi_process_options,
    vhost_custom_fragment       => $vhost_custom_fragment,
    access_log_file             => $access_log_file,
    access_log_pipe             => $access_log_pipe,
    access_log_syslog           => $access_log_syslog,
    access_log_format           => $access_log_format,
    access_log_env_var          => $access_log_env_var,
    error_log_file              => $error_log_file,
    error_log_pipe              => $error_log_pipe,
    error_log_syslog            => $error_log_syslog,
  }

  # Workaround to empty Keystone vhost that is provided & activated by default with running
  # Canonical packaging (called 'keystone'). This will make sure upgrading the package is
  # possible, see https://bugs.launchpad.net/ubuntu/+source/keystone/+bug/1737697
  #
  # The file should be created after the apache class is invoked, otherwise
  # the file is deleted because of its default behavior which removes all files
  # in sites-available/sites-enabled.
  if ($facts['os']['name'] == 'Ubuntu') {
    ensure_resource('file', '/etc/apache2/sites-available/keystone.conf', {
      'ensure'  => 'file',
      'content' => '',
    })

    Anchor['keystone::install::end']
      -> File<| title == '/etc/apache2/sites-available/keystone.conf' |>

    File<| title == '/etc/apache2/sites-available' |>
      -> File<| title == '/etc/apache2/sites-available/keystone.conf' |>
      ~> Anchor['keystone::service::begin']
  }
}
