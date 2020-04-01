require 'spec_helper'

describe 'keystone::cache' do
  shared_examples 'keystone::cache' do

    context 'with default parameters' do
      let :params do
        {}
      end

      it 'configure cache default params' do
        is_expected.to contain_keystone_config('memcache/dead_retry').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('memcache/pool_maxsize').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('memcache/pool_unused_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('memcache/socket_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('token/caching').with_value('<SERVICE DEFAULT>')

        is_expected.to contain_keystone_config('cache/config_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('cache/expiration_time').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('cache/backend').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('cache/backend_argument').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('cache/proxies').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('cache/enabled').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('cache/debug_cache_backend').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('cache/memcache_servers').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('cache/memcache_dead_retry').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('cache/memcache_socket_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('cache/memcache_pool_unused_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('cache/memcache_servers').with_value('<SERVICE DEFAULT>')

        is_expected.to contain_oslo__cache('keystone_config').with_manage_backend_package(true)
      end
    end

    context 'with specific values' do
      let :params do
        {
          :config_prefix                        => 'prefix',
          :expiration_time                      => '3600',
          :backend                              => 'dogpile.cache.memcached',
          :backend_argument                     => ['url:SERVER1:12211'],
          :proxies                              => ['proxy01:8888', 'proxy02:8888'],
          :enabled                              => true,
          :debug_cache_backend                  => false,
          :memcache_servers                     => ['memcached01:11211', 'memcached02:11211'],
          :memcache_dead_retry                  => '60',
          :memcache_socket_timeout              => '300.0',
          :memcache_pool_maxsize                => '10',
          :memcache_pool_unused_timeout         => '120',
          :memcache_pool_connection_get_timeout => '360',
          :manage_backend_package               => false,
          :token_caching                        => 'true',
        }
      end

      it 'configure cache params' do
        is_expected.to contain_keystone_config('memcache/dead_retry').with_value('60')
        is_expected.to contain_keystone_config('memcache/pool_maxsize').with_value('10')
        is_expected.to contain_keystone_config('memcache/pool_unused_timeout').with_value('120')
        is_expected.to contain_keystone_config('memcache/socket_timeout').with_value('300.0')
        is_expected.to contain_keystone_config('token/caching').with_value('true')

        is_expected.to contain_keystone_config('cache/config_prefix').with_value('prefix')
        is_expected.to contain_keystone_config('cache/expiration_time').with_value('3600')
        is_expected.to contain_keystone_config('cache/backend').with_value('dogpile.cache.memcached')
        is_expected.to contain_keystone_config('cache/backend_argument').with_value('url:SERVER1:12211')
        is_expected.to contain_keystone_config('cache/proxies').with_value('proxy01:8888,proxy02:8888')
        is_expected.to contain_keystone_config('cache/enabled').with_value('true')
        is_expected.to contain_keystone_config('cache/debug_cache_backend').with_value('false')
        is_expected.to contain_keystone_config('cache/memcache_servers').with_value('memcached01:11211,memcached02:11211')
        is_expected.to contain_keystone_config('cache/memcache_dead_retry').with_value('60')
        is_expected.to contain_keystone_config('cache/memcache_socket_timeout').with_value('300.0')
        is_expected.to contain_keystone_config('cache/memcache_pool_maxsize').with_value('10')
        is_expected.to contain_keystone_config('cache/memcache_pool_unused_timeout').with_value('120')

        is_expected.to contain_oslo__cache('keystone_config').with_manage_backend_package(false)
      end
    end

  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'keystone::cache'
    end
  end
end
