require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_user_role/openstack'

setup_provider_tests

provider_class = Puppet::Type.type(:keystone_user_role).provider(:openstack)

describe provider_class do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  before(:each) { set_env }

  after(:each) { provider_class.reset }

  describe 'when managing a user\'s role' do
    let(:resource_attrs) do
      Puppet::Provider::Keystone.expects(:default_domain).twice.returns('Default')
      {
        :title        => 'user1::domain1@project1::domain1',
        :ensure       => 'present',
        :roles        => %w(role1 role2)
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_user_role.new(resource_attrs)
    end

    let(:provider) do
      provider_class.new(resource)
    end

    describe '#create' do
      before(:each) do

        provider_class.expects(:openstack)
          .with('role', 'list', '--quiet', '--format', 'csv',
          ['--project', 'project1_id', '--user', 'user1_id' ])
          .returns('"ID","Name","Project","User"
"role1_id","role1","project1","user1"
"role2_id","role2","project1","user1"
')
        provider_class.expects(:openstack)
          .with('role', 'add',
          ['role1', '--project', 'project1_id', '--user', 'user1_id'])
        provider_class.expects(:openstack)
          .with('role', 'add',
          ['role2', '--project', 'project1_id', '--user', 'user1_id'])
        provider_class.expects(:openstack)
          .with('project', 'show', '--format', 'shell',
          ['project1', '--domain', 'domain1'])
          .returns('name="project1"
id="project1_id"
')
        provider_class.expects(:openstack)
          .with('user', 'show', '--format', 'shell',
          ['user1', '--domain', 'domain1'])
          .returns('name="user1"
id="user1_id"
')
      end
      include_examples 'create the correct resource', [
        {
          'expected_results' => {}
        },
        {
          :name       => 'domain1',
          :times      => 4,
          :attributes => {
            'Default' => {
              :title  => 'user1@project1',
              :ensure => 'present',
              :roles  => %w(role1 role2)
            }
          }
        },
        {
          'all in the title' => {
            :title  => 'user1::domain1@project1::domain1',
            :ensure => 'present',
            :roles  => %w(role1 role2),
            :default_domain => 2
          }
        },
        {
          'user complete and project in the params' => {
            :title          => 'user1::domain1@project1',
            :ensure         => 'present',
            :project_domain => 'domain1',
            :roles          => %w(role1 role2),
            :default_domain => 2
          }
        },
        {
          'user and project in the params' => {
            :title          => 'user1@project1',
            :ensure         => 'present',
            :project_domain => 'domain1',
            :user_domain    => 'domain1',
            :roles          => %w(role1 role2),
            :default_domain => 2
          }
        },
        {
          'project complet and user in the params' => {
            :title       => 'user1@project1::domain1',
            :ensure      => 'present',
            :user_domain => 'domain1',
            :roles       => %w(role1 role2),
            :default_domain => 2
          }
        },
      ]
    end

    describe '#destroy' do
      it 'removes all the roles from a user' do
        provider.instance_variable_get('@property_hash')[:roles] = ['role1', 'role2']
        provider.class.expects(:openstack)
          .with('role', 'remove', ['role1', '--project', 'project1_id', '--user', 'user1_id'])
        provider.class.expects(:openstack)
          .with('role', 'remove', ['role2', '--project', 'project1_id', '--user', 'user1_id'])
        provider.class.expects(:openstack)
          .with('project', 'show', '--format', 'shell', ['project1', '--domain', 'domain1'])
          .returns('name="project1"
id="project1_id"
')
        provider.class.expects(:openstack)
          .with('user', 'show', '--format', 'shell', ['user1', '--domain', 'domain1'])
          .returns('name="user1"
id="user1_id"
')
        provider.class.expects(:openstack)
          .with('role', 'list', '--quiet', '--format', 'csv', ['--project', 'project1_id', '--user', 'user1_id'])
          .returns('"ID","Name","Project","User"
')
        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end

    describe '#exists' do
      subject(:response) do
        provider.class.expects(:openstack)
          .with('role', 'list', '--quiet', '--format', 'csv', ['--project', 'project1_id', '--user', 'user1_id' ])
          .returns('"ID","Name","Project","User"
"role1_id","role1","project1","user1"
"role2_id","role2","project1","user1"
')
        provider.class.expects(:openstack)
          .with('project', 'show', '--format', 'shell', ['project1', '--domain', 'domain1'])
          .returns('name="project1"
id="project1_id"
')
        provider.class.expects(:openstack)
          .with('user', 'show', '--format', 'shell', ['user1', '--domain', 'domain1'])
          .returns('name="user1"
id="user1_id"
')
        provider.exists?
      end

      it { is_expected.to be_truthy }
    end

    describe '#instances' do
      it 'finds every user role' do
        project_class = Puppet::Type.type(:keystone_tenant).provider(:openstack)
        user_class = Puppet::Type.type(:keystone_user).provider(:openstack)

        usermock = user_class.new(:id => 'user1_id', :name => 'user1')
        user_class.expects(:instances).with(any_parameters).returns([usermock])

        projectmock = project_class.new(:id => 'project1_id', :name => 'project1')
        # 2 for tenant and user and 2 for user_role
        Puppet::Provider::Keystone.expects(:default_domain).times(4).returns('Default')
        project_class.expects(:instances).with(any_parameters).returns([projectmock])

        provider.class.expects(:openstack)
          .with('role', 'list', '--quiet', '--format', 'csv', [])
          .returns('"ID","Name"
"role1-id","role1"
"role2-id","role2"
')
        provider.class.expects(:openstack)
          .with('role assignment', 'list', '--quiet', '--format', 'csv', [])
          .returns('
"Role","User","Group","Project","Domain"
"role1-id","user1_id","","project1_id","Default"
"role2-id","user1_id","","project1_id","Default"
')
        instances = provider.class.instances
        expect(instances.count).to eq(1)
        expect(instances[0].name).to eq('user1@project1')
        expect(instances[0].roles).to eq(['role1', 'role2'])
        expect(instances[0].user).to eq('user1')
        expect(instances[0].user_domain).to eq('Default')
        expect(instances[0].project).to eq('project1')
        expect(instances[0].project_domain).to eq('Default')
      end
    end

    describe '#roles=' do
      let(:resource_attrs) do
        {
          :title        => 'foo@foo',
          :ensure       => 'present',
          :roles        => ['one', 'two'],
        }
      end

      it 'applies new roles' do
        Puppet::Provider::Keystone.expects(:default_domain).times(4).returns('Default')
        provider.instance_variable_get('@property_hash')[:roles] = ['foo', 'bar']
        provider.class.expects(:openstack)
          .with('role', 'remove', ['foo', '--project', 'project1_id', '--user', 'user1_id'])
        provider.class.expects(:openstack)
          .with('role', 'remove', ['bar', '--project', 'project1_id', '--user', 'user1_id'])
        provider.class.expects(:openstack)
          .with('role', 'add', ['one', '--project', 'project1_id', '--user', 'user1_id'])
        provider.class.expects(:openstack)
          .with('role', 'add', ['two', '--project', 'project1_id', '--user', 'user1_id'])
        provider.class.expects(:openstack)
          .with('project', 'show', '--format', 'shell', ['foo', '--domain', 'Default'])
          .returns('name="foo"
id="project1_id"
')
        provider.class.expects(:openstack)
          .with('user', 'show', '--format', 'shell', ['foo', '--domain', 'Default'])
          .returns('name="foo"
id="user1_id"
')
        provider.roles = %w(one two)
      end
    end

    context 'different name, identical resource' do
      let(:resources) do
        Puppet::Provider::Keystone.expects(:default_domain).times(4).returns('Default')
        [
          Puppet::Type.type(:keystone_user_role)
            .new(:title => 'user::domain_user@project::domain_project',
                 :ensure => :present),
          Puppet::Type.type(:keystone_user_role)
            .new(:title => 'user@project',
                 :user_domain => 'domain_user',
                 :project_domain => 'domain_project',
                 :ensure => :present)
        ]
      end
      include_examples 'detect duplicate resource'
    end
  end
end
