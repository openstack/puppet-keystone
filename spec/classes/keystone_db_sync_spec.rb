require 'spec_helper'

describe 'keystone::db::sync' do

  describe 'with only required params' do
    it {
        is_expected.to contain_exec('keystone-manage db_sync').with(
          :command     => 'keystone-manage  db_sync',
          :refreshonly => true,
          :subscribe   => ['Anchor[keystone::install::end]',
                          'Anchor[keystone::config::end]',
                          'Anchor[keystone::dbsync::begin]'],
          :notify      => 'Anchor[keystone::dbsync::end]',
        )
    }
  end

  describe "overriding extra_params" do
    let :params do
      {
        :extra_params => '--config-file /etc/keystone/keystone.conf',
      }
    end

    it {
        is_expected.to contain_exec('keystone-manage db_sync').with(
          :command     => 'keystone-manage --config-file /etc/keystone/keystone.conf db_sync',
          :refreshonly => true,
          :subscribe   => ['Anchor[keystone::install::end]',
                          'Anchor[keystone::config::end]',
                          'Anchor[keystone::dbsync::begin]'],
          :notify      => 'Anchor[keystone::dbsync::end]',
        )
    }
  end

end
