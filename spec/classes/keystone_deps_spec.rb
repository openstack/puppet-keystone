require 'spec_helper'

describe 'keystone::deps' do
  shared_examples 'keystone::deps' do
    context 'with default params' do
      it {
        is_expected.to contain_anchor('keystone::install::begin')
        is_expected.to contain_anchor('keystone::install::end')
        is_expected.to contain_anchor('keystone::config::begin')
        is_expected.to contain_anchor('keystone::config::end')
        is_expected.to contain_anchor('keystone::db::begin')
        is_expected.to contain_anchor('keystone::db::end')
        is_expected.to contain_anchor('keystone::dbsync::begin')
        is_expected.to contain_anchor('keystone::dbsync::end')
        is_expected.to contain_anchor('keystone::service::begin')
        is_expected.to contain_anchor('keystone::service::end')
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

      it_behaves_like 'keystone::deps'
    end
  end
end
