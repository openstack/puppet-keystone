require 'spec_helper'

describe 'keystone::db::sync' do

  shared_examples_for 'keystone-dbsync' do

    describe 'with only required params' do
      it {
        is_expected.to contain_exec('keystone-manage db_sync').with(
          :command     => 'keystone-manage  db_sync',
          :user        => 'keystone',
          :refreshonly => true,
          :subscribe   => ['Anchor[keystone::install::end]',
                          'Anchor[keystone::config::end]',
                          'Anchor[keystone::dbsync::begin]'],
          :notify      => 'Anchor[keystone::dbsync::end]',
        )
      }
    end

    describe "overriding extra_params and keystone user" do
      let :params do
        {
          :extra_params  => '--config-file /etc/keystone/keystone.conf',
          :keystone_user => 'test_user',
        }
      end

      it {
        is_expected.to contain_exec('keystone-manage db_sync').with(
          :command     => 'keystone-manage --config-file /etc/keystone/keystone.conf db_sync',
          :user        => 'test_user',
          :refreshonly => true,
          :subscribe   => ['Anchor[keystone::install::end]',
                          'Anchor[keystone::config::end]',
                          'Anchor[keystone::dbsync::begin]'],
          :notify      => 'Anchor[keystone::dbsync::end]',
        )
      }
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'keystone-dbsync'
    end
  end

end
