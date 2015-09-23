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

  let(:resource_attrs) do
    Puppet::Provider::Keystone.expects(:default_domain).returns('Default')
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
        provider_class.expects(:openstack)
          .with('user', 'list', '--quiet', '--format', 'csv', ['--long'])
          .returns('"ID","Name","Project Id","Domain","Description","Email","Enabled"
"user1_id","user1","project1_id","domain1_id","user1 description","user1@example.com",True
"user2_id","user2","project2_id","domain2_id","user2 description","user2@example.com",True
"user3_id","user3","project3_id","domain3_id","user3 description","user3@example.com",True
')
        provider_class.expects(:openstack)
          .with('domain', 'list', '--quiet', '--format', 'csv', [])
          .returns('"ID","Name","Enabled","Description"
"default","Default",True,"default"
"domain1_id","domain1",True,"domain1"
"domain2_id","domain2",True,"domain2"
"domain3_id","domain3",True,"domain3"
')
        # for self.instances to create the name string in
        # resource_to_name
        Puppet::Provider::Keystone.expects(:default_domain).times(3).returns('Default')
        instances = provider.class.instances
        expect(instances.count).to eq(3)
        expect(instances[0].name).to eq('user1::domain1')
        expect(instances[0].domain).to eq('domain1')
        expect(instances[1].name).to eq('user2::domain2')
        expect(instances[1].domain).to eq('domain2')
        expect(instances[2].name).to eq('user3::domain3')
        expect(instances[2].domain).to eq('domain3')
      end
    end

    describe '#prefetch' do
      let(:resources) do
        [Puppet::Type.type(:keystone_user).new(:title => 'exists', :ensure => :present),
          Puppet::Type.type(:keystone_user).new(:title => 'non_exists', :ensure => :present)]
      end
      before(:each) do
        provider_class.expects(:domain_name_from_id).with('default')
          .returns('Default')
        provider_class.expects(:domain_name_from_id).with('domain2_id')
          .returns('bar')
        Puppet::Provider::Keystone.expects(:default_domain).times(7)
          .returns('Default')
        provider_class.expects(:openstack)
          .with('user', 'list', '--quiet', '--format', 'csv', ['--long'])
          .returns('"ID","Name","Project Id","Domain","Description","Email","Enabled"
"user1_id","exists","project1_id","default","user1 description","user1@example.com",True
"user2_id","user2","project2_id","domain2_id","user2 description","user2@example.com",True
')
      end
      include_examples 'prefetch the resources'
    end

    describe '#flush' do
      context '.enable' do
        describe '-> false' do
          it 'properly set enable to false' do
            provider_class.expects(:openstack)
              .with('user', 'set', ['--disable', '37b7086693ec482389799da5dc546fa4'])
              .returns('""')
            provider.expects(:id).returns('37b7086693ec482389799da5dc546fa4')
            provider.enabled = :false
            provider.flush
          end
        end
        describe '-> true' do
          it 'properly set enable to true' do
            provider_class.expects(:openstack)
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
          provider_class.expects(:openstack)
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
        :name         => 'foo',
        :ensure       => 'present',
        :enabled      => 'True',
        :password     => 'foo',
        :email        => 'foo@example.com',
        :domain       => 'domain1'
      }
    end

    let(:resource) do
      Puppet::Provider::Keystone.expects(:default_domain).returns('Default')
      Puppet::Type::Keystone_user.new(resource_attrs)
    end

    let :provider do
      provider_class.new(resource)
    end

    it 'checks the password' do
      mock_creds = Puppet::Provider::Openstack::CredentialsV3.new
      mock_creds.auth_url='http://127.0.0.1:5000'
      mock_creds.password='foo'
      mock_creds.username='foo'
      mock_creds.user_id='project1_id'
      mock_creds.project_id='project-id-1'
      Puppet::Provider::Openstack::CredentialsV3.expects(:new).returns(mock_creds)

      provider_class.expects(:openstack)
        .with('project', 'list', '--quiet', '--format', 'csv', ['--user', 'user1_id', '--long'])
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
      provider.expects(:id).times(2).returns('user1_id')
      password = provider.password
      expect(password).to eq('foo')
    end

    it 'fails the password check' do
      provider_class.expects(:openstack)
        .with('project', 'list', '--quiet', '--format', 'csv', ['--user', 'user1_id', '--long'])
        .returns('"ID","Name","Domain ID","Description","Enabled"
"project-id-1","foo","domain1_id","foo",True
')
      Puppet::Provider::Openstack.expects(:openstack)
        .with('token', 'issue', ['--format', 'value'])
        .raises(Puppet::ExecutionFailure, 'HTTP 401 invalid authentication')
      provider.expects(:id).times(2).returns('user1_id')
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
      provider_class.expects(:openstack)
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

      let(:resource_attrs) do
        Puppet::Provider::Keystone.expects(:default_domain).returns('Default')
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
        provider_class.new(resource)
      end

      it 'should not try to check password' do
        expect(provider.password).to eq('secret')
      end
    end
  end

  describe 'when managing an user using v3 domains' do
    describe '#create' do
      before(:each) do
        provider_class.expects(:openstack)
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
            :domain => 'domain1',
            :id     => 'user1_id',
            :name   => 'user1',
            :domain => 'domain1'
          }
        },
        {
          :name  => 'domain1',
          :times => 2,
          :attributes => {
            'Default' => {
              :title    => 'user1',
              :ensure   => 'present',
              :enabled  => 'True',
              :password => 'secret',
              :email    => 'user1@example.com'
            }
          }
        },
        {
          'domain in parameter' => {
            :name     => 'user1',
            :ensure   => 'present',
            :enabled  => 'True',
            :password => 'secret',
            :email    => 'user1@example.com',
            :domain   => 'domain1',
            :default_domain => 1
          }
        },
        {
          'domain in title' => {
            :title    => 'user1::domain1',
            :ensure   => 'present',
            :enabled  => 'True',
            :password => 'secret',
            :email    => 'user1@example.com',
            :default_domain => 1
          }
        },
        {
          'domain in parameter override domain in title' => {
            :title    => 'user1::foobar',
            :ensure   => 'present',
            :enabled  => 'True',
            :password => 'secret',
            :email    => 'user1@example.com',
            :domain   => 'domain1',
            :default_domain => 1
          }
        },
      ]
    end

    describe '#prefetch' do
      let(:resources) do
        Puppet::Provider::Keystone.expects(:default_domain).twice.returns('Default')
        [
          Puppet::Type.type(:keystone_user)
            .new(:title => 'exists::domain1', :ensure => :present),
          Puppet::Type.type(:keystone_user)
            .new(:title => 'non_exists::domain1', :ensure => :present)
        ]
      end
      before(:each) do
        # Used to make the final display name
        provider_class.expects(:default_domain).times(3).returns('Default')

        provider_class.expects(:domain_name_from_id)
          .with('domain1_id').returns('domain1')
        provider_class.expects(:domain_name_from_id)
          .with('domain2_id').returns('bar')
        provider_class.expects(:openstack)
          .with('user', 'list', '--quiet', '--format', 'csv', ['--long'])
          .returns('"ID","Name","Project Id","Domain","Description","Email","Enabled"
"user1_id","exists","project1_id","domain1_id","user1 description","user1@example.com",True
"user2_id","user2","project2_id","domain2_id","user2 description","user2@example.com",True
')
      end
      include_examples 'prefetch the resources'
    end

    context 'different name, identical resource' do
      let(:resources) do
        Puppet::Provider::Keystone.expects(:default_domain).twice.returns('Default')
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
