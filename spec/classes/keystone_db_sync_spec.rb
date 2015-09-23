require 'spec_helper'

describe 'keystone::db::sync' do

  describe 'with only required params' do
    it {
        is_expected.to contain_exec('keystone-manage db_sync').with(
          :command     => 'keystone-manage  db_sync',
          :user        => 'keystone',
          :refreshonly => true,
          :subscribe   => ['Package[keystone]', 'Keystone_config[database/connection]'],
          :require     => 'User[keystone]'
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
          :user        => 'keystone',
          :refreshonly => true,
          :subscribe   => ['Package[keystone]', 'Keystone_config[database/connection]'],
          :require     => 'User[keystone]'
        )
    }
  end

end
