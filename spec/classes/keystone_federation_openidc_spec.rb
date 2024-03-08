require 'spec_helper'

describe 'keystone::federation::openidc' do

  def get_param(type, title, param)
    catalogue.resource(type, title).send(:parameters)[param.to_sym]
  end

  let(:pre_condition) do
    <<-EOS
    class { 'keystone': }

    include keystone::wsgi::apache
    EOS
  end

  let :params do
    { :keystone_url => 'http://localhost:5000',
      :methods => 'password, token, openid',
      :idp_name => 'myidp',
      :openidc_provider_metadata_url => 'https://accounts.google.com/.well-known/openid-configuration',
      :openidc_client_id => 'openid_client_id',
      :openidc_client_secret => 'openid_client_secret',
      :template_order => 331
     }
  end

  context 'with invalid params' do
    before do
      params.merge!(:methods => 'external, password, token, oauth1, openid')
      it_raises 'a Puppet::Error', /The external method should be dropped to avoid any interference with openid/
    end

    before do
      params.merge!(:methods => 'password, token, oauth1')
      it_raises 'a Puppet::Error', /Methods should contain openid as one of the auth methods./
    end

    before do
      params.merge!(:template_port => 330)
      it_raises 'a Puppet:Error', /The template order should be greater than 330 and less than 999./
    end

    before do
      params.merge!(:template_port => 999)
      it_raises 'a Puppet:Error', /The template order should be greater than 330 and less than 999./
    end

    before do
      params.merge!(:openidc_enable_oauth => true)
      it_raises 'a Puppet:Error', /You must set openidc_introspection_endpoint when enabling oauth support/
    end
  end

  on_supported_os({
  }).each do |os,facts|
    let (:facts) do
      facts.merge!(OSDefaults.get_facts({}))
    end

    it { is_expected.to contain_class('apache::mod::auth_openidc') }

    context 'with only required parameters' do
      it 'should have basic params for openidc in Keystone configuration' do
        is_expected.to contain_keystone_config('auth/methods').with_value('password, token, openid')
        is_expected.to contain_keystone_config('openid/remote_id_attribute').with_value('<SERVICE DEFAULT>')
      end

      it { is_expected.to contain_concat__fragment('configure_openidc_keystone').with({
        :target => "10-keystone_wsgi.conf",
        :order  => params[:template_order],
      })}

      it 'should contain expected config' do
        content = get_param('concat::fragment', 'configure_openidc_keystone', 'content')
        expect(content).to match('OIDCProviderMetadataURL "https://accounts.google.com/.well-known/openid-configuration"')
        expect(content).to match('OIDCClientID "openid_client_id"')
        expect(content).to match('OIDCClientSecret "openid_client_secret"')
      end
    end

    context 'with oauth and introspection enabled' do
      before do
        params.merge!({
          :openidc_enable_oauth => true,
          :openidc_introspection_endpoint => 'http://example.com',
        })
      end

      it 'should contain oauth and introspection config' do
        content = get_param('concat::fragment', 'configure_openidc_keystone', 'content')
        expect(content).to match('OIDCOAuthClientID "openid_client_id"')
        expect(content).to match('OIDCOAuthClientSecret "openid_client_secret"')
        expect(content).to match('OIDCOAuthIntrospectionEndpoint "http://example.com"')
        expect(content).to match('/v3/OS-FEDERATION/identity_providers/myidp/protocols/openid/auth')
      end
    end

    context 'with oauth and jwks enabled' do
      before do
        params.merge!({
          :openidc_enable_oauth => true,
          :openidc_verify_method => 'jwks',
          :openidc_verify_jwks_uri => 'http://example.com',
        })
      end

      it 'should contain oauth and jwks config' do
        content = get_param('concat::fragment', 'configure_openidc_keystone', 'content')
        expect(content).to match('OIDCOAuthVerifyJwksUri "http://example.com"')
        expect(content).to match('/v3/OS-FEDERATION/identity_providers/myidp/protocols/openid/auth')
      end
    end

    context 'with remote id attribute' do
      before do
        params.merge!({
          :remote_id_attribute => 'myremoteid',
        })
      end

      it 'should set remote id attribute in Keystone configuration' do
        is_expected.to contain_keystone_config('openid/remote_id_attribute').with_value('myremoteid')
      end

    end

    context 'with memcache options' do
      before do
        params.merge!({
          :openidc_cache_type           => 'memcache',
          :openidc_cache_shm_max        => 10,
          :openidc_cache_shm_entry_size => 11,
          :openidc_cache_dir            => '/var/cache/openidc',
          :openidc_cache_clean_interval => 12,
        })
      end

      it 'should contain memcache servers' do
        content = get_param('concat::fragment', 'configure_openidc_keystone', 'content')
        expect(content).to match('OIDCCacheType memcache')
        expect(content).to match('OIDCCacheShmMax 10')
        expect(content).to match('OIDCCacheShmEntrySize 11')
        expect(content).to match('OIDCCacheDir /var/cache/openidc')
        expect(content).to match('OIDCCacheFileCleanInterval 12')
      end
    end

    context 'with redis options' do
      before do
        params.merge!({
          :openidc_cache_type    => 'redis',
          :redis_password        => 'redispass',
          :redis_username        => 'redisuser',
          :redis_database        => 0,
          :redis_timeout         => 10,
          :redis_connect_timeout => 11,
        })
      end

      it 'should contain memcache servers' do
        content = get_param('concat::fragment', 'configure_openidc_keystone', 'content')
        expect(content).to match('OIDCCacheType redis')
        expect(content).to match('OIDCRedisCachePassword "redispass"')
        expect(content).to match('OIDCRedisCacheUsername "redisuser"')
        expect(content).to match('OIDCRedisCacheDatabase 0')
        expect(content).to match('OIDCRedisCacheTimeout 10')
        expect(content).to match('OIDCRedisCacheConnectTimeout 11')
      end
    end

    context 'with memcached_servers attribute' do
      before do
        params.merge!({
          :memcached_servers => ['127.0.0.1:11211', '127.0.0.2:11211'],
        })
      end

      it 'should contain memcache servers' do
        content = get_param('concat::fragment', 'configure_openidc_keystone', 'content')
        expect(content).to match('OIDCMemCacheServers "127.0.0.1:11211 127.0.0.2:11211"')
      end
    end

    context 'with redis_server attribute' do
      before do
        params.merge!({
          :redis_server => '127.0.0.1',
        })
      end

      it 'should contain redis server' do
        content = get_param('concat::fragment', 'configure_openidc_keystone', 'content')
        expect(content).to match('OIDCRedisCacheServer "127.0.0.1"')
      end
    end

    context 'with openidc_claim_delimiter attribute' do
      before do
        params.merge!({
          :openidc_claim_delimiter => ';',
        })
      end

      it 'should contain OIDC claim delimiter' do
        content = get_param('concat::fragment', 'configure_openidc_keystone', 'content')
        expect(content).to match('OIDCClaimDelimiter ";"')
      end
    end

    context 'with openidc_pass_userinfo_as attribute' do
      before do
        params.merge!({
          :openidc_pass_userinfo_as => 'claims',
        })
      end

      it 'should contain OIDC pass userinfo as' do
        content = get_param('concat::fragment', 'configure_openidc_keystone', 'content')
        expect(content).to match('OIDCPassUserInfoAs "claims"')
      end
    end

    context 'with openidc_pass_claim_as attribute' do
      before do
        params.merge!({
          :openidc_pass_claim_as => 'both',
        })
      end

      it 'should contain OIDC pass claim as' do
        content = get_param('concat::fragment', 'configure_openidc_keystone', 'content')
        expect(content).to match('OIDCPassClaimsAs "both"')
      end
    end

    context 'with openidc_response_mode attribute' do
      before do
        params.merge!({
          :openidc_response_mode => 'form_post',
        })
      end

      it 'should contain OIDC response mode' do
        content = get_param('concat::fragment', 'configure_openidc_keystone', 'content')
        expect(content).to match('OIDCResponseMode "form_post"')
      end
    end
  end
end
