require 'spec_helper'

describe 'keystone::service' do
  shared_examples 'keystone::service' do
    let :params do
      {}
    end

    context 'with default parameters' do
      it { is_expected.to contain_service('keystone').with(
        :ensure     => nil,
        :name       => platform_params[:service_name],
        :enable     => true,
        :hasstatus  => true,
        :hasrestart => true,
        :tag        => 'keystone-service',
      )}
    end

    context 'with overriden parameters' do
      before do
        params.merge!(
          :ensure     => 'present',
          :enable     => false,
          :hasstatus  => false,
          :hasrestart => false
        )
      end

      it { is_expected.to contain_service('keystone').with(
        :ensure     => 'present',
        :name       => platform_params[:service_name],
        :enable     => false,
        :hasstatus  => false,
        :hasrestart => false,
      )}
    end

    context 'with service_name set to keystone-public-keystone-admin' do
      before do
        params.merge!( :service_name => 'keystone-public-keystone-admin' )
      end

      it { is_expected.to contain_service('keystone-public').with(
        :ensure     => nil,
        :name       => 'keystone-public',
        :enable     => true,
        :hasstatus  => true,
        :hasrestart => true,
        :tag        => 'keystone-service',
      )}

      it { is_expected.to contain_service('keystone-admin').with(
        :ensure     => nil,
        :name       => 'keystone-admin',
        :enable     => true,
        :hasstatus  => true,
        :hasrestart => true,
        :tag        => 'keystone-service',
      )}
    end

    context 'with overriden parameters and service_name set to keystone-public-keystone-admin' do
      before do
        params.merge!(
          :ensure       => 'present',
          :service_name => 'keystone-public-keystone-admin',
          :enable       => false,
          :hasstatus    => false,
          :hasrestart   => false
        )
      end

      it { is_expected.to contain_service('keystone-public').with(
        :ensure     => 'present',
        :name       => 'keystone-public',
        :enable     => false,
        :hasstatus  => false,
        :hasrestart => false,
      )}

      it { is_expected.to contain_service('keystone-admin').with(
        :ensure     => 'present',
        :name       => 'keystone-admin',
        :enable     => false,
        :hasstatus  => false,
        :hasrestart => false,
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os, facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        if facts[:osfamily ] == 'RedHat'
          { :service_name => 'openstack-keystone' }
        else
          { :service_name => 'keystone' }
        end
      end

      it_behaves_like 'keystone::service'
    end
  end
end
