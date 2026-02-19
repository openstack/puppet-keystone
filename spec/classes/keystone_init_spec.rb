require 'spec_helper'

describe 'keystone' do

  shared_examples 'keystone' do
    let :params do
      { :service_name => 'httpd' }
    end

    let :pre_condition do
      'include apache
       include keystone::wsgi::apache'
    end

    context 'with default parameters' do
      it { is_expected.to contain_class('keystone::logging') }
      it { is_expected.to contain_class('keystone::params') }
      it { is_expected.to contain_class('keystone::policy') }

      it { is_expected.to contain_package('keystone').with(
        :ensure => 'present',
        :name   => platform_params[:package_name],
        :tag    => ['openstack', 'keystone-package'],
      ) }

      it { is_expected.to contain_class('openstacklib::openstackclient') }

      it 'should synchronize the db if $sync_db is true' do
        is_expected.to contain_class('keystone::db::sync')
      end

      it 'should set the default values' do
        is_expected.to contain_resources('keystone_config').with({ :purge => false })
        is_expected.to contain_keystone_config('DEFAULT/public_endpoint').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('token/provider').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('token/expiration').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('identity/password_hash_algorithm').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('identity/password_hash_rounds').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('identity/max_password_length').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('revoke/driver').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('policy/driver').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('token/revoke_by_id').with_value('<SERVICE DEFAULT>')

        is_expected.to contain_oslo__middleware('keystone_config').with(
          :enable_proxy_headers_parsing => '<SERVICE DEFAULT>',
          :max_request_body_size        => '<SERVICE DEFAULT>',
        )

        is_expected.to contain_keystone_config('catalog/driver').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('DEFAULT/max_token_size').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('DEFAULT/list_limit').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('DEFAULT/max_db_limit').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('DEFAULT/notification_format').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('DEFAULT/notification_opt_out').with_value('<SERVICE DEFAULT>')

        is_expected.to contain_oslo__messaging__default('keystone_config').with(
          :executor_thread_pool_size => '<SERVICE DEFAULT>',
          :transport_url             => '<SERVICE DEFAULT>',
          :control_exchange          => '<SERVICE DEFAULT>',
          :rpc_response_timeout      => '<SERVICE DEFAULT>',
        )

        is_expected.to contain_oslo__messaging__notifications('keystone_config').with(
          :transport_url => '<SERVICE DEFAULT>',
          :driver        => '<SERVICE DEFAULT>',
          :topics        => '<SERVICE DEFAULT>',
          :retry         => '<SERVICE DEFAULT>',
        )

        is_expected.to contain_oslo__messaging__rabbit('keystone_config').with(
          :kombu_ssl_version               => '<SERVICE DEFAULT>',
          :kombu_ssl_keyfile               => '<SERVICE DEFAULT>',
          :kombu_ssl_certfile              => '<SERVICE DEFAULT>',
          :kombu_ssl_ca_certs              => '<SERVICE DEFAULT>',
          :kombu_reconnect_delay           => '<SERVICE DEFAULT>',
          :kombu_failover_strategy         => '<SERVICE DEFAULT>',
          :kombu_compression               => '<SERVICE DEFAULT>',
          :rabbit_use_ssl                  => '<SERVICE DEFAULT>',
          :rabbit_ha_queues                => '<SERVICE DEFAULT>',
          :heartbeat_timeout_threshold     => '<SERVICE DEFAULT>',
          :heartbeat_rate                  => '<SERVICE DEFAULT>',
          :rabbit_qos_prefetch_count       => '<SERVICE DEFAULT>',
          :amqp_durable_queues             => '<SERVICE DEFAULT>',
          :amqp_auto_delete                => '<SERVICE DEFAULT>',
          :rabbit_quorum_queue             => '<SERVICE DEFAULT>',
          :rabbit_transient_quorum_queue   => '<SERVICE DEFAULT>',
          :rabbit_transient_queues_ttl     => '<SERVICE DEFAULT>',
          :rabbit_quorum_delivery_limit    => '<SERVICE DEFAULT>',
          :rabbit_quorum_max_memory_length => '<SERVICE DEFAULT>',
          :rabbit_quorum_max_memory_bytes  => '<SERVICE DEFAULT>',
          :use_queue_manager               => '<SERVICE DEFAULT>',
          :rabbit_stream_fanout            => '<SERVICE DEFAULT>',
          :enable_cancel_on_failover       => '<SERVICE DEFAULT>',
        )

        is_expected.to contain_keystone_config('identity/domain_specific_drivers_enabled').with_ensure('absent')
        is_expected.to contain_keystone_config('identity/domain_config_dir').with_ensure('absent')
      end

      it { is_expected.to_not contain_file('/etc/keystone/domains') }

      it { is_expected.to contain_file('/etc/keystone/fernet-keys').with(
        :ensure => 'directory',
        :owner  => 'keystone',
        :group  => 'keystone',
        'mode'  => '0600',
      ) }

      it { is_expected.to contain_exec('keystone-manage fernet_setup').with(
        :command => 'keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone',
        :user    => 'keystone',
        :creates => '/etc/keystone/fernet-keys/0',
        :require => 'File[/etc/keystone/fernet-keys]',
      ) }
      it { is_expected.to contain_keystone_config('fernet_tokens/key_repository').with_value('/etc/keystone/fernet-keys') }

      it { is_expected.to contain_file('/etc/keystone/credential-keys').with(
        :ensure => 'directory',
        :owner  => 'keystone',
        :group  => 'keystone',
        'mode'  => '0600',
      ) }

      it { is_expected.to contain_exec('keystone-manage credential_setup').with(
        :command => 'keystone-manage credential_setup --keystone-user keystone --keystone-group keystone',
        :user    => 'keystone',
        :creates => '/etc/keystone/credential-keys/0',
        :require => 'File[/etc/keystone/credential-keys]',
      ) }
      it { is_expected.to contain_keystone_config('credential/key_repository').with_value('/etc/keystone/credential-keys')}

      it do
        if facts[:os]['name'] == 'Debian'
          is_expected.to contain_service('keystone').with(
            :ensure => 'stopped',
            :name   => platform_params[:service_name],
            :enable => false,
            :tag    => 'keystone-service',
          )
        else
          is_expected.to_not contain_service('keystone')
        end
      end

      it { is_expected.to contain_exec('restart_keystone').with(
        'command' => "systemctl restart #{platform_params[:httpd_service_name]}",
      ) }
    end

    context 'with overridden parameters' do
      before :each do
        params.merge!({
          :service_name                 => 'httpd',
          :purge_config                 => true,
          :public_endpoint              => 'http://127.0.0.1:5000',
          :token_provider               => 'fernet',
          :token_expiration             => 3600,
          :password_hash_algorithm      => 'bcrypt',
          :password_hash_rounds         => 12,
          :max_password_length          => 54,
          :revoke_driver                => 'sql',
          :policy_driver                => 'sql',
          :revoke_by_id                 => true,
          :enable_proxy_headers_parsing => true,
          :max_request_body_size        => 114688,
          :catalog_driver               => 'templated',
          :max_token_size               => 255,
          :list_limit                   => 10000,
          :max_db_limit                 => 10001,
          :notification_format          => 'basic',
          :notification_opt_out         => [
            'identity.authenticate.success',
            'identity.authenticate.pending',
            'identity.authenticate.failed'
            ],
        })
      end

      let :pre_condition do
        'include apache
         include keystone::wsgi::apache'
      end


      it 'should set the overridden values' do
        is_expected.to contain_resources('keystone_config').with({ :purge => true })
        is_expected.to contain_keystone_config('DEFAULT/public_endpoint').with_value('http://127.0.0.1:5000')
        is_expected.to contain_keystone_config('token/provider').with_value('fernet')
        is_expected.to contain_keystone_config('token/expiration').with_value(3600)
        is_expected.to contain_keystone_config('identity/password_hash_algorithm').with_value('bcrypt')
        is_expected.to contain_keystone_config('identity/password_hash_rounds').with_value(12)
        is_expected.to contain_keystone_config('identity/max_password_length').with_value(54)
        is_expected.to contain_keystone_config('revoke/driver').with_value('sql')
        is_expected.to contain_keystone_config('policy/driver').with_value('sql')
        is_expected.to contain_keystone_config('token/revoke_by_id').with_value(true)

        is_expected.to contain_oslo__middleware('keystone_config').with(
          :enable_proxy_headers_parsing => true,
          :max_request_body_size        => 114688,
        )

        is_expected.to contain_keystone_config('catalog/driver').with_value('templated')
        is_expected.to contain_keystone_config('DEFAULT/max_token_size').with_value(255)
        is_expected.to contain_keystone_config('DEFAULT/list_limit').with_value(10000)
        is_expected.to contain_keystone_config('DEFAULT/max_db_limit').with_value(10001)
        is_expected.to contain_keystone_config('DEFAULT/notification_format').with_value('basic')
        is_expected.to contain_keystone_config('DEFAULT/notification_opt_out').with_value([
          'identity.authenticate.success',
          'identity.authenticate.pending',
          'identity.authenticate.failed'
        ])
      end
    end

    context 'with package management disabled' do
      before :each do
        params.merge!({
          :manage_package => false
        })
      end

      it { is_expected.to_not contain_package('keystone') }
      it { is_expected.to_not contain_class('openstacklib::openstackclient') }
    end

    context 'when sync_db is set to false' do
      before :each do
        params.merge!({
          'sync_db' => false,
        })
      end

      it { is_expected.not_to contain_exec('keystone-manage db_sync') }
    end

    context 'with RabbitMQ communication SSLed' do
      before :each do
        params.merge!({
          :rabbit_use_ssl     => true,
          :kombu_ssl_ca_certs => '/path/to/ssl/ca/certs',
          :kombu_ssl_certfile => '/path/to/ssl/cert/file',
          :kombu_ssl_keyfile  => '/path/to/ssl/keyfile',
          :kombu_ssl_version  => 'TLSv1'
        })
      end

      it { is_expected.to contain_oslo__messaging__rabbit('keystone_config').with(
        :rabbit_use_ssl     => true,
        :kombu_ssl_ca_certs => '/path/to/ssl/ca/certs',
        :kombu_ssl_certfile => '/path/to/ssl/cert/file',
        :kombu_ssl_keyfile  => '/path/to/ssl/keyfile',
        :kombu_ssl_version  => 'TLSv1'
      )}
    end

    context 'with RabbitMQ communication not SSLed' do
      it { is_expected.to contain_oslo__messaging__rabbit('keystone_config').with(
          :rabbit_use_ssl     => '<SERVICE DEFAULT>',
          :kombu_ssl_ca_certs => '<SERVICE DEFAULT>',
          :kombu_ssl_certfile => '<SERVICE DEFAULT>',
          :kombu_ssl_keyfile  => '<SERVICE DEFAULT>',
          :kombu_ssl_version  => '<SERVICE DEFAULT>'
      )}
    end

    context 'setting notification settings' do
      before :each do
        params.merge!({
          :default_transport_url      => 'rabbit://user:pass@host:1234/virt',
          :notification_transport_url => 'rabbit://user:pass@host:1234/virt',
          :notification_driver        => ['keystone.openstack.common.notifier.rpc_notifier'],
          :notification_topics        => ['notifications'],
          :notification_retry         => 10,
          :control_exchange           => 'keystone',
          :rpc_response_timeout       => 120,
          :executor_thread_pool_size  => 64,
        })
      end

      it {
        is_expected.to contain_oslo__messaging__default('keystone_config').with(
          :executor_thread_pool_size => 64,
          :transport_url             => 'rabbit://user:pass@host:1234/virt',
          :control_exchange          => 'keystone',
          :rpc_response_timeout      => 120,
        )

        is_expected.to contain_oslo__messaging__notifications('keystone_config').with(
          :transport_url => 'rabbit://user:pass@host:1234/virt',
          :driver        => ['keystone.openstack.common.notifier.rpc_notifier'],
          :topics        => ['notifications'],
          :retry         => 10,
        )
      }
    end

    context 'setting kombu settings' do
      before :each do
        params.merge!({
          :kombu_reconnect_delay => '1.0',
          :kombu_compression     => 'gzip',
        })
      end

      it {
        is_expected.to contain_oslo__messaging__rabbit('keystone_config').with(
          :kombu_reconnect_delay => '1.0',
          :kombu_compression     => 'gzip',
      ) }
    end

    context 'when disabling credential_setup' do
      before :each do
        params.merge!({
          'enable_credential_setup' => false,
        })
      end

      it { is_expected.to_not contain_file('/etc/keystone/credential-keys') }
      it { is_expected.to_not contain_exec('keystone-manage credential_setup') }
      it { is_expected.to contain_keystone_config('credential/key_repository').with_value('/etc/keystone/credential-keys') }
    end

    context 'when overriding the credential key directory' do
      before :each do
        params.merge!({
          'enable_credential_setup'   => true,
          'credential_key_repository' => '/var/lib/credential-keys',
        })
      end

      it { is_expected.to contain_file('/var/lib/credential-keys').with(
        :ensure => 'directory',
        :owner  => 'keystone',
        :group  => 'keystone',
        'mode'  => '0600',
      ) }
      it { is_expected.to contain_exec('keystone-manage credential_setup').with(
        :creates => '/var/lib/credential-keys/0'
      ) }
      it { is_expected.to contain_keystone_config('credential/key_repository').with_value('/var/lib/credential-keys') }
    end

    context 'when overriding the keystone group and user' do
      before :each do
        params.merge!({
          'enable_credential_setup' => true,
          'keystone_user'           => 'test_user',
          'keystone_group'          => 'test_group',
        })
      end

      it { is_expected.to contain_exec('keystone-manage credential_setup').with(
        :command => "keystone-manage credential_setup --keystone-user #{params['keystone_user']} --keystone-group #{params['keystone_group']}",
        :user    => params['keystone_user'],
        :creates => '/etc/keystone/credential-keys/0',
        :require => 'File[/etc/keystone/credential-keys]',
      ) }
    end

    context 'when setting credential_keys parameter' do
      before :each do
        params.merge!({
          'enable_credential_setup' => true,
          'credential_keys' => {
            '/etc/keystone/credential-keys/0' => {
              'content' => 't-WdduhORSqoyAykuqWAQSYjg2rSRuJYySgI2xh48CI=',
            },
            '/etc/keystone/credential-keys/1' => {
              'content' => 'GLlnyygEVJP4-H2OMwClXn3sdSQUZsM5F194139Unv8=',
            },
          }
        })
      end

      it { is_expected.to_not contain_exec('keystone-manage credential_setup') }
      it { is_expected.to contain_file('/etc/keystone/credential-keys/0').with(
        'content'   => 't-WdduhORSqoyAykuqWAQSYjg2rSRuJYySgI2xh48CI=',
        'owner'     => 'keystone',
        :show_diff  => false,
        'subscribe' => 'Anchor[keystone::install::end]',
      )}
      it { is_expected.to contain_file('/etc/keystone/credential-keys/1').with(
        'content'   => 'GLlnyygEVJP4-H2OMwClXn3sdSQUZsM5F194139Unv8=',
        'owner'     => 'keystone',
        :show_diff  => false,
        'subscribe' => 'Anchor[keystone::install::end]',
      )}
    end

    context 'when disabling fernet_setup' do
      before :each do
        params.merge!({
          'enable_fernet_setup' => false,
        })
      end

      it { is_expected.to_not contain_file('/etc/keystone/fernet-keys') }
      it { is_expected.to_not contain_exec('keystone-manage fernet_setup') }
      it { is_expected.to contain_keystone_config('fernet_tokens/key_repository').with_value('/etc/keystone/fernet-keys') }
    end

    context 'when enabling fernet_setup' do
      before :each do
        params.merge!({
          'enable_fernet_setup'    => true,
          'fernet_max_active_keys' => 5,
        })
      end

      it { is_expected.to contain_file('/etc/keystone/fernet-keys').with(
        :ensure => 'directory',
        :owner  => 'keystone',
        :group  => 'keystone',
        :mode   => '0600',
      ) }

      it { is_expected.to contain_exec('keystone-manage fernet_setup').with(
        :command => 'keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone',
        :user    => 'keystone',
        :creates => '/etc/keystone/fernet-keys/0',
        :require => 'File[/etc/keystone/fernet-keys]',
      ) }
      it { is_expected.to contain_keystone_config('fernet_tokens/max_active_keys').with_value(5)}
    end

    context 'when overriding the fernet key directory' do
      before :each do
        params.merge!({
          'enable_fernet_setup'   => true,
          'fernet_key_repository' => '/var/lib/fernet-keys',
        })
      end

      it { is_expected.to contain_file('/var/lib/fernet-keys').with(
        :ensure => 'directory',
        :owner  => 'keystone',
        :group  => 'keystone',
        :mode   => '0600',
      ) }

      it { is_expected.to contain_exec('keystone-manage fernet_setup').with(
        :creates => '/var/lib/fernet-keys/0'
      ) }
      it { is_expected.to contain_keystone_config('fernet_tokens/key_repository').with_value('/var/lib/fernet-keys') }
    end

    context 'when overriding the keystone group and user' do
      before :each do
        params.merge!({
          'enable_fernet_setup' => true,
          'keystone_user'       => 'test_user',
          'keystone_group'      => 'test_group',
        })
      end

      it { is_expected.to contain_exec('keystone-manage fernet_setup').with(
        :command => "keystone-manage fernet_setup --keystone-user #{params['keystone_user']} --keystone-group #{params['keystone_group']}",
        :user    => params['keystone_user'],
        :creates => '/etc/keystone/fernet-keys/0',
        :require => 'File[/etc/keystone/fernet-keys]',
      ) }
    end

    context 'when setting fernet_keys parameter' do
      before :each do
        params.merge!({
          'enable_fernet_setup' => true,
          'fernet_keys' => {
            '/etc/keystone/fernet-keys/0' => {
              'content' => 't-WdduhORSqoyAykuqWAQSYjg2rSRuJYySgI2xh48CI=',
            },
            '/etc/keystone/fernet-keys/1' => {
              'content' => 'GLlnyygEVJP4-H2OMwClXn3sdSQUZsM5F194139Unv8=',
            },
          }
        })
      end

      it { is_expected.to_not contain_exec('keystone-manage fernet_setup') }
      it { is_expected.to contain_file('/etc/keystone/fernet-keys/0').with(
        'content'   => 't-WdduhORSqoyAykuqWAQSYjg2rSRuJYySgI2xh48CI=',
        'owner'     => 'keystone',
        'mode'      => '0600',
        'replace'   => true,
        'subscribe' => 'Anchor[keystone::install::end]',
        'tag'       => 'keystone-fernet-key',
      )}
      it { is_expected.to contain_file('/etc/keystone/fernet-keys/1').with(
        'content'   => 'GLlnyygEVJP4-H2OMwClXn3sdSQUZsM5F194139Unv8=',
        'owner'     => 'keystone',
        'mode'      => '0600',
        'replace'   => true,
        'subscribe' => 'Anchor[keystone::install::end]',
        'tag'       => 'keystone-fernet-key',
      )}
    end

    context 'when not replacing fernet_keys and setting fernet_keys parameter' do
      before :each do
        params.merge!({
          'enable_fernet_setup' => true,
          'fernet_keys' => {
            '/etc/keystone/fernet-keys/0' => {
              'content' => 't-WdduhORSqoyAykuqWAQSYjg2rSRuJYySgI2xh48CI=',
            },
            '/etc/keystone/fernet-keys/1' => {
              'content' => 'GLlnyygEVJP4-H2OMwClXn3sdSQUZsM5F194139Unv8=',
            },
          },
          'fernet_replace_keys' => false,
        })
      end

      it { is_expected.to_not contain_exec('keystone-manage fernet_setup') }
      it { is_expected.to contain_file('/etc/keystone/fernet-keys/0').with(
        'content'   => 't-WdduhORSqoyAykuqWAQSYjg2rSRuJYySgI2xh48CI=',
        'owner'     => 'keystone',
        'mode'      => '0600',
        'replace'   => false,
        'subscribe' => 'Anchor[keystone::install::end]',
      )}
      it { is_expected.to contain_file('/etc/keystone/fernet-keys/1').with(
        'content'   => 'GLlnyygEVJP4-H2OMwClXn3sdSQUZsM5F194139Unv8=',
        'owner'     => 'keystone',
        'mode'      => '0600',
        'replace'   => false,
        'subscribe' => 'Anchor[keystone::install::end]',
      )}
    end

    context 'with default domain and eventlet service is managed and enabled' do
      before :each do
        params.merge!({
          'default_domain' => 'test'
        })
      end

      it { is_expected.to contain_keystone_domain('test').with(
        :ensure     => 'present',
        :enabled    => true,
        :is_default => true,
      ) }
      it { is_expected.to contain_anchor('default_domain_created') }
    end

    context 'with default domain and service is not managed' do
      before :each do
        params.merge!({
          'default_domain' => 'test',
          'manage_service' => false,
        })
      end

      it { is_expected.to contain_keystone_domain('test').with(
        :ensure     => 'present',
        :enabled    => true,
        :is_default => true,
      ) }
      it { is_expected.to_not contain_exec('restart_keystone') }
      it { is_expected.to contain_anchor('default_domain_created') }
    end

    context 'when using domain config' do
      before :each do
        params.merge!({
          'using_domain_config'=> true
        })
      end

      it { is_expected.to contain_file('/etc/keystone/domains').with(
        'ensure' => "directory",
      ) }
      it { is_expected
          .to contain_keystone_config('identity/domain_specific_drivers_enabled')
          .with('value' => true,
      ) }
      it { is_expected
          .to contain_keystone_config('identity/domain_config_dir')
          .with('value' => '/etc/keystone/domains',
      ) }
    end

    context 'when using domain config and a wrong directory' do
      before :each do
        params.merge!({
          'using_domain_config'=> true,
          'domain_config_directory' => 'this/is/not/an/absolute/path'
        })
      end

      it { should raise_error(Puppet::Error) }
    end

    context 'when setting domain directory and not using domain config' do
      before :each do
        params.merge!({
          'using_domain_config'=> false,
          'domain_config_directory' => '/this/is/an/absolute/path'
        })
      end

      it 'should raise an error' do
        expect { should contain_file('/etc/keystone/domains') }
          .to raise_error(Puppet::Error, %r(You must activate domain))
      end
    end

    context 'when setting domain directory and using domain config' do
      before :each do
        params.merge!({
          'using_domain_config'=> true,
          'domain_config_directory' => '/this/is/an/absolute/path'
        })
      end

      it { is_expected.to contain_file('/this/is/an/absolute/path').with(
        'ensure' => "directory",
      ) }
    end
  end

  shared_examples 'keystone in Debian' do
    context 'with default parameters' do
      it { is_expected.to contain_service('keystone').with(
        :ensure     => 'running',
        :enable     => true,
        :name       => platform_params[:service_name],
        :hasstatus  => true,
        :hasrestart => true,
        :tag        => 'keystone-service',
      ) }

      it { is_expected.to contain_exec('restart_keystone').with(
        'command' => "systemctl restart #{platform_params[:service_name]}",
      ) }
    end


  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          case facts[:os]['name']
          when 'Debian'
            { :package_name       => 'keystone',
              :service_name       => 'keystone',
              :httpd_service_name => 'apache2' }
          when 'Ubuntu'
            { :package_name       => 'keystone',
              :httpd_service_name => 'apache2' }
          end
        when 'RedHat'
          { :package_name       => 'openstack-keystone',
            :httpd_service_name => 'httpd' }
        end
      end

      it_behaves_like 'keystone'
      if facts[:os]['name'] == 'Debian'
        it_behaves_like 'keystone in Debian'
      end
    end
  end
end
