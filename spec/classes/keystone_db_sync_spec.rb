require 'spec_helper'

describe 'keystone::db::sync' do
  shared_examples 'keystone::db::sync' do
    describe 'with only required params' do

      it { is_expected.to contain_class('keystone::deps') }

      it {
        is_expected.to contain_exec('keystone-manage db_sync').with(
          :command     => 'keystone-manage  db_sync',
          :path        => '/usr/bin',
          :user        => 'keystone',
          :try_sleep   => 5,
          :tries       => 10,
          :timeout     => 300,
          :refreshonly => true,
          :logoutput   => 'on_failure',
          :subscribe   => ['Anchor[keystone::install::end]',
                          'Anchor[keystone::config::end]',
                          'Anchor[keystone::dbsync::begin]'],
          :notify      => 'Anchor[keystone::dbsync::end]',
          :tag         => ['keystone-exec', 'openstack-db'],
        )
      }
    end

    describe "overriding params" do
      let :params do
        {
          :extra_params    => '--config-file /etc/keystone/keystone.conf',
          :keystone_user   => 'test_user',
          :db_sync_timeout => 750,
        }
      end

      it {
        is_expected.to contain_exec('keystone-manage db_sync').with(
          :command     => 'keystone-manage --config-file /etc/keystone/keystone.conf db_sync',
          :path        => '/usr/bin',
          :user        => 'test_user',
          :try_sleep   => 5,
          :tries       => 10,
          :timeout     => 750,
          :refreshonly => true,
          :logoutput   => 'on_failure',
          :subscribe   => ['Anchor[keystone::install::end]',
                          'Anchor[keystone::config::end]',
                          'Anchor[keystone::dbsync::begin]'],
          :notify      => 'Anchor[keystone::dbsync::end]',
          :tag         => ['keystone-exec', 'openstack-db'],
        )
      }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'keystone::db::sync'
    end
  end
end
