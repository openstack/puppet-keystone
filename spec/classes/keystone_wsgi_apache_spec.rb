require 'spec_helper'

describe 'keystone::wsgi::apache' do

  let :pre_condition do
    "class { 'keystone':
       service_name => 'httpd',
     }"
  end

  shared_examples 'keystone::wsgi::apache' do
    context 'with default parameters' do
      it {
        should contain_class('keystone::params')
        should contain_class('keystone::deps')
      }

      it { should contain_openstacklib__wsgi__apache('keystone_wsgi').with(
        :servername                  => 'some.host.tld',
        :bind_host                   => nil,
        :bind_port                   => 5000,
        :group                       => 'keystone',
        :workers                     => facts[:os_workers_keystone],
        :threads                     => 1,
        :user                        => 'keystone',
        :priority                    => '10',
        :ssl                         => false,
        :wsgi_daemon_process         => 'keystone',
        :wsgi_process_display_name   => 'keystone',
        :wsgi_process_group          => 'keystone',
        :wsgi_application_group      => '%{GLOBAL}',
        :wsgi_script_dir             => platform_params[:wsgi_script_path],
        :wsgi_script_file            => 'keystone',
        :wsgi_script_source          => '/usr/bin/keystone-wsgi-public',
        :wsgi_pass_authorization     => 'On',
        :headers                     => nil,
        :request_headers             => nil,
        :custom_wsgi_process_options => {},
        :access_log_file             => false,
        :access_log_pipe             => false,
        :access_log_syslog           => false,
        :access_log_format           => false,
        :error_log_file              => nil,
        :error_log_pipe              => nil,
        :error_log_syslog            => nil,
      )}
    end

    context 'when overriding parameters' do
      let :params do
        {
          :servername                  => 'dummy.host',
          :bind_host                   => '127.0.0.1',
          :api_port                    => 1234,
          :path                        => '/keystone',
          :ssl                         => true,
          :workers                     => 10,
          :ssl_cert                    => 'ssl cert',
          :ssl_key                     => 'ssl key',
          :ssl_chain                   => 'ssl chain',
          :ssl_ca                      => 'ssl ca',
          :ssl_crl_path                => '/etc/ssl',
          :ssl_crl                     => 'crl',
          :ssl_certs_dir               => '/etc/ssl/certs',
          :threads                     => 10,
          :priority                    => '20',
          :wsgi_application_group      => 'group',
          :wsgi_pass_authorization     => 'Off',
          :wsgi_chunked_request        => 'On',
          :wsgi_script_source          => '/path/to/my/script.py',
          :headers                     => ['set X-XSS-Protection "1; mode=block"'],
          :request_headers             => ['set Content-Type "application/json"'],
          :vhost_custom_fragment       => 'custom',
          :custom_wsgi_process_options => { 'python-path' => '/my/python/virtualenv' },
        }
      end

      it { should contain_openstacklib__wsgi__apache('keystone_wsgi').with(
        :servername                  => params[:servername],
        :bind_host                   => params[:bind_host],
        :bind_port                   => params[:api_port],
        :path                        => params[:path],
        :workers                     => params[:workers],
        :threads                     => params[:threads],
        :priority                    => params[:priority],
        :ssl                         => params[:ssl],
        :ssl_cert                    => params[:ssl_cert],
        :ssl_key                     => params[:ssl_key],
        :ssl_chain                   => params[:ssl_chain],
        :ssl_ca                      => params[:ssl_ca],
        :ssl_crl_path                => params[:ssl_crl_path],
        :ssl_crl                     => params[:ssl_crl],
        :ssl_certs_dir               => params[:ssl_certs_dir],
        :wsgi_application_group      => params[:wsgi_application_group],
        :wsgi_pass_authorization     => params[:wsgi_pass_authorization],
        :wsgi_chunked_request        => params[:wsgi_chunked_request],
        :wsgi_script_source          => params[:wsgi_script_source],
        :headers                     => params[:headers],
        :request_headers             => params[:request_headers],
        :vhost_custom_fragment       => params[:vhost_custom_fragment],
        :custom_wsgi_process_options => params[:custom_wsgi_process_options],
      )}
    end

    context 'with backward compatible ports' do
      let :params do
        {
          :api_port => [35357, 5000],
        }
      end

      it { should contain_openstacklib__wsgi__apache('keystone_wsgi').with(
        :bind_port => [35357, 5000],
      )}
    end

    context 'with custom access logging' do
      let :params do
        {
          :access_log_format => 'foo',
          :access_log_syslog => 'syslog:local0',
          :error_log_syslog  => 'syslog:local1',
        }
      end

      it { should contain_openstacklib__wsgi__apache('keystone_wsgi').with(
        :access_log_format => params[:access_log_format],
        :access_log_syslog => params[:access_log_syslog],
        :error_log_syslog  => params[:error_log_syslog],
      )}
    end

    context 'with access_log_file' do
      let :params do
        {
          :access_log_file => '/path/to/file',
        }
      end

      it { should contain_openstacklib__wsgi__apache('keystone_wsgi').with(
        :access_log_file => params[:access_log_file],
      )}
    end

    context 'with access_log_pipe' do
      let :params do
        {
          :access_log_pipe => 'pipe',
        }
      end

      it { should contain_openstacklib__wsgi__apache('keystone_wsgi').with(
        :access_log_pipe => params[:access_log_pipe],
      )}
    end

    context 'with error_log_file' do
      let :params do
        {
          :error_log_file => '/path/to/file',
        }
      end

      it { should contain_openstacklib__wsgi__apache('keystone_wsgi').with(
        :error_log_file => params[:error_log_file],
      )}
    end

    context 'with error_log_pipe' do
      let :params do
        {
          :error_log_pipe => 'pipe',
        }
      end

      it { should contain_openstacklib__wsgi__apache('keystone_wsgi').with(
        :error_log_pipe => params[:error_log_pipe],
      )}
    end
  end

  shared_examples 'keystone::wsgi::apache on Ubuntu' do
    context 'with default parameters' do
      it {
        is_expected.to contain_file('/etc/apache2/sites-available/keystone.conf').with(
          :ensure  => 'file',
          :content => '')
      }
    end
  end
  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :os_workers_keystone => 8,
          :concat_basedir      => '/var/lib/puppet/concat',
          :fqdn                => 'some.host.tld',
        }))
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          {
            :httpd_service_name => 'apache2',
            :httpd_ports_file   => '/etc/apache2/ports.conf',
            :wsgi_script_path   => '/usr/lib/cgi-bin/keystone',
          }
        when 'RedHat'
          {
            :httpd_service_name => 'httpd',
            :httpd_ports_file   => '/etc/httpd/conf/ports.conf',
            :wsgi_script_path   => '/var/www/cgi-bin/keystone',
          }
        end
      end

      it_behaves_like 'keystone::wsgi::apache'
      if facts[:operatingsystem] == 'Ubuntu'
        it_behaves_like 'keystone::wsgi::apache on Ubuntu'
      end
    end
  end
end
