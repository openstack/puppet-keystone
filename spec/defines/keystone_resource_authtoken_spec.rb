require 'spec_helper'

describe 'keystone::resource::authtoken' do

  let (:title) { 'keystone_config' }

  let :params do
    { :username     => 'keystone',
      :password     => 'secret',
      :auth_url     => 'http://127.0.0.1:35357',
      :project_name => 'services' }
  end

  shared_examples 'shared examples' do
    context 'with only required parameters' do
      it 'configures keystone authtoken' do
        is_expected.to contain_keystone_config('keystone_authtoken/username').with_value('keystone')
        is_expected.to contain_keystone_config('keystone_authtoken/password').with_value('secret').with_secret(true)
        is_expected.to contain_keystone_config('keystone_authtoken/auth_url').with_value( params[:auth_url] )
        is_expected.to contain_keystone_config('keystone_authtoken/project_name').with_value( params[:project_name] )
        is_expected.to contain_keystone_config('keystone_authtoken/project_domain_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/user_domain_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/insecure').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/auth_section').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/auth_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/auth_uri').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/auth_version').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/cache').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/cafile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/certfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/check_revocations_for_cached').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/delay_auth_decision').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/enforce_token_bind').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/hash_algorithms').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/http_connect_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/http_request_max_retries').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/include_service_catalog').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/keyfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_conn_get_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_dead_retry').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_maxsize').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_socket_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_unused_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_secret_key').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_security_strategy').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_use_advanced_pool').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcached_servers').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/region_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/revocation_cache_time').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/signing_dir').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/token_cache_time').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'set all keystone authoken parameters' do
      before do
        params.merge! ({
          :username                     => 'username',
          :password                     => 'hardpassword',
          :auth_url                     => 'http://127.1.1.127:35357/',
          :project_name                 => 'NoProject',
          :user_domain_name             => 'MyDomain',
          :project_domain_name          => 'OurDomain',
          :insecure                     =>  true,
          :auth_section                 => 'some_section',
          :auth_type                    => 'password',
          :auth_uri                     => 'http://127.1.1.127:5000/',
          :auth_version                 => '3',
          :cache                        => 'somevalue',
          :cafile                       => 'cafile.pem',
          :certfile                     => 'certfile.crt',
          :check_revocations_for_cached =>  true,
          :delay_auth_decision          =>  true,
          :enforce_token_bind           => 'strict',
          :hash_algorithms              => 'sha1',
          :http_connect_timeout         => '120',
          :http_request_max_retries     => '5',
          :include_service_catalog      => false,
          :keyfile                      => 'somekey.key',
          :region_name                  => 'MyRegion',
          :revocation_cache_time        => '50',
          :signing_dir                  => '/tmp/',
          :token_cache_time             => '20',
        })
      end
      it 'override keystone authtoken parameters' do
        is_expected.to contain_keystone_config('keystone_authtoken/username').with_value(params[:username])
        is_expected.to contain_keystone_config('keystone_authtoken/password').with_value(params[:password]).with_secret(true)
        is_expected.to contain_keystone_config('keystone_authtoken/auth_url').with_value( params[:auth_url] )
        is_expected.to contain_keystone_config('keystone_authtoken/project_name').with_value( params[:project_name] )
        is_expected.to contain_keystone_config('keystone_authtoken/user_domain_name').with_value(params[:user_domain_name])
        is_expected.to contain_keystone_config('keystone_authtoken/project_domain_name').with_value(params[:project_domain_name])
        is_expected.to contain_keystone_config('keystone_authtoken/insecure').with_value(params[:insecure])
        is_expected.to contain_keystone_config('keystone_authtoken/auth_section').with_value(params[:auth_section])
        is_expected.to contain_keystone_config('keystone_authtoken/auth_uri').with_value(params[:auth_uri])
        is_expected.to contain_keystone_config('keystone_authtoken/auth_version').with_value(params[:auth_version])
        is_expected.to contain_keystone_config('keystone_authtoken/cache').with_value(params[:cache])
        is_expected.to contain_keystone_config('keystone_authtoken/check_revocations_for_cached').with_value(params[:check_revocations_for_cached])
        is_expected.to contain_keystone_config('keystone_authtoken/delay_auth_decision').with_value(params[:delay_auth_decision])
        is_expected.to contain_keystone_config('keystone_authtoken/enforce_token_bind').with_value(params[:enforce_token_bind])
        is_expected.to contain_keystone_config('keystone_authtoken/hash_algorithms').with_value(params[:hash_algorithms])
        is_expected.to contain_keystone_config('keystone_authtoken/http_connect_timeout').with_value(params[:http_connect_timeout])
        is_expected.to contain_keystone_config('keystone_authtoken/http_request_max_retries').with_value(params[:http_request_max_retries])
        is_expected.to contain_keystone_config('keystone_authtoken/include_service_catalog').with_value(params[:include_service_catalog])
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_conn_get_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_dead_retry').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_maxsize').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_socket_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_unused_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_secret_key').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_security_strategy').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_use_advanced_pool').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/memcached_servers').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('keystone_authtoken/region_name').with_value(params[:region_name])
        is_expected.to contain_keystone_config('keystone_authtoken/revocation_cache_time').with_value(params[:revocation_cache_time])
        is_expected.to contain_keystone_config('keystone_authtoken/signing_dir').with_value(params[:signing_dir])
        is_expected.to contain_keystone_config('keystone_authtoken/token_cache_time').with_value(params[:token_cache_time])
      end
    end

    context 'without password required parameter' do
      let :params do
        params.delete(:password)
      end
      it { expect { is_expected.to raise_error(Puppet::Error) } }
    end

    context 'without specify project' do
      let :params do
        params.delete(:project_name)
      end
      it { expect { is_expected.to raise_error(Puppet::Error) } }
    end

    context 'when specifying all memcache params' do
      before do
        params.merge! ({
          :memcached_servers              => 'localhost',
          :memcache_use_advanced_pool     =>  true,
          :memcache_security_strategy     => 'ENCRYPT',
          :memcache_secret_key            => 'secret_key',
          :memcache_pool_unused_timeout   => '60',
          :memcache_pool_socket_timeout   => '3',
          :memcache_pool_maxsize          => '10',
          :memcache_pool_dead_retry       => '300',
          :memcache_pool_conn_get_timeout => '10',
          :manage_memcache_package        => true,
      })
      end
      it 'configures memcache severs in keystone authtoken' do
        is_expected.to contain_keystone_config('keystone_authtoken/memcached_servers').with_value( params[:memcached_servers] )
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_use_advanced_pool').with_value( params[:memcache_use_advanced_pool] )
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_security_strategy').with_value( params[:memcache_security_strategy] )
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_secret_key').with_value( params[:memcache_secret_key] )
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_unused_timeout').with_value( params[:memcache_pool_unused_timeout] )
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_socket_timeout').with_value( params[:memcache_pool_socket_timeout] )
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_maxsize').with_value( params[:memcache_pool_maxsize] )
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_dead_retry').with_value( params[:memcache_pool_dead_retry] )
        is_expected.to contain_keystone_config('keystone_authtoken/memcache_pool_conn_get_timeout').with_value( params[:memcache_pool_conn_get_timeout] )
        is_expected.to contain_package('python-memcache').with(
          :name   => 'python-memcache',
          :ensure => 'present'
        )
      end
    end

    context 'memcache_security_strategy with invalid value' do
      before do
        params.merge!({ :memcache_security_strategy => 'mystrategy', })
      end
      it { expect { is_expected.to raise_error(Puppet::Error, 'memcache_security_strategy can be set only to MAC or ENCRYPT') } }
    end

    context 'require memcache_secret_key when memcache_security_strategy is defined' do
      before do
        params.merge!({
          :memcache_security_strategy => 'MAC',
          :memcache_secret_key => '<SERVICE DEFAULT>',
        })
      end
      it { expect { is_expected.to raise_error(Puppet::Error, 'memcache_secret_key is required when memcache_security_strategy is defined') } }
    end

  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      include_examples 'shared examples'
    end
  end

end
