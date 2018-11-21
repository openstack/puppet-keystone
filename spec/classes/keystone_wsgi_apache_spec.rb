require 'spec_helper'

describe 'keystone::wsgi::apache' do

  let :global_facts do
    {
      :os_workers     => 8,
      :concat_basedir => '/var/lib/puppet/concat',
      :fqdn           => 'some.host.tld'
    }
  end

  let :pre_condition do
    [
     'class { keystone: admin_token => "dummy", service_name => "httpd", enable_ssl => true }'
    ]
  end

  shared_examples_for 'apache serving keystone with mod_wsgi' do
    it { is_expected.to contain_service('httpd').with_name(platform_params[:httpd_service_name]) }
    it { is_expected.to contain_class('keystone::params') }
    it { is_expected.to contain_class('apache') }
    it { is_expected.to contain_class('apache::mod::wsgi') }
    it { is_expected.to contain_class('apache::mod::ssl') }
    it { is_expected.to contain_class('keystone::db::sync') }

    describe 'with default parameters' do

      it { is_expected.to contain_file("#{platform_params[:wsgi_script_path]}").with(
        :ensure  => 'directory',
        :owner   => 'keystone',
        :group   => 'keystone',
        :require => 'Anchor[keystone::install::end]',
      )}

      it { is_expected.to contain_file('keystone_wsgi_admin').with(
        :ensure  => 'file',
        :path    => "#{platform_params[:wsgi_script_path]}/keystone-admin",
        :source  => platform_params[:wsgi_admin_script_source],
        :owner   => 'keystone',
        :group   => 'keystone',
        :mode    => '0644',
        :require => "File[#{platform_params[:wsgi_script_path]}]",
      )}

      it { is_expected.to contain_file('keystone_wsgi_main').with(
        :ensure  => 'file',
        :path    => "#{platform_params[:wsgi_script_path]}/keystone-public",
        :source  => platform_params[:wsgi_public_script_source],
        :owner   => 'keystone',
        :group   => 'keystone',
        :mode    => '0644',
        :require => "File[#{platform_params[:wsgi_script_path]}]",
      )}

      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_main').with(
        :servername                  => 'some.host.tld',
        :bind_port                   => 35357,
        :group                       => 'keystone',
        :workers                     => facts[:os_workers],
        :threads                     => 1,
        :user                        => 'keystone',
        :priority                    => '10',
        :ssl                         => true,
        :wsgi_daemon_process         => 'keystone_main',
        :wsgi_process_display_name   => 'keystone-main',
        :wsgi_process_group          => 'keystone_main',
        :wsgi_application_group      => '%{GLOBAL}',
        :wsgi_script_dir             => platform_params[:wsgi_script_path],
        :wsgi_script_file            => 'keystone-public',
        :wsgi_pass_authorization     => 'On',
        :headers                     => nil,
        :custom_wsgi_process_options => {},
        :access_log_file             => false,
        :access_log_pipe             => false,
        :access_log_syslog           => false,
        :access_log_format           => false,
        :error_log_file              => nil,
        :error_log_pipe              => nil,
        :error_log_syslog            => nil,
        :require                     => 'File[keystone_wsgi_main]',
      )}

      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_admin').with(
        :servername                  => 'some.host.tld',
        :bind_port                   => 5000,
        :group                       => 'keystone',
        :workers                     => facts[:os_workers],
        :threads                     => 1,
        :user                        => 'keystone',
        :priority                    => '10',
        :ssl                         => true,
        :wsgi_daemon_process         => 'keystone_admin',
        :wsgi_process_display_name   => 'keystone-admin',
        :wsgi_process_group          => 'keystone_admin',
        :wsgi_application_group      => '%{GLOBAL}',
        :wsgi_script_dir             => platform_params[:wsgi_script_path],
        :wsgi_script_file            => 'keystone-admin',
        :wsgi_pass_authorization     => 'On',
        :headers                     => nil,
        :custom_wsgi_process_options => {},
        :access_log_file             => false,
        :access_log_pipe             => false,
        :access_log_syslog           => false,
        :access_log_format           => false,
        :error_log_file              => nil,
        :error_log_pipe              => nil,
        :error_log_syslog            => nil,
        :require                     => 'File[keystone_wsgi_admin]',
      )}

      it { is_expected.to contain_concat("#{platform_params[:httpd_ports_file]}") }
    end

    describe 'when overriding parameters using different ports' do
      let :params do
        {
          :servername            => 'dummy.host',
          :bind_host             => '10.42.51.1',
          :admin_bind_host       => '10.42.51.2',
          :public_port           => 12345,
          :admin_port            => 4142,
          :ssl                   => false,
          :workers               => 37,
          :vhost_custom_fragment => 'LimitRequestFieldSize 81900'
        }
      end

      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_main').with(
        :servername                  => 'dummy.host',
        :bind_host                   => '10.42.51.1',
        :bind_port                   => 12345,
        :user                        => 'keystone',
        :group                       => 'keystone',
        :workers                     => 37,
        :threads                     => 1,
        :priority                    => '10',
        :ssl                         => false,
        :wsgi_daemon_process         => 'keystone_main',
        :wsgi_process_display_name   => 'keystone-main',
        :wsgi_process_group          => 'keystone_main',
        :wsgi_application_group      => '%{GLOBAL}',
        :wsgi_script_dir             => platform_params[:wsgi_script_path],
        :wsgi_script_file            => 'keystone-public',
        :wsgi_pass_authorization     => 'On',
        :headers                     => nil,
        :custom_wsgi_process_options => {},
        :vhost_custom_fragment       => 'LimitRequestFieldSize 81900',
        :access_log_file             => false,
        :access_log_pipe             => false,
        :access_log_syslog           => false,
        :access_log_format           => false,
        :error_log_file              => nil,
        :error_log_pipe              => nil,
        :error_log_syslog            => nil,
        :require                     => 'File[keystone_wsgi_main]',
      )}

      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_admin').with(
        :servername                  => 'dummy.host',
        :bind_host                   => '10.42.51.1',
        :bind_port                   => 4142,
        :group                       => 'keystone',
        :workers                     => 37,
        :threads                     => 1,
        :user                        => 'keystone',
        :priority                    => '10',
        :ssl                         => false,
        :wsgi_daemon_process         => 'keystone_admin',
        :wsgi_process_display_name   => 'keystone-admin',
        :wsgi_process_group          => 'keystone_admin',
        :wsgi_application_group      => '%{GLOBAL}',
        :wsgi_script_dir             => platform_params[:wsgi_script_path],
        :wsgi_script_file            => 'keystone-admin',
        :wsgi_pass_authorization     => 'On',
        :headers                     => nil,
        :custom_wsgi_process_options => {},
        :vhost_custom_fragment       => 'LimitRequestFieldSize 81900',
        :access_log_file             => false,
        :access_log_pipe             => false,
        :access_log_syslog           => false,
        :access_log_format           => false,
        :error_log_file              => nil,
        :error_log_pipe              => nil,
        :error_log_syslog            => nil,
        :require                     => 'File[keystone_wsgi_admin]',
      )}

      it { is_expected.to contain_concat("#{platform_params[:httpd_ports_file]}") }
    end

    describe 'when admin_bind_host is not set default to bind_host' do
      let :params do
        {
          :servername            => 'dummy.host',
          :bind_host             => '10.42.51.1',
          :public_port           => 12345,
          :admin_port            => 4142,
          :ssl                   => false,
          :workers               => 37,
          :vhost_custom_fragment => 'LimitRequestFieldSize 81900'
        }
      end

      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_main').with(
        :servername            => 'dummy.host',
        :bind_host             => '10.42.51.1',
        :bind_port             => 12345,
        :ssl                   => false,
        :workers               => 37,
        :vhost_custom_fragment => 'LimitRequestFieldSize 81900'
      )}

      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_admin').with(
        :servername            => 'dummy.host',
        :bind_host             => '10.42.51.1',
        :bind_port             => 4142,
        :ssl                   => false,
        :workers               => 37,
        :vhost_custom_fragment => 'LimitRequestFieldSize 81900'
      )}

      it { is_expected.to contain_concat("#{platform_params[:httpd_ports_file]}") }
    end

    describe 'when servername_admin is overridden' do
      let :params do
        {
          :servername            => 'dummy1.host',
          :servername_admin      => 'dummy2.host',
        }
      end

      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_main').with(
        :servername => 'dummy1.host',
      )}

      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_admin').with(
        :servername => 'dummy2.host',
      )}

    end

    describe 'when wsgi_daemon_process_options are overridden' do
      let :params do
        {
          :custom_wsgi_process_options_main  => {
                  python_path => '/my/python/main/path',
          },
          :custom_wsgi_process_options_admin => {
                  python_path => '/my/python/admin/path',
          },
        }
      end

      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_main').with(
        :custom_wsgi_process_options => { 'python-path' => '/my/python/main/path' },
      )}

      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_admin').with(
        :custom_wsgi_process_options => { 'python-path' => '/my/python/admin/path' },
      )}

    end

    describe 'when overriding parameters using same port' do
      let :params do
        {
          :servername  => 'dummy.host',
          :public_port => 4242,
          :admin_port  => 4242,
          :public_path => '/main/endpoint/',
          :admin_path  => '/admin/endpoint/',
          :ssl         => true,
          :workers     => 37,
        }
      end

      it { is_expected.to_not contain_openstacklib__wsgi__apache('keystone_wsgi_admin') }

      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_main').with(
        :servername => 'dummy.host',
        :bind_port  => 4242,
        :user                        => 'keystone',
        :group                       => 'keystone',
        :workers                     => 37,
        :threads                     => 1,
        :priority                    => '10',
        :ssl                         => true,
        :wsgi_daemon_process         => 'keystone_main',
        :wsgi_process_display_name   => 'keystone-main',
        :wsgi_process_group          => 'keystone_main',
        :wsgi_application_group      => '%{GLOBAL}',
        :wsgi_script_dir             => platform_params[:wsgi_script_path],
        :wsgi_script_file            => 'keystone-public',
        :wsgi_pass_authorization     => 'On',
        :headers                     => nil,
        :custom_wsgi_process_options => {},
        :custom_wsgi_script_aliases  => { '/admin/endpoint' => "#{platform_parameters[:wsgi_script_path]}/keystone-admin" },
        :access_log_file             => false,
        :access_log_pipe             => false,
        :access_log_syslog           => false,
        :access_log_format           => false,
        :error_log_file              => nil,
        :error_log_pipe              => nil,
        :error_log_syslog            => nil,
        :require                     => 'File[keystone_wsgi_main]'
      )}
    end

    describe 'when overriding parameters using same port and same path' do
      let :params do
        {
          :servername  => 'dummy.host',
          :public_port => 4242,
          :admin_port  => 4242,
          :public_path => '/endpoint/',
          :admin_path  => '/endpoint/',
          :ssl         => true,
          :workers     => 37,
        }
      end

      it_raises 'a Puppet::Error', /When using the same port for public and admin endpoints, public_path and admin_path should be different\./
    end

    describe 'when overriding default apache logging' do
      let :params do
        {
          :servername        => 'dummy.host',
          :access_log_format => 'foo',
          :access_log_syslog => 'syslog:local0',
        }
      end
      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_main').with(
          :servername        => 'dummy.host',
          :access_log_format => 'foo',
          :access_log_syslog => 'syslog:local0',
         )}
    end

    describe 'when overriding parameters using symlink and custom file source' do
      let :params do
        {
          :wsgi_script_source => '/opt/keystone/httpd/keystone.py',
        }
      end

      it { is_expected.to contain_file('keystone_wsgi_admin').with(
        :ensure  => 'link',
        :path    => "#{platform_params[:wsgi_script_path]}/keystone-admin",
        :target  => '/opt/keystone/httpd/keystone.py',
        :owner   => 'keystone',
        :group   => 'keystone',
        :mode    => '0644',
        :require => "File[#{platform_params[:wsgi_script_path]}]",
      )}

      it { is_expected.to contain_file('keystone_wsgi_main').with(
        :ensure  => 'link',
        :path    => "#{platform_params[:wsgi_script_path]}/keystone-public",
        :target  => '/opt/keystone/httpd/keystone.py',
        :owner   => 'keystone',
        :group   => 'keystone',
        :mode    => '0644',
        :require => "File[#{platform_params[:wsgi_script_path]}]",
      )}
    end

    describe 'when setting ssl cert and key' do
      let :params do
        {
          :ssl_cert => 'some cert',
          :ssl_key  => 'some key',
        }
      end
      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_main').with(
          :ssl_cert => 'some cert',
          :ssl_key  => 'some key',
          )}
      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_admin').with(
          :ssl_cert => 'some cert',
          :ssl_key  => 'some key',
          )}
    end

    describe 'when setting different ssl cert and key for admin' do
      let :params do
        {
          :ssl_cert       => 'some cert',
          :ssl_key        => 'some key',
          :ssl_cert_admin => 'some cert admin',
          :ssl_key_admin  => 'some key admin',
        }
      end
      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_main').with(
          :ssl_cert => 'some cert',
          :ssl_key  => 'some key',
          )}
      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_admin').with(
          :ssl_cert => 'some cert admin',
          :ssl_key  => 'some key admin',
          )}
    end

    describe 'when overriding parameters using wsgi chunked request' do
      let :params do
        {
          :wsgi_chunked_request => 'On'
        }
      end

      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_main').with(
        :wsgi_chunked_request => 'On'
      )}
      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_admin').with(
        :wsgi_chunked_request => 'On'
      )}

    end

   describe 'when overriding parameters using additional headers' do
      let :params do
        {
          :headers => 'set X-Frame-Options "DENY"'
        }
      end

      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_main').with(
        :headers => 'set X-Frame-Options "DENY"'
      )}
      it { is_expected.to contain_openstacklib__wsgi__apache('keystone_wsgi_admin').with(
        :headers => 'set X-Frame-Options "DENY"'
      )}

    end

    describe 'when overriding script paths with link' do
      let :params do
        {
          :wsgi_file_target          => 'link',
          :wsgi_admin_script_source  => '/home/foo/admin-script',
          :wsgi_public_script_source => '/home/foo/public-script',
        }
      end

      it 'should contain correct files' do
        is_expected.to contain_file('keystone_wsgi_main').with(
          :path   => "#{facts[:wsgi_script_path]}/keystone-public",
          :target => params[:wsgi_public_script_source]
        )
        is_expected.to contain_file('keystone_wsgi_admin').with(
          :path   => "#{facts[:wsgi_script_path]}/keystone-admin",
          :target => params[:wsgi_admin_script_source]
        )
      end
    end

    describe 'when overriding script paths with source' do
      let :params do
        {
          :wsgi_admin_script_source  => '/home/foo/admin-script',
          :wsgi_public_script_source => '/home/foo/public-script',
        }
      end

      it 'should contain correct files' do
        is_expected.to contain_file('keystone_wsgi_main').with(
          :path   => "#{facts[:wsgi_script_path]}/keystone-public",
          :source => params[:wsgi_public_script_source]
        )
        is_expected.to contain_file('keystone_wsgi_admin').with(
          :path   => "#{facts[:wsgi_script_path]}/keystone-admin",
          :source => params[:wsgi_admin_script_source]
        )
      end
    end
  end

  on_supported_os({
  }).each do |os,facts|
    let (:facts) do
      facts.merge!(OSDefaults.get_facts({}))
    end

    let(:platform_params) do
      case facts[:osfamily]
      when 'Debian'
        {
          :httpd_service_name => 'apache2',
          :httpd_ports_file   => '/etc/apache2/ports.conf',
          :wsgi_script_path   => '/usr/lib/cgi-bin/keystone',
          :wsgi_admin_script_source => '/usr/bin/keystone-wsgi-admin',
          :wsgi_public_script_source => '/usr/bin/keystone-wsgi-public'
        }
      when 'RedHat'
        {
          :httpd_service_name => 'httpd',
          :httpd_ports_file   => '/etc/httpd/conf/ports.conf',
          :wsgi_script_path   => '/var/www/cgi-bin/keystone',
          :wsgi_admin_script_source => '/usr/bin/keystone-wsgi-admin',
          :wsgi_public_script_source => '/usr/bin/keystone-wsgi-public'
        }
      end
    end
  end
end
