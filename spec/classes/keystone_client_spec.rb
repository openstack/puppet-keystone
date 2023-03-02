require 'spec_helper'

describe 'keystone::client' do
  shared_examples 'keystone::client' do

    it { is_expected.to contain_class('keystone::deps') }

    context 'with default parameters' do
      it { should contain_package('python-keystoneclient').with(
        :ensure => 'present',
        :name   => platform_params[:client_package_name],
        :tag    => 'openstack',
      )}

      it { should contain_class('openstacklib::openstackclient') }
    end

    context 'with specified parameters' do
      let :params do
        {
          :client_package_name => 'package_name',
          :ensure              => '1.2.3',
        }
      end

      it { should contain_package('python-keystoneclient').with(
        :ensure => '1.2.3',
        :name   => 'package_name',
        :tag    => 'openstack',
      )}

      it { should contain_class('openstacklib::openstackclient') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          { :client_package_name => 'python3-keystoneclient' }
        when 'RedHat'
          { :client_package_name => 'python3-keystoneclient' }
        end
      end

      it_behaves_like 'keystone::client'
    end
  end
end
