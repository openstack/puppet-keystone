require 'spec_helper'

describe 'keystone::federation' do

  let(:pre_condition) do
    <<-EOS
    class { 'keystone': }
    EOS
  end

  shared_examples_for 'keystone::federation' do
    context 'with defaults' do
      it 'should configure federation options' do
        is_expected.to contain_keystone_config('federation/trusted_dashboard').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('federation/remote_id_attribute').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with optional parameters' do
      let :params do
        {
          :trusted_dashboards  => ['http://dashboard.example.com'],
          :remote_id_attribute => 'test_attribute',
        }
      end

      it 'should configure federation options' do
        is_expected.to contain_keystone_config('federation/trusted_dashboard').with_value(['http://dashboard.example.com'])
        is_expected.to contain_keystone_config('federation/remote_id_attribute').with_value('test_attribute')
      end
    end
  end

  on_supported_os({
  }).each do |os,facts|
    let (:facts) do
      facts.merge!(OSDefaults.get_facts({}))
    end

    it_behaves_like 'keystone::federation'
  end
end
