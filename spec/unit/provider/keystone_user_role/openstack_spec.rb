require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_user_role/openstack'

setup_provider_tests

describe Puppet::Type.type(:keystone_user_role).provider(:openstack) do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  before(:each) { set_env }

  after(:each) { described_class.reset }

  describe 'when managing a user\'s role' do
    let(:resource_attrs) do
      {
        :title  => 'user1::domain1@project1::domain1',
        :ensure => 'present',
        :roles  => %w(role1 role2)
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_user_role.new(resource_attrs)
    end

    let(:provider) do
      described_class.new(resource)
    end

    describe '#create' do
      before(:each) do

        described_class.expects(:openstack)
          .with('role', 'list', '--quiet', '--format', 'csv',
                ['--project', 'project1_id', '--user', 'user1_id'])
          .returns('"ID","Name","Project","User"
"role1_id","role1","project1","user1"
"role2_id","role2","project1","user1"
')
        described_class.expects(:openstack)
          .with('role', 'add',
                ['role1', '--project', 'project1_id', '--user', 'user1_id'])
        described_class.expects(:openstack)
          .with('role', 'add',
                ['role2', '--project', 'project1_id', '--user', 'user1_id'])
        described_class.expects(:openstack)
          .with('project', 'show', '--format', 'shell',
                ['project1', '--domain', 'domain1'])
          .returns('name="project1"
id="project1_id"
')
        described_class.expects(:openstack)
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
          'all in the title' => {
            :title  => 'user1::domain1@project1::domain1',
            :ensure => 'present',
            :roles  => %w(role1 role2)
          }
        },
        {
          'user complete and project in the params' => {
            :title          => 'user1::domain1@project1',
            :ensure         => 'present',
            :project_domain => 'domain1',
            :roles          => %w(role1 role2)
          }
        },
        {
          'user and project in the params' => {
            :title          => 'user1@project1',
            :ensure         => 'present',
            :project_domain => 'domain1',
            :user_domain    => 'domain1',
            :roles          => %w(role1 role2)
          }
        },
        {
          'project complet and user in the params' => {
            :title       => 'user1@project1::domain1',
            :ensure      => 'present',
            :user_domain => 'domain1',
            :roles       => %w(role1 role2)
          }
        }
      ]
    end

    describe '#destroy' do
      it 'removes all the roles from a user' do
        provider.instance_variable_get('@property_hash')[:roles] = ['role1', 'role2']
        described_class.expects(:openstack)
          .with('role', 'remove',
                ['role1', '--project', 'project1_id', '--user', 'user1_id'])
        described_class.expects(:openstack)
          .with('role', 'remove',
                ['role2', '--project', 'project1_id', '--user', 'user1_id'])
        described_class.expects(:openstack)
          .with('project', 'show', '--format', 'shell',
                ['project1', '--domain', 'domain1'])
          .returns('name="project1"
id="project1_id"
')
        described_class.expects(:openstack)
          .with('user', 'show', '--format', 'shell',
                ['user1', '--domain', 'domain1'])
          .returns('name="user1"
id="user1_id"
')
        described_class.expects(:openstack)
          .with('role', 'list', '--quiet', '--format', 'csv',
                ['--project', 'project1_id', '--user', 'user1_id'])
          .returns('"ID","Name","Project","User"
')
        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end

    describe '#exists' do
      subject(:response) do
        described_class.expects(:openstack)
          .with('role', 'list', '--quiet', '--format', 'csv',
                ['--project', 'project1_id', '--user', 'user1_id'])
          .returns('"ID","Name","Project","User"
"role1_id","role1","project1","user1"
"role2_id","role2","project1","user1"
')
        described_class.expects(:openstack)
          .with('project', 'show', '--format', 'shell',
                ['project1', '--domain', 'domain1'])
          .returns('name="project1"
id="project1_id"
')
        described_class.expects(:openstack)
          .with('user', 'show', '--format', 'shell',
                ['user1', '--domain', 'domain1'])
          .returns('name="user1"
id="user1_id"
')
        provider.exists?
      end

      it { is_expected.to be_truthy }
    end

    describe '#roles=' do
      let(:resource_attrs) do
        {
          :title  => 'user_one@project_one',
          :ensure => 'present',
          :roles  => %w(one two)
        }
      end

      it 'applies new roles' do
        provider.expects(:roles).returns(%w(role_one role_two))
        described_class.expects(:openstack)
          .with('role', 'remove',
                ['role_one', '--project', 'project1_id', '--user', 'user1_id'])
        described_class.expects(:openstack)
          .with('role', 'remove',
                ['role_two', '--project', 'project1_id', '--user', 'user1_id'])
        described_class.expects(:openstack)
          .with('role', 'add',
                ['one', '--project', 'project1_id', '--user', 'user1_id'])
        described_class.expects(:openstack)
          .with('role', 'add',
                ['two', '--project', 'project1_id', '--user', 'user1_id'])
        described_class.expects(:openstack)
          .with('project', 'show', '--format', 'shell',
                ['project_one', '--domain', 'Default'])
          .returns('name="project_one"
id="project1_id"
')
        described_class.expects(:openstack)
          .with('user', 'show', '--format', 'shell',
                ['user_one', '--domain', 'Default'])
          .returns('name="role_one"
id="user1_id"
')
        provider.roles = %w(one two)
      end
    end

    context 'different name, identical resource' do
      let(:resources) do
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
