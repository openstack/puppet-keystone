require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_user/openstack'
require 'puppet/provider/openstack'

setup_provider_tests

describe Puppet::Type.type(:keystone_user).provider(:openstack) do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  after :each do
    described_class.reset
    Puppet::Type.type(:keystone_tenant).provider(:openstack).reset
  end

  let(:resource_attrs) do
    {
      :name          => 'user1',
      :ensure        => :present,
      :enabled       => 'True',
      :password      => 'secret',
      :email         => 'user1@example.com',
      :domain        => 'domain1'
    }
  end

  let(:resource) do
    Puppet::Type::Keystone_user.new(resource_attrs)
  end

  let(:provider) do
    described_class.new(resource)
  end

  before(:each) { set_env }

  describe 'when managing a user' do
    describe '#create' do
      it 'creates a user' do
        described_class.expects(:openstack)
          .with('user', 'create', '--format', 'shell', ['user1', '--enable', '--password', 'secret', '--email', 'user1@example.com', '--domain', 'domain1'])
          .returns('email="user1@example.com"
enabled="True"
id="user1_id"
name="user1"
username="user1"
')
        provider.create
        expect(provider.exists?).to be_truthy
      end
    end

    describe '#destroy' do
      it 'destroys a user' do
        provider.expects(:id).returns('my-user-id')
        described_class.expects(:openstack)
          .with('user', 'delete', 'my-user-id')
        provider.destroy
      end
    end

    describe '#exists' do
      context 'when user does not exist' do
        it 'should detect it' do
          described_class.expects(:openstack)
            .with('domain', 'list', '--quiet', '--format', 'csv', [])
            .returns('"ID","Name","Enabled","Description"
"default","Default",True,"default"
"domain1_id","domain1",True,"domain1"
"domain2_id","domain2",True,"domain2"
"domain3_id","domain3",True,"domain3"
')
          described_class.expects(:openstack)
            .with('user', 'show', '--format', 'shell',
                  ['user1', '--domain', 'domain1_id'])
            .once
            .raises(Puppet::ExecutionFailure,
                    "No user with a name or ID of 'user1' exists.")
          expect(provider.exists?).to be_falsey
        end
      end
    end

    describe '#flush' do
      context '.enable' do
        describe '-> false' do
          it 'properly set enable to false' do
            described_class.expects(:openstack)
              .with('user', 'set', ['--disable', '37b7086693ec482389799da5dc546fa4'])
              .returns('""')
            provider.expects(:id).returns('37b7086693ec482389799da5dc546fa4')
            provider.enabled = :false
            provider.flush
          end
        end
        describe '-> true' do
          it 'properly set enable to true' do
            described_class.expects(:openstack)
              .with('user', 'set', ['--enable', '37b7086693ec482389799da5dc546fa4'])
              .returns('""')
            provider.expects(:id).returns('37b7086693ec482389799da5dc546fa4')
            provider.enabled = :true
            provider.flush
          end
        end
      end
      context '.email' do
        it 'change the mail' do
          described_class.expects(:openstack)
            .with('user', 'set', ['--email', 'new email',
                                     '37b7086693ec482389799da5dc546fa4'])
            .returns('""')
          provider.expects(:id).returns('37b7086693ec482389799da5dc546fa4')
          provider.expects(:resource).returns(:email => 'new email')
          provider.email = 'new email'
          provider.flush
        end
      end
    end
  end

  describe '#password' do
    let(:resource_attrs) do
      {
        :name         => 'user_one',
        :ensure       => 'present',
        :enabled      => 'True',
        :password     => 'pass_one',
        :email        => 'user_one@example.com',
        :domain       => 'domain1'
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_user.new(resource_attrs)
    end

    let :provider do
      described_class.new(resource)
    end

    it 'checks the password' do
      mock_creds = Puppet::Provider::Openstack::CredentialsV3.new
      mock_creds.auth_url   = 'http://127.0.0.1:5000'
      mock_creds.password   = 'pass_one'
      mock_creds.username   = 'user_one'
      mock_creds.user_id    = 'project1_id'
      mock_creds.project_id = 'project-id-1'
      Puppet::Provider::Openstack::CredentialsV3.expects(:new).returns(mock_creds)

      described_class.expects(:openstack)
        .with('project', 'list', '--quiet', '--format', 'csv',
              ['--user', 'user1_id', '--long'])
        .returns('"ID","Name","Domain ID","Description","Enabled"
"project-id-1","domain_one","domain1_id","Domain One",True
')
      Puppet::Provider::Openstack.expects(:openstack)
        .with('token', 'issue', ['--format', 'value'])
        .returns('2015-05-14T04:06:05Z
e664a386befa4a30878dcef20e79f167
8dce2ae9ecd34c199d2877bf319a3d06
ac43ec53d5a74a0b9f51523ae41a29f0
')
      provider.expects(:id).times(2).returns('user1_id')
      password = provider.password
      expect(password).to eq('pass_one')
    end

    it 'fails the password check' do
      described_class.expects(:openstack)
        .with('project', 'list', '--quiet', '--format', 'csv',
              ['--user', 'user1_id', '--long'])
        .returns('"ID","Name","Domain ID","Description","Enabled"
"project-id-1","domain_one","domain1_id","Domain One",True
')
      Puppet::Provider::Openstack.expects(:openstack)
        .with('token', 'issue', ['--format', 'value'])
        .raises(Puppet::ExecutionFailure, 'HTTP 401 invalid authentication')
      provider.expects(:id).times(2).returns('user1_id')
      password = provider.password
      expect(password).to eq(nil)
    end

    it 'checks the password with domain scoped token' do
      provider.expects(:id).twice.returns('project1_id')
      provider.expects(:domain_id).returns('domain1_id')
      mock_creds = Puppet::Provider::Openstack::CredentialsV3.new
      mock_creds.auth_url    = 'http://127.0.0.1:5000'
      mock_creds.password    = 'foo'
      mock_creds.username    = 'foo'
      mock_creds.user_id     = 'project1_id'
      mock_creds.domain_id = 'domain1_id'
      Puppet::Provider::Openstack::CredentialsV3.expects(:new).returns(mock_creds)
      described_class.expects(:openstack)
        .with('project', 'list', '--quiet', '--format', 'csv',
              ['--user', 'project1_id', '--long'])
        .returns('"ID","Name","Domain ID","Description","Enabled"
')
      Puppet::Provider::Openstack.expects(:openstack)
        .with('token', 'issue', ['--format', 'value'])
        .returns('2015-05-14T04:06:05Z
e664a386befa4a30878dcef20e79f167
8dce2ae9ecd34c199d2877bf319a3d06
ac43ec53d5a74a0b9f51523ae41a29f0
')
      password = provider.password
      expect(password).to eq('pass_one')
    end
  end

  describe 'when updating a user with unmanaged password' do

    describe 'when updating a user with unmanaged password' do

      let(:resource_attrs) do
        {
          :name             => 'user1',
          :ensure           => 'present',
          :enabled          => 'True',
          :password         => 'secret',
          :replace_password => 'False',
          :email            => 'user1@example.com',
          :domain           => 'domain1'
        }
      end

      let(:resource) do
        Puppet::Type::Keystone_user.new(resource_attrs)
      end

      let :provider do
        described_class.new(resource)
      end

      it 'should not try to check password' do
        expect(provider.password).to eq('secret')
      end
    end
  end

  describe 'when managing an user using v3 domains' do
    describe '#create' do
      context 'domain provided' do
        before(:each) do
          described_class.expects(:openstack)
            .with('user', 'create', '--format', 'shell', ['user1', '--enable', '--password', 'secret', '--email', 'user1@example.com', '--domain', 'domain1'])
            .returns('email="user1@example.com"
enabled="True"
id="user1_id"
name="user1"
username="user1"
')
        end
        include_examples 'create the correct resource', [
          {
            'expected_results' => {
              :id     => 'user1_id',
              :name   => 'user1',
              :domain => 'domain1'
            }
          },
          {
            'domain in parameter' => {
              :name     => 'user1',
              :ensure   => 'present',
              :enabled  => 'True',
              :password => 'secret',
              :email    => 'user1@example.com',
              :domain   => 'domain1'
            }
          },
          {
            'domain in title' => {
              :title    => 'user1::domain1',
              :ensure   => 'present',
              :enabled  => 'True',
              :password => 'secret',
              :email    => 'user1@example.com'
            }
          },
          {
            'domain in parameter override domain in title' => {
              :title    => 'user1::foobar',
              :ensure   => 'present',
              :enabled  => 'True',
              :password => 'secret',
              :email    => 'user1@example.com',
              :domain   => 'domain1'
            }
          }
        ]
      end
      context 'domain not provided' do
        before(:each) do
          described_class.expects(:openstack)
            .with('user', 'create', '--format', 'shell', ['user1', '--enable', '--password', 'secret', '--email', 'user1@example.com', '--domain', 'Default'])
            .returns('email="user1@example.com"
enabled="True"
id="user1_id"
name="user1"
username="user1"
')
        end
        include_examples 'create the correct resource', [
          {
            'expected_results' => {
              :domain => 'Default',
              :id     => 'user1_id',
              :name   => 'user1',
            }
          },
          {
            'domain in parameter' => {
              :name     => 'user1',
              :ensure   => 'present',
              :enabled  => 'True',
              :password => 'secret',
              :email    => 'user1@example.com'
            }
          }
        ]
      end
    end

    context 'different name, identical resource' do
      let(:resources) do
        [
          Puppet::Type.type(:keystone_user)
            .new(:title => 'name::domain_one', :ensure => :present),
          Puppet::Type.type(:keystone_user)
            .new(:title => 'name', :domain => 'domain_one', :ensure => :present)
        ]
      end
      include_examples 'detect duplicate resource'
    end
  end
end
