require 'spec_helper'

describe 'keystone::db' do

  shared_examples 'keystone::db' do

    context 'with default parameters' do

      it { is_expected.to contain_keystone_config('database/connection').with_value('sqlite:////var/lib/keystone/keystone.sqlite').with_secret(true) }
      it { is_expected.to contain_keystone_config('database/idle_timeout').with_value('3600') }
      it { is_expected.to contain_keystone_config('database/min_pool_size').with_value('1') }
      it { is_expected.to contain_keystone_config('database/max_pool_size').with_value('10') }
      it { is_expected.to contain_keystone_config('database/max_overflow').with_value('20') }
      it { is_expected.to contain_keystone_config('database/max_retries').with_value('10') }
      it { is_expected.to contain_keystone_config('database/retry_interval').with_value('10') }

    end

    context 'with specific parameters' do
      let :params do
        { :database_connection     => 'mysql://keystone:keystone@localhost/keystone',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_max_pool_size  => '21',
          :database_max_retries    => '11',
          :database_max_overflow   => '21',
          :database_retry_interval => '11', }
      end

      it { is_expected.to contain_keystone_config('database/connection').with_value('mysql://keystone:keystone@localhost/keystone').with_secret(true) }
      it { is_expected.to contain_keystone_config('database/idle_timeout').with_value('3601') }
      it { is_expected.to contain_keystone_config('database/min_pool_size').with_value('2') }
      it { is_expected.to contain_keystone_config('database/max_retries').with_value('11') }
      it { is_expected.to contain_keystone_config('database/max_pool_size').with_value('21') }
      it { is_expected.to contain_keystone_config('database/max_overflow').with_value('21') }
      it { is_expected.to contain_keystone_config('database/retry_interval').with_value('11') }

    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection     => 'postgresql://keystone:keystone@localhost/keystone', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-psycopg2').with(:ensure => 'present')
      end

    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection     => 'redis://keystone:keystone@localhost/keystone', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian',
        :operatingsystem => 'Debian',
        :operatingsystemrelease => 'jessie',
      }
    end

    it_configures 'keystone::db'
  end

  context 'on Redhat platforms' do
    let :facts do
      { :osfamily => 'RedHat',
        :operatingsystemrelease => '7.1',
      }
    end

    it_configures 'keystone::db'
  end

end
