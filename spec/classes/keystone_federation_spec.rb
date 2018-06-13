require 'spec_helper'

describe 'keystone::federation' do

  let(:pre_condition) do
    <<-EOS
    class { 'keystone':
      admin_token => 'service_token',
      admin_password => 'special_password',
    }
    EOS
  end

  let :params do
    { :trusted_dashboards => ['http://dashboard.example.com'],
      :remote_id_attribute => 'test_attribute',
     }
  end

  on_supported_os({
  }).each do |os,facts|
    let (:facts) do
      facts.merge!(OSDefaults.get_facts({}))
    end

    context 'with optional parameters' do
      it 'should set federation/trusted_dashboard' do
        is_expected.to contain_keystone_config('federation/trusted_dashboard').with_value(['http://dashboard.example.com'])
      end

      it 'should set federation/remote_id_attribute' do
        is_expected.to contain_keystone_config('federation/remote_id_attribute').with_value('test_attribute')
      end
    end
  end
end
