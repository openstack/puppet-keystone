require 'spec_helper'
describe 'keystone::roles::admin' do
  let :pre_condition do
    "class { 'keystone':
      admin_token => 'dummy',
      admin_password => 'ChangeMe' }"
  end

  let :facts do
    @default_facts.merge({
      :osfamily               => 'Debian',
      :operatingsystem        => 'Debian',
      :operatingsystemrelease => '7.0',
      :processorcount         => '1'
    })
  end

  describe 'with only the required params set' do
    let :params do
      {
        :email          => 'foo@bar',
        :password       => 'ChangeMe',
        :service_tenant => 'services'
      }
    end

    it { is_expected.to contain_keystone_tenant('services').with(
      :ensure      => 'present',
      :enabled     => true,
      :description => 'Tenant for the openstack services'
    )}
    it { is_expected.to contain_keystone_tenant('openstack').with(
      :ensure      => 'present',
      :enabled     => true,
      :description => 'admin tenant'
    )}
    it { is_expected.to contain_keystone_user('admin').with(
      :ensure                 => 'present',
      :enabled                => true,
      :email                  => 'foo@bar',
      :password               => 'ChangeMe',
    )}
    it { is_expected.to contain_keystone_role('admin').with_ensure('present') }
    it { is_expected.to contain_keystone_user_role('admin@openstack').with(
      :roles          => ['admin'],
      :ensure         => 'present',
      :user_domain    => nil,
      :project_domain => nil,
    )}

  end

  describe 'when overriding optional params' do
    let :pre_condition do
      "class { 'keystone':
        admin_token => 'dummy',
        admin_password => 'foo' }"
    end

    let :params do
      {
        :admin                  => 'admin',
        :email                  => 'foo@baz',
        :password               => 'foo',
        :admin_tenant           => 'admin',
        :admin_roles            => ['admin', 'heat_stack_owner'],
        :service_tenant         => 'foobar',
        :admin_tenant_desc      => 'admin something else',
        :service_tenant_desc    => 'foobar description',
      }
    end

    it { is_expected.to contain_keystone_tenant('foobar').with(
      :ensure      => 'present',
      :enabled     => true,
      :description => 'foobar description'
    )}
    it { is_expected.to contain_keystone_tenant('admin').with(
      :ensure      => 'present',
      :enabled     => true,
      :description => 'admin something else'
    )}
    it { is_expected.to contain_keystone_user('admin').with(
      :ensure                 => 'present',
      :enabled                => true,
      :email                  => 'foo@baz',
      :password               => 'foo',
    )}
    it { is_expected.to contain_keystone_user_role('admin@admin').with(
      :roles          => ['admin', 'heat_stack_owner'],
      :ensure         => 'present',
      :user_domain    => nil,
      :project_domain => nil,
    )}

  end

  describe 'when disabling user configuration' do
    before do
      let :params do
        {
          :configure_user => false
        }
      end

      it { is_expected.to_not contain_keystone_user('keystone') }
      it { is_expected.to contain_keystone_user_role('keystone@openstack') }
    end
  end

  describe 'when disabling user and role configuration' do
    before do
      let :params do
        {
          :configure_user      => false,
          :configure_user_role => false
        }
      end

      it { is_expected.to_not contain_keystone_user('keystone') }
      it { is_expected.to_not contain_keystone_user_role('keystone@openstack') }
    end
  end

  describe 'when specifying admin_user_domain and admin_project_domain' do
    let :params do
      {
        :email                => 'foo@bar',
        :password             => 'ChangeMe',
        :admin_tenant         => 'admin_tenant',
        :admin_user_domain    => 'admin_user_domain',
        :admin_project_domain => 'admin_project_domain',
      }
    end
    it { is_expected.to contain_keystone_user('admin').with(
      :domain => 'admin_user_domain',
    )}
    it { is_expected.to contain_keystone_tenant('admin_tenant').with(:domain => 'admin_project_domain') }
    it { is_expected.to contain_keystone_domain('admin_user_domain') }
    it { is_expected.to contain_keystone_domain('admin_project_domain') }
    it { is_expected.to contain_keystone_user_role('admin@admin_tenant').with(
      :roles          => ['admin'],
      :ensure         => 'present',
      :user_domain    => 'admin_user_domain',
      :project_domain => 'admin_project_domain',
    )}

  end

  describe 'when specifying admin_user_domain and admin_project_domain' do
    let :params do
      {
        :email                => 'foo@bar',
        :password             => 'ChangeMe',
        :admin_tenant         => 'admin_tenant::admin_project_domain',
        :admin_user_domain    => 'admin_user_domain',
        :admin_project_domain => 'admin_project_domain',
      }
    end
    it { is_expected.to contain_keystone_user('admin').with(
      :domain => 'admin_user_domain',
    )}
    it { is_expected.to contain_keystone_tenant('admin_tenant::admin_project_domain').with(:domain => 'admin_project_domain') }
    it { is_expected.to contain_keystone_domain('admin_user_domain') }
    it { is_expected.to contain_keystone_domain('admin_project_domain') }
    it { is_expected.to contain_keystone_user_role('admin@admin_tenant::admin_project_domain').with(
      :roles          => ['admin'],
      :ensure         => 'present',
      :user_domain    => 'admin_user_domain',
      :project_domain => 'admin_project_domain',
    )}

  end

  describe 'when specifying a service domain' do
    let :params do
      {
        :email                  => 'foo@bar',
        :password               => 'ChangeMe',
        :service_tenant         => 'service_project',
        :service_project_domain => 'service_domain'
      }
    end
    it { is_expected.to contain_keystone_tenant('service_project').with(:domain => 'service_domain') }
    it { is_expected.to contain_keystone_domain('service_domain') }

  end

  describe 'when specifying a service domain and service tenant domain' do
    let :params do
      {
        :email                  => 'foo@bar',
        :password               => 'ChangeMe',
        :service_tenant         => 'service_project::service_domain',
        :service_project_domain => 'service_domain'
      }
    end
    it { is_expected.to contain_keystone_tenant('service_project::service_domain').with(:domain => 'service_domain') }
    it { is_expected.to contain_keystone_domain('service_domain') }

  end

  describe 'when admin_user_domain and admin_project_domain are equal' do
    let :params do
      {
        :email                => 'foo@bar',
        :password             => 'ChangeMe',
        :admin_user_domain    => 'admin_domain',
        :admin_project_domain => 'admin_domain',
      }
    end
   it { is_expected.to contain_keystone_domain('admin_domain') }
  end

  describe 'when specifying a target admin domain' do
    let :params do
      {
        :email                  => 'foo@bar',
        :password               => 'ChangeMe',
        :admin_user_domain      => 'admin_domain',
        :admin_project_domain   => 'admin_domain',
        :target_admin_domain    => 'admin_domain_target'
      }
    end
    let :pre_condition do
      ["class { 'keystone':
        admin_token => 'dummy',
        admin_password => 'ChangeMe' }",
       "file { '/root/openrc': tag => ['openrc']}"]
    end
    it { is_expected.to contain_keystone_domain('admin_domain_target') }
    it { is_expected.to contain_keystone_user_role('admin@::admin_domain_target')
             .with(
               :roles          => ['admin'],
               :ensure         => 'present',
               :user_domain    => 'admin_domain',
             )
             .that_comes_before('File[/root/openrc]')
    }
  end

  describe 'when admin_password and password do not match' do
    let :pre_condition do
      "class { 'keystone':
        admin_token => 'dummy',
        admin_password => 'foo' }"
    end
    let :params do
      {
        :email          => 'foo@bar',
        :password       => 'bar',
        :service_tenant => 'services'
      }
    end
    it { is_expected.to contain_keystone_role('admin').with_ensure('present') }
    it { is_expected.to contain_keystone_user_role('admin@openstack').with(
      :roles          => ['admin'],
      :ensure         => 'present',
      :user_domain    => nil,
      :project_domain => nil,
    )}
  end
end
