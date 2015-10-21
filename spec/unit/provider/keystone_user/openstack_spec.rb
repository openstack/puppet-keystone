require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_user/openstack'
require 'puppet/provider/openstack'

setup_provider_tests

provider_class = Puppet::Type.type(:keystone_user).provider(:openstack)

def project_class
  Puppet::Type.type(:keystone_tenant).provider(:openstack)
end

describe provider_class do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  after :each do
    provider_class.reset
    project_class.reset
  end

  let(:user_attrs) do
    {
      :name          => 'user1',
      :ensure        => :present,
      :enabled       => 'True',
      :password      => 'secret',
      :email         => 'user1@example.com',
      :domain        => 'domain1',
    }
  end

  let(:resource) do
    Puppet::Type::Keystone_user.new(user_attrs)
  end

  let(:provider) do
    provider_class.new(resource)
  end

  before(:each) { set_env }

  describe 'when managing a user' do
    describe '#create' do
      it 'creates a user' do
        provider.class.expects(:openstack)
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
        provider.instance_variable_get('@property_hash')[:id] = 'my-user-id'
        provider.class.expects(:openstack)
          .with('user', 'delete', 'my-user-id')
        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end

    describe '#exists' do
      context 'when user does not exist' do
        subject(:response) do
          response = provider.exists?
        end

        it { is_expected.to be_falsey }
      end
    end

    describe '#instances' do
      it 'finds every user' do
        provider.class.expects(:openstack)
          .with('user', 'list', '--quiet', '--format', 'csv', ['--long'])
          .returns('"ID","Name","Project Id","Domain","Description","Email","Enabled"
"user1_id","user1","project1_id","domain1_id","user1 description","user1@example.com",True
"user2_id","user2","project2_id","domain2_id","user2 description","user2@example.com",True
"user3_id","user3","project3_id","domain3_id","user3 description","user3@example.com",True
')
      provider.class.expects(:openstack)
        .with('domain', 'list', '--quiet', '--format', 'csv', [])
        .returns('"ID","Name","Enabled","Description"
"default","Default",True,"default"
"domain1_id","domain1",True,"domain1"
"domain2_id","domain2",True,"domain2"
"domain3_id","domain3",True,"domain3"
')
        provider.class.expects(:openstack)
          .with('domain', 'show', '--format', 'shell', 'domain1')
          .returns('description=""
enabled="True"
id="domain1_id"
name="domain1"
')
        provider.class.expects(:openstack)
          .with('domain', 'show', '--format', 'shell', 'domain2')
          .returns('description=""
enabled="True"
id="domain2_id"
name="domain2"
')
        provider.class.expects(:openstack)
          .with('domain', 'show', '--format', 'shell', 'domain3')
          .returns('description=""
enabled="True"
id="domain3_id"
name="domain3"
')
        instances = provider.class.instances
        expect(instances.count).to eq(3)
        expect(instances[0].name).to eq('user1::domain1')
        expect(instances[0].domain).to eq('domain1')
        expect(instances[1].name).to eq('user2::domain2')
        expect(instances[2].name).to eq('user3::domain3')
      end
    end
  end

  describe "#password" do
    let(:user_attrs) do
      {
        :name         => 'foo',
        :ensure       => 'present',
        :enabled      => 'True',
        :password     => 'foo',
        :email        => 'foo@example.com',
        :domain       => 'domain1',
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_user.new(user_attrs)
    end

    let :provider do
      provider_class.new(resource)
    end

    it 'checks the password' do
      provider.instance_variable_get('@property_hash')[:id] = 'user1_id'
      mock_creds = Puppet::Provider::Openstack::CredentialsV3.new
      mock_creds.auth_url='http://127.0.0.1:5000'
      mock_creds.password='foo'
      mock_creds.username='foo'
      mock_creds.user_id='project1_id'
      mock_creds.project_id='project-id-1'
      Puppet::Provider::Openstack::CredentialsV3.expects(:new).returns(mock_creds)

      provider.class.expects(:openstack)
        .with('domain', 'list', '--quiet', '--format', 'csv', [])
        .returns('"ID","Name","Enabled","Description"
"default","Default",True,"default"
"domain1_id","domain1",True,"domain1"
"domain2_id","domain2",True,"domain2"
')
      provider.class.expects(:openstack)
        .with('project', 'list', '--quiet', '--format', 'csv', ['--user', 'user1_id', '--long'])
        .returns('"ID","Name","Domain ID","Description","Enabled"
"project2_id","project2","domain2_id","",True
')
      Puppet::Provider::Openstack.expects(:openstack)
        .with('project', 'list', '--quiet', '--format', 'csv', ['--user', 'project1_id', '--long'])
        .returns('"ID","Name","Domain ID","Description","Enabled"
"project-id-1","foo","domain1_id","foo",True
')
      Puppet::Provider::Openstack.expects(:openstack)
        .with('token', 'issue', ['--format', 'value'])
        .returns('2015-05-14T04:06:05Z
e664a386befa4a30878dcef20e79f167
8dce2ae9ecd34c199d2877bf319a3d06
ac43ec53d5a74a0b9f51523ae41a29f0
')
      password = provider.password
      expect(password).to eq('foo')
    end

    it 'fails the password check' do
      provider.instance_variable_get('@property_hash')[:id] = 'user1_id'
      provider.class.expects(:openstack)
        .with('domain', 'list', '--quiet', '--format', 'csv', [])
        .returns('"ID","Name","Enabled","Description"
"default","Default",True,"default"
"domain1_id","domain1",True,"domain1"
"domain2_id","domain2",True,"domain2"
')
      Puppet::Provider::Openstack.expects(:openstack)
        .with('project', 'list', '--quiet', '--format', 'csv', ['--user', 'user1_id', '--long'])
        .returns('"ID","Name","Domain ID","Description","Enabled"
"project-id-1","foo","domain1_id","foo",True
')
      Puppet::Provider::Openstack.expects(:openstack)
        .with('token', 'issue', ['--format', 'value'])
        .raises(Puppet::ExecutionFailure, 'HTTP 401 invalid authentication')
      password = provider.password
      expect(password).to eq(nil)
    end

    it 'checks the password with domain scoped token' do
      provider.instance_variable_get('@property_hash')[:id] = 'project1_id'
      provider.instance_variable_get('@property_hash')[:domain] = 'domain1'
      mock_creds = Puppet::Provider::Openstack::CredentialsV3.new
      mock_creds.auth_url='http://127.0.0.1:5000'
      mock_creds.password='foo'
      mock_creds.username='foo'
      mock_creds.user_id='project1_id'
      mock_creds.domain_name='domain1'
      Puppet::Provider::Openstack::CredentialsV3.expects(:new).returns(mock_creds)
      Puppet::Provider::Openstack.expects(:openstack)
        .with('project', 'list', '--quiet', '--format', 'csv', ['--user', 'project1_id', '--long'])
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
      expect(password).to eq('foo')
    end
  end

  describe 'when updating a user with unmanaged password' do

    describe 'when updating a user with unmanaged password' do

      let(:user_attrs) do
        {
          :name             => 'user1',
          :ensure           => 'present',
          :enabled          => 'True',
          :password         => 'secret',
          :replace_password => 'False',
          :email            => 'user1@example.com',
          :domain           => 'domain1',
        }
      end

      let(:resource) do
        Puppet::Type::Keystone_user.new(user_attrs)
      end

      let :provider do
        provider_class.new(resource)
      end

      it 'should not try to check password' do
        expect(provider.password).to eq('secret')
      end
    end
  end

  describe 'v3 domains with no domain in resource' do
    let(:user_attrs) do
      {
        :name          => 'user1',
        :ensure        => 'present',
        :enabled       => 'True',
        :password      => 'secret',
        :email         => 'user1@example.com',
      }
    end

    it 'adds default domain to commands' do
      mock = {
        'identity' => {'default_domain_id' => 'domain1_id'}
      }
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      File.expects(:exists?).with('/etc/keystone/keystone.conf').returns(true)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      provider.class.expects(:openstack)
        .with('domain', 'list', '--quiet', '--format', 'csv', [])
        .returns('"ID","Name","Enabled","Description"
"domain1_id","domain1",True,"domain1"
"domain2_id","domain2",True,"domain2"
')
      provider.class.expects(:openstack)
        .with('project', 'list', '--quiet', '--format', 'csv', ['--user', 'user1_id', '--long'])
        .returns('"ID","Name"
')
      provider.class.expects(:openstack)
        .with('role', 'show', '--format', 'shell', '_member_')
        .returns('
name="_member_"
')
      provider.class.expects(:openstack)
        .with('role', 'add', ['_member_', '--project', 'project1_id', '--user', 'user1_id'])
      provider.class.expects(:openstack)
        .with('user', 'create', '--format', 'shell', ['user1', '--enable', '--password', 'secret', '--email', 'user1@example.com', '--domain', 'domain1'])
        .returns('email="user1@example.com"
enabled="True"
id="user1_id"
name="user1"
username="user1"
')
      provider.class.expects(:openstack)
        .with('project', 'show', '--format', 'shell', ['project1', '--domain', 'domain2'])
        .returns('name="project1"
id="project1_id"
')
      provider.create
      expect(provider.exists?).to be_truthy
      expect(provider.id).to eq("user1_id")
    end
  end

  describe 'v3 domains with domain in resource' do
    let(:user_attrs) do
      {
        :name          => 'user1',
        :ensure        => 'present',
        :enabled       => 'True',
        :password      => 'secret',
        :email         => 'user1@example.com',
        :domain        => 'domain1',
      }
    end

    it 'uses given domain in commands' do
      provider.class.expects(:openstack)
        .with('user', 'create', '--format', 'shell', ['user1', '--enable', '--password', 'secret', '--email', 'user1@example.com', '--domain', 'domain1'])
        .returns('email="user1@example.com"
enabled="True"
id="user1_id"
name="user1"
username="user1"
')
      provider.create
      expect(provider.exists?).to be_truthy
      expect(provider.id).to eq("user1_id")
    end
  end

  describe 'v3 domains with domain in name/title' do
    let(:user_attrs) do
      {
        :name         => 'user1::domain1',
        :ensure       => 'present',
        :enabled      => 'True',
        :password     => 'secret',
        :email        => 'user1@example.com',
      }
    end

    it 'uses given domain in commands' do
      provider.class.expects(:openstack)
        .with('user', 'create', '--format', 'shell', ['user1', '--enable', '--password', 'secret', '--email', 'user1@example.com', '--domain', 'domain1'])
        .returns('email="user1@example.com"
enabled="True"
id="user1_id"
name="user1"
username="user1"
')
      provider.create
      expect(provider.exists?).to be_truthy
      expect(provider.id).to eq("user1_id")
      expect(provider.name).to eq('user1::domain1')
    end
  end

  describe 'v3 domains with domain in name/title and in resource' do
    let(:user_attrs) do
      {
        :name         => 'user1::domain1',
        :ensure       => 'present',
        :enabled      => 'True',
        :password     => 'secret',
        :email        => 'user1@example.com',
        :domain       => 'domain1',
      }
    end

    it 'uses the resource domain in commands' do
      provider.class.expects(:openstack)
        .with('user', 'create', '--format', 'shell', ['user1', '--enable', '--password', 'secret', '--email', 'user1@example.com', '--domain', 'domain1'])
        .returns('email="user1@example.com"
enabled="True"
id="user1_id"
name="user1"
username="user1"
')
      provider.create
      expect(provider.exists?).to be_truthy
      expect(provider.id).to eq("user1_id")
      expect(provider.name).to eq('user1::domain1')
    end
  end
end
