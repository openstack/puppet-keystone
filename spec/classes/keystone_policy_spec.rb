require 'spec_helper'

describe 'keystone::policy' do
  shared_examples 'keystone::policy' do

    context 'setup policy with parameters' do
      let :params do
        {
          :enforce_scope        => false,
          :enforce_new_defaults => false,
          :policy_path          => '/etc/keystone/policy.yaml',
          :policy_dirs          => '/etc/keystone/policy.d',
          :policies             => {
            'context_is_admin' => {
              'key'   => 'context_is_admin',
              'value' => 'foo:bar'
            }
          }
        }
      end

      it 'set up the policies' do
        is_expected.to contain_openstacklib__policy('/etc/keystone/policy.yaml').with(
          :policies     => {
            'context_is_admin' => {
              'key'   => 'context_is_admin',
              'value' => 'foo:bar'
            }
          },
          :policy_path  => '/etc/keystone/policy.yaml',
          :file_user    => 'root',
          :file_group   => 'keystone',
          :file_format  => 'yaml',
          :purge_config => false,
          :tag          => 'keystone',
        )
        is_expected.to contain_oslo__policy('keystone_config').with(
          :enforce_scope        => false,
          :enforce_new_defaults => false,
          :policy_file          => '/etc/keystone/policy.yaml',
          :policy_dirs          => '/etc/keystone/policy.d',
        )
      end
    end

    context 'with empty policies and purge_config enabled' do
      let :params do
        {
          :enforce_scope        => false,
          :enforce_new_defaults => false,
          :policy_path          => '/etc/keystone/policy.yaml',
          :policies             => {},
          :purge_config         => true,
        }
      end

      it 'set up the policies' do
        is_expected.to contain_openstacklib__policy('/etc/keystone/policy.yaml').with(
          :policies     => {},
          :policy_path  => '/etc/keystone/policy.yaml',
          :file_user    => 'root',
          :file_group   => 'keystone',
          :file_format  => 'yaml',
          :purge_config => true,
          :tag          => 'keystone',
        )
        is_expected.to contain_oslo__policy('keystone_config').with(
          :enforce_scope        => false,
          :enforce_new_defaults => false,
          :policy_file          => '/etc/keystone/policy.yaml',
        )
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'keystone::policy'
    end
  end
end
