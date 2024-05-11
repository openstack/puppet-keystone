require 'spec_helper'

describe 'keystone::bootstrap' do
  shared_examples 'keystone::bootstrap' do
    context 'with required parameters' do
      let :params do
        {
          :password => 'secret'
        }
      end

      it { is_expected.to contain_class('keystone::deps') }

      it { is_expected.to contain_exec('keystone bootstrap').with(
        :command     => 'keystone-manage bootstrap',
        :environment => [
          "OS_BOOTSTRAP_USERNAME=admin",
          "OS_BOOTSTRAP_PASSWORD=secret",
          "OS_BOOTSTRAP_PROJECT_NAME=admin",
          "OS_BOOTSTRAP_ROLE_NAME=admin",
          "OS_BOOTSTRAP_SERVICE_NAME=keystone",
          "OS_BOOTSTRAP_PUBLIC_URL=http://127.0.0.1:5000",
          "OS_BOOTSTRAP_REGION_ID=RegionOne",
          "OS_BOOTSTRAP_ADMIN_URL=http://127.0.0.1:5000",
          "OS_BOOTSTRAP_INTERNAL_URL=http://127.0.0.1:5000",
        ],
        :user        => platform_params[:user],
        :path        => '/usr/bin',
        :refreshonly => true,
        :subscribe   => 'Anchor[keystone::dbsync::end]',
        :notify      => 'Anchor[keystone::service::begin]',
        :tag         => 'keystone-bootstrap',
      )}

      it { is_expected.to contain_keystone_role('admin').with_ensure('present') }
      it { is_expected.to contain_keystone_role('manager').with_ensure('present') }
      it { is_expected.to contain_keystone_role('member').with_ensure('present') }
      it { is_expected.to contain_keystone_role('reader').with_ensure('present') }
      it { is_expected.to contain_keystone_role('service').with_ensure('present') }

      it { is_expected.to contain_keystone_implied_role('admin@manager').with_ensure('present') }
      it { is_expected.to contain_keystone_implied_role('manager@member').with_ensure('present') }
      it { is_expected.to contain_keystone_implied_role('member@reader').with_ensure('present') }

      it { is_expected.to contain_keystone_user('admin').with(
        :ensure   => 'present',
        :enabled  => true,
        :email    => 'admin@localhost',
        :password => 'secret',
      )}

      it { is_expected.to contain_keystone_tenant('services').with(
        :ensure  => 'present',
        :enabled => true,
      )}

      it { is_expected.to contain_keystone_tenant('admin').with(
        :ensure  => 'present',
        :enabled => true,
      )}

      it { is_expected.to contain_keystone_user_role('admin@admin').with(
        :ensure => 'present',
        :roles  => ['admin'],
      )}

      it { is_expected.to contain_keystone_user_role('admin@::::all').with(
        :ensure => 'present',
        :roles  => ['admin'],
      )}

      it { is_expected.to contain_keystone_service('keystone::identity').with_ensure('present') }

      it { is_expected.to contain_keystone_endpoint('RegionOne/keystone::identity').with(
        :ensure       => 'present',
        :public_url   => 'http://127.0.0.1:5000',
        :admin_url    => 'http://127.0.0.1:5000',
        :internal_url => 'http://127.0.0.1:5000',
      )}

      it { is_expected.to contain_file('/etc/openstack').with(
        :ensure  => 'directory',
        :mode    => '0755',
        :owner   => 'root',
        :group   => 'root',
      )}

      it { is_expected.to contain_file('/etc/openstack/puppet').with(
        :ensure  => 'directory',
        :mode    => '0755',
        :owner   => 'root',
        :group   => 'root',
      )}

      it { is_expected.to contain_openstacklib__clouds('/etc/openstack/puppet/admin-clouds.yaml').with(
        :username     => 'admin',
        :password     => 'secret',
        :auth_url     => 'http://127.0.0.1:5000',
        :project_name => 'admin',
        :system_scope => 'all',
        :region_name  => 'RegionOne',
        :interface    => 'public',
      )}
    end

    context 'with specified parameters' do
      let :params do
        {
          :password             => 'secret',
          :username             => 'user',
          :email                => 'some@email',
          :project_name         => 'adminproj',
          :service_project_name => 'serviceproj',
          :role_name            => 'adminrole',
          :service_name         => 'servicename',
          :admin_url            => 'http://admin:1234',
          :public_url           => 'http://public:4321',
          :internal_url         => 'http://internal:1342',
          :region               => 'RegionTwo',
          :interface            => 'admin'
        }
      end

      it { is_expected.to contain_class('keystone::deps') }

      it { is_expected.to contain_exec('keystone bootstrap').with(
        :command     => 'keystone-manage bootstrap',
        :environment => [
          "OS_BOOTSTRAP_USERNAME=user",
          "OS_BOOTSTRAP_PASSWORD=secret",
          "OS_BOOTSTRAP_PROJECT_NAME=adminproj",
          "OS_BOOTSTRAP_ROLE_NAME=adminrole",
          "OS_BOOTSTRAP_SERVICE_NAME=servicename",
          "OS_BOOTSTRAP_PUBLIC_URL=http://public:4321",
          "OS_BOOTSTRAP_REGION_ID=RegionTwo",
          "OS_BOOTSTRAP_ADMIN_URL=http://admin:1234",
          "OS_BOOTSTRAP_INTERNAL_URL=http://internal:1342",
        ],
        :user        => platform_params[:user],
        :path        => '/usr/bin',
        :refreshonly => true,
        :subscribe   => 'Anchor[keystone::dbsync::end]',
        :notify      => 'Anchor[keystone::service::begin]',
        :tag         => 'keystone-bootstrap',
      )}

      it { is_expected.to contain_keystone_role('adminrole').with_ensure('present') }
      it { is_expected.to contain_keystone_role('manager').with_ensure('present') }
      it { is_expected.to contain_keystone_role('member').with_ensure('present') }
      it { is_expected.to contain_keystone_role('reader').with_ensure('present') }
      it { is_expected.to contain_keystone_role('service').with_ensure('present') }

      it { is_expected.to contain_keystone_implied_role('adminrole@manager').with_ensure('present') }
      it { is_expected.to contain_keystone_implied_role('manager@member').with_ensure('present') }
      it { is_expected.to contain_keystone_implied_role('member@reader').with_ensure('present') }

      it { is_expected.to contain_keystone_user('user').with(
        :ensure   => 'present',
        :enabled  => true,
        :email    => 'some@email',
        :password => 'secret',
      )}

      it { is_expected.to contain_keystone_tenant('serviceproj').with(
        :ensure  => 'present',
        :enabled => true,
      )}

      it { is_expected.to contain_keystone_tenant('adminproj').with(
        :ensure  => 'present',
        :enabled => true,
      )}

      it { is_expected.to contain_keystone_user_role('user@adminproj').with(
        :ensure => 'present',
        :roles  => ['adminrole'],
      )}

      it { is_expected.to contain_keystone_user_role('user@::::all').with(
        :ensure => 'present',
        :roles  => ['adminrole'],
      )}

      it { is_expected.to contain_keystone_service('servicename::identity').with_ensure('present') }

      it { is_expected.to contain_keystone_endpoint('RegionTwo/servicename::identity').with(
        :ensure       => 'present',
        :public_url   => 'http://public:4321',
        :admin_url    => 'http://admin:1234',
        :internal_url => 'http://internal:1342',
      )}

      it { is_expected.to contain_file('/etc/openstack').with(
        :ensure  => 'directory',
        :mode    => '0755',
        :owner   => 'root',
        :group   => 'root',
      )}

      it { is_expected.to contain_file('/etc/openstack/puppet').with(
        :ensure  => 'directory',
        :mode    => '0755',
        :owner   => 'root',
        :group   => 'root',
      )}

      it { is_expected.to contain_openstacklib__clouds('/etc/openstack/puppet/admin-clouds.yaml').with(
        :username     => 'user',
        :password     => 'secret',
        :auth_url     => 'http://admin:1234',
        :project_name => 'adminproj',
        :region_name  => 'RegionTwo',
        :system_scope => 'all',
        :interface    => 'admin',
      )}
    end

    context 'with bootstrap disabled' do
      let :params do
        {
          :bootstrap => false,
          :password  => 'secret'
        }
      end

      it { is_expected.to contain_class('keystone::deps') }

      it { is_expected.to_not contain_exec('keystone bootstrap') }

      it { is_expected.to contain_keystone_role('admin') }
      it { is_expected.to contain_keystone_user('admin') }
      it { is_expected.to contain_keystone_tenant('services') }
      it { is_expected.to contain_keystone_tenant('admin') }
      it { is_expected.to contain_keystone_user_role('admin@admin') }
      it { is_expected.to contain_keystone_service('keystone::identity') }
      it { is_expected.to contain_keystone_endpoint('RegionOne/keystone::identity') }

      it { is_expected.to contain_file('/etc/openstack').with(
        :ensure  => 'directory',
        :mode    => '0755',
        :owner   => 'root',
        :group   => 'root',
      )}

      it { is_expected.to contain_file('/etc/openstack/puppet').with(
        :ensure  => 'directory',
        :mode    => '0755',
        :owner   => 'root',
        :group   => 'root',
      )}

      it { is_expected.to contain_openstacklib__clouds('/etc/openstack/puppet/admin-clouds.yaml').with(
        :username     => 'admin',
        :password     => 'secret',
        :auth_url     => 'http://127.0.0.1:5000',
        :project_name => 'admin',
        :system_scope => 'all',
        :region_name  => 'RegionOne',
        :interface    => 'public',
      )}
    end

    context 'when setting keystone_user param in keystone' do
      let :params do
        {
          :password => 'secret'
        }
      end

      let :pre_condition do
        "class { '::keystone':
           keystone_user => 'some',
         }"
      end

      it { is_expected.to contain_exec('keystone bootstrap').with_user('some') }
    end

    context 'with bootstrap enabled and manage_resource to false' do
      let :params do
        {
          :bootstrap        => false,
          :manage_resources => false,
          :password         => 'secret'
        }
      end

      it { is_expected.to contain_class('keystone::deps') }

      it { is_expected.to_not contain_exec('keystone bootstrap') }

      it { is_expected.to_not contain_keystone_role('admin') }
      it { is_expected.to_not contain_keystone_user('admin') }
      it { is_expected.to_not contain_keystone_tenant('services') }
      it { is_expected.to_not contain_keystone_tenant('admin') }
      it { is_expected.to_not contain_keystone_user_role('admin@admin') }
      it { is_expected.to_not contain_keystone_service('keystone::identity') }
      it { is_expected.to_not contain_keystone_endpoint('RegionOne/keystone::identity') }
    end

    context 'when setting interface to internal' do
      let :params do
        {
          :password     => 'secret',
          :internal_url => 'http://internal:1234',
          :interface    => 'internal',
        }
      end

      it { is_expected.to contain_openstacklib__clouds('/etc/openstack/puppet/admin-clouds.yaml').with(
        :auth_url  => 'http://internal:1234',
        :interface => 'internal',
      )}
    end

    context 'when admin endpoint is omitted' do
      let :params do
        {
          :password  => 'secret',
          :admin_url => '',
        }
      end

      it { is_expected.to contain_exec('keystone bootstrap').with(
        :command     => 'keystone-manage bootstrap',
        :environment => [
          "OS_BOOTSTRAP_USERNAME=admin",
          "OS_BOOTSTRAP_PASSWORD=secret",
          "OS_BOOTSTRAP_PROJECT_NAME=admin",
          "OS_BOOTSTRAP_ROLE_NAME=admin",
          "OS_BOOTSTRAP_SERVICE_NAME=keystone",
          "OS_BOOTSTRAP_PUBLIC_URL=http://127.0.0.1:5000",
          "OS_BOOTSTRAP_REGION_ID=RegionOne",
          "OS_BOOTSTRAP_INTERNAL_URL=http://127.0.0.1:5000",
        ],
        :user        => platform_params[:user],
        :path        => '/usr/bin',
        :refreshonly => true,
        :subscribe   => 'Anchor[keystone::dbsync::end]',
        :notify      => 'Anchor[keystone::service::begin]',
        :tag         => 'keystone-bootstrap',
      )}
      it { is_expected.to contain_keystone_endpoint('RegionOne/keystone::identity').with(
        :ensure       => 'present',
        :public_url   => 'http://127.0.0.1:5000',
        :internal_url => 'http://127.0.0.1:5000',
      )}
    end

    context 'when internal endpoint is omitted' do
      let :params do
        {
          :password     => 'secret',
          :internal_url => '',
        }
      end

      it { is_expected.to contain_exec('keystone bootstrap').with(
        :command     => 'keystone-manage bootstrap',
        :environment => [
          "OS_BOOTSTRAP_USERNAME=admin",
          "OS_BOOTSTRAP_PASSWORD=secret",
          "OS_BOOTSTRAP_PROJECT_NAME=admin",
          "OS_BOOTSTRAP_ROLE_NAME=admin",
          "OS_BOOTSTRAP_SERVICE_NAME=keystone",
          "OS_BOOTSTRAP_PUBLIC_URL=http://127.0.0.1:5000",
          "OS_BOOTSTRAP_REGION_ID=RegionOne",
          "OS_BOOTSTRAP_ADMIN_URL=http://127.0.0.1:5000",
        ],
        :user        => platform_params[:user],
        :path        => '/usr/bin',
        :refreshonly => true,
        :subscribe   => 'Anchor[keystone::dbsync::end]',
        :notify      => 'Anchor[keystone::service::begin]',
        :tag         => 'keystone-bootstrap',
      )}
      it { is_expected.to contain_keystone_endpoint('RegionOne/keystone::identity').with(
        :ensure       => 'present',
        :public_url   => 'http://127.0.0.1:5000',
        :admin_url    => 'http://127.0.0.1:5000',
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        { :user => 'keystone' }
      end

      it_behaves_like 'keystone::bootstrap'
    end
  end
end
