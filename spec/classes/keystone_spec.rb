require 'spec_helper'

describe 'keystone' do

  let :facts do
    {:osfamily => 'Debian'}
  end

  let :default_params do
    {
      'package_ensure'  => 'present',
      'bind_host'       => '0.0.0.0',
      'public_port'     => '5000',
      'admin_port'      => '35357',
      'admin_token'     => 'service_token',
      'compute_port'    => '8774',
      'verbose'         => false,
      'debug'           => false,
      'use_syslog'      => false,
      'catalog_type'    => 'sql',
      'token_format'    => 'PKI',
      'cache_dir'       => '/var/cache/keystone',
      'enabled'         => true,
      'sql_connection'  => 'sqlite:////var/lib/keystone/keystone.db',
      'idle_timeout'    => '200'
    }
  end

  [{'admin_token'     => 'service_token'},
   {
      'package_ensure'  => 'latest',
      'bind_host'       => '127.0.0.1',
      'public_port'     => '5001',
      'admin_port'      => '35358',
      'admin_token'     => 'service_token_override',
      'compute_port'    => '8778',
      'verbose'         => true,
      'debug'           => true,
      'catalog_type'    => 'template',
      'token_format'    => 'UUID',
      'enabled'         => false,
      'sql_connection'  => 'mysql://a:b@c/d',
      'idle_timeout'    => '300'
    }
  ].each do |param_set|

    describe "when #{param_set == {} ? "using default" : "specifying"} class parameters" do
      let :param_hash do
        default_params.merge(param_set)
      end

      let :params do
        param_set
      end

      it { should contain_class('keystone::params') }

      it { should contain_package('keystone').with(
        'ensure' => param_hash['package_ensure']
      ) }

      it { should contain_group('keystone').with(
          'ensure' => 'present',
          'system' => true
      ) }
      it { should contain_user('keystone').with(
        'ensure' => 'present',
        'gid'    => 'keystone',
        'system' => true
      ) }

      it 'should contain the expected directories' do
        ['/etc/keystone', '/var/log/keystone', '/var/lib/keystone'].each do |d|
          should contain_file(d).with(
            'ensure'     => 'directory',
            'owner'      => 'keystone',
            'group'      => 'keystone',
            'mode'       => '0750',
            'require'    => 'Package[keystone]'
          )
        end
      end

      it { should contain_service('keystone').with(
        'ensure'     => param_hash['enabled'] ? 'running' : 'stopped',
        'enable'     => param_hash['enabled'],
        'hasstatus'  => true,
        'hasrestart' => true
      ) }

      it 'should only migrate the db if $enabled is true' do
        if param_hash['enabled']
          should contain_exec('keystone-manage db_sync').with(
            :user        => 'keystone',
            :refreshonly => true,
            :notify      => 'Service[keystone]',
            :subscribe   => 'Package[keystone]',
            :require     => 'User[keystone]'
          )
        end
      end

      it 'should contain correct config' do
        [
          'admin_token',
          'bind_host',
          'public_port',
          'admin_port',
          'compute_port',
          'verbose',
          'debug'
        ].each do |config|
          should contain_keystone_config("DEFAULT/#{config}").with_value(param_hash[config])
        end
      end

      it 'should contain correct mysql config' do
        should contain_keystone_config('sql/idle_timeout').with_value(param_hash['idle_timeout'])
        should contain_keystone_config('sql/connection').with_value(param_hash['sql_connection'])
      end

      it { should contain_keystone_config('signing/token_format').with_value(
        param_hash['token_format']
      ) }
    end
  end
  describe 'when configuring signing token format' do
    describe 'when configuring as UUID' do
      let :params do
        {
          'admin_token'  => 'service_token',
          'token_format' => 'UUID'
        }
      end
      it { should_not contain_exec('keystone-manage pki_setup') }
    end
    describe 'when configuring as PKI' do
      let :params do
        {
          'admin_token'  => 'service_token',
          'token_format' => 'PKI'
        }
      end
      it { should contain_exec('keystone-manage pki_setup').with(
        :creates => '/etc/keystone/ssl/private/signing_key.pem'
      ) }
      it { should contain_file('/var/cache/keystone').with_ensure('directory') }
      describe 'when overriding the cache dir' do
        let :params do
          {
            'admin_token'  => 'service_token',
            'token_format' => 'PKI',
            'cache_dir'    => '/var/lib/cache/keystone'
          }
        end
        it { should contain_file('/var/lib/cache/keystone') }
      end
    end
  end
end
