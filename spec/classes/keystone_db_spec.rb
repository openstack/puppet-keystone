require 'spec_helper'

describe 'keystone::db' do

  shared_examples 'keystone::db' do

    context 'with default parameters' do

      it { is_expected.to contain_oslo__db('keystone_config').with(
        :db_max_retries => '<SERVICE DEFAULT>',
        :connection     => 'sqlite:////var/lib/keystone/keystone.sqlite',
        :idle_timeout   => '<SERVICE DEFAULT>',
        :min_pool_size  => '<SERVICE DEFAULT>',
        :max_pool_size  => '<SERVICE DEFAULT>',
        :max_retries    => '<SERVICE DEFAULT>',
        :retry_interval => '<SERVICE DEFAULT>',
        :max_overflow   => '<SERVICE DEFAULT>',
        :pool_timeout   => '<SERVICE DEFAULT>',
      )}

    end

    context 'with specific parameters' do
      let :params do
        { :database_db_max_retries => '-1',
          :database_connection     => 'mysql+pymysql://keystone:keystone@localhost/keystone',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_max_pool_size  => '21',
          :database_max_retries    => '11',
          :database_max_overflow   => '21',
          :database_pool_timeout   => '21',
          :database_retry_interval => '11', }
      end

      it { is_expected.to contain_oslo__db('keystone_config').with(
        :db_max_retries => '-1',
        :connection     => 'mysql+pymysql://keystone:keystone@localhost/keystone',
        :idle_timeout   => '3601',
        :min_pool_size  => '2',
        :max_pool_size  => '21',
        :max_retries    => '11',
        :retry_interval => '11',
        :max_overflow   => '21',
        :pool_timeout   => '21',
      )}
    end

    context 'with MySQL-python library as backend package' do
      let :params do
        { :database_connection => 'mysql://keystone:keystone@localhost/keystone' }
      end

      it { is_expected.to contain_package('python-mysqldb').with(:ensure => 'present') }
    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection => 'postgresql://keystone:keystone@localhost/keystone', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-psycopg2').with(:ensure => 'present')
      end

    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection => 'redis://keystone:keystone@localhost/keystone', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

    context 'with incorrect pymysql database_connection string' do
      let :params do
        { :database_connection => 'foo+pymysql://keystone:keystone@localhost/keystone', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'Debian',
        :operatingsystem => 'Debian',
        :operatingsystemrelease => 'jessie',
      })
    end

    it_configures 'keystone::db'

    context 'using pymysql driver' do
      let :params do
        { :database_connection => 'mysql+pymysql://keystone:keystone@localhost/keystone', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-pymysql').with(
          :ensure => 'present',
          :name   => 'python-pymysql',
          :tag    => ['openstack']
        )
      end
    end
  end

  context 'on Redhat platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'RedHat',
        :operatingsystemrelease => '7.1',
      })
    end

    it_configures 'keystone::db'

    context 'using pymysql driver' do
      let :params do
        { :database_connection => 'mysql+pymysql://keystone:keystone@localhost/keystone', }
      end
    end
  end

end
