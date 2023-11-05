require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_user_role/openstack'

setup_provider_tests

describe Puppet::Type.type(:keystone_user_role).provider(:openstack) do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_SYSTEM_SCOPE'] = 'all'
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
        expect(described_class).to receive(:openstack)
          .with('role assignment', 'list', '--quiet', '--format', 'csv',
                ['--names',
                 '--project', 'project1', '--project-domain', 'domain1',
                 '--user', 'user1', '--user-domain', 'domain1'])
          .and_return('"ID","Name","Project","User"
"role1_id","role1","project1","user1"
"role2_id","role2","project1","user1"
')
        expect(described_class).to receive(:openstack)
          .with('role', 'add',
                ['role1',
                 '--project', 'project1', '--project-domain', 'domain1',
                 '--user', 'user1', '--user-domain', 'domain1'])
        expect(described_class).to receive(:openstack)
          .with('role', 'add',
                ['role2',
                 '--project', 'project1', '--project-domain', 'domain1',
                 '--user', 'user1', '--user-domain', 'domain1'])
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
        expect(described_class).to receive(:openstack)
          .with('role', 'remove',
                ['role1',
                 '--project', 'project1', '--project-domain', 'domain1',
                 '--user', 'user1', '--user-domain', 'domain1'])
        expect(described_class).to receive(:openstack)
          .with('role', 'remove',
                ['role2',
                 '--project', 'project1', '--project-domain', 'domain1',
                 '--user', 'user1', '--user-domain', 'domain1'])
        expect(described_class).to receive(:openstack)
          .with('role assignment', 'list', '--quiet', '--format', 'csv',
                ['--names',
                 '--project', 'project1', '--project-domain', 'domain1',
                 '--user', 'user1', '--user-domain', 'domain1'])
          .and_return('"ID","Name","Project","User"
')
        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end

    describe '#exists' do
      subject(:response) do
        expect(described_class).to receive(:openstack)
          .with('role assignment', 'list', '--quiet', '--format', 'csv',
                ['--names',
                 '--project', 'project1', '--project-domain', 'domain1',
                 '--user', 'user1', '--user-domain', 'domain1'])
          .and_return('"ID","Name","Project","User"
"role1_id","role1","project1","user1"
"role2_id","role2","project1","user1"
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
        expect(provider).to receive(:roles).and_return(%w(role_one role_two))
        expect(described_class).to receive(:openstack)
          .with('role', 'remove',
                ['role_one',
                 '--project', 'project_one', '--project-domain', 'Default',
                 '--user', 'user_one', '--user-domain', 'Default'])
        expect(described_class).to receive(:openstack)
          .with('role', 'remove',
                ['role_two',
                 '--project', 'project_one', '--project-domain', 'Default',
                 '--user', 'user_one', '--user-domain', 'Default'])
        expect(described_class).to receive(:openstack)
          .with('role', 'add',
                ['one',
                 '--project', 'project_one', '--project-domain', 'Default',
                 '--user', 'user_one', '--user-domain', 'Default'])
        expect(described_class).to receive(:openstack)
          .with('role', 'add',
                ['two',
                 '--project', 'project_one', '--project-domain', 'Default',
                 '--user', 'user_one', '--user-domain', 'Default'])
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
