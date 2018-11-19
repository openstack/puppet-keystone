require 'spec_helper'

describe 'keystone::config' do

  let(:config_hash) do {
    'DEFAULT/foo' => { 'value'  => 'fooValue' },
    'DEFAULT/bar' => { 'value'  => 'barValue' },
    'DEFAULT/baz' => { 'ensure' => 'absent' }
  }
  end

  shared_examples_for 'keystone_config' do
    let :params do
      { :keystone_config => config_hash }
    end

    it { is_expected.to contain_class('keystone::deps') }

    it 'configures arbitrary keystone-config configurations' do
      is_expected.to contain_keystone_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_keystone_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_keystone_config('DEFAULT/baz').with_ensure('absent')
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'keystone_config'
    end
  end
end
