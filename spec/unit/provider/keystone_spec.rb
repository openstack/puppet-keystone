require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone'
require 'tempfile'

setup_provider_tests

klass = Puppet::Provider::Keystone

class Puppet::Provider::Keystone
  @credentials = Puppet::Provider::Openstack::CredentialsV3.new
end

describe Puppet::Provider::Keystone do
  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:35357/v3'
  end

  let(:another_class) do
    class AnotherKlass < Puppet::Provider::Keystone
      @credentials = Puppet::Provider::Openstack::CredentialsV3.new
    end
    AnotherKlass
  end

  before(:each) { set_env }

  after :each do
    klass.reset
    another_class.reset
  end

  describe '#domain_id_from_name' do
    it 'should list all domains when requesting a domain name from an ID' do
      klass.expects(:openstack)
           .with('domain', 'list', '--quiet', '--format', 'csv', [])
           .returns('"ID","Name","Enabled","Description"
"someid","SomeName",True,"default domain"
')
      expect(klass.domain_id_from_name('SomeName')).to eq('someid')
    end
    it 'should lookup a domain when not found in the hash' do
      klass.expects(:openstack)
           .with('domain', 'show', '--format', 'shell', 'NewName')
           .returns('
name="NewName"
id="newid"
')
      expect(klass.domain_id_from_name('NewName')).to eq('newid')
    end
    it 'should print an error when there is no such domain' do
      klass.expects(:openstack)
           .with('domain', 'show', '--format', 'shell', 'doesnotexist')
           .returns('
')
      klass.expects(:err)
           .with('Could not find domain with name [doesnotexist]')
      expect(klass.domain_id_from_name('doesnotexist')).to eq(nil)
    end
  end

  describe '#ssl?' do
    it 'should be false if there is no keystone file' do
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(false)
      expect(klass.ssl?).to be_falsey
    end

    it 'should be false if ssl is not configured in keystone file' do
      mock = {}
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      expect(klass.ssl?).to be_falsey
    end

    it 'should be false if ssl is configured and disable in keystone file' do
      mock = {'ssl' => {'enable' => 'False'}}
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      expect(klass.ssl?).to be_falsey
    end

    it 'should be true if ssl is configured and enabled in keystone file' do
      mock = {'ssl' => {'enable' => 'True'}}
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      expect(klass.ssl?).to be_truthy
    end
  end

  describe '#fetch_project' do
    let(:set_env) do
      ENV['OS_USERNAME']     = 'test'
      ENV['OS_PASSWORD']     = 'abc123'
      ENV['OS_PROJECT_NAME'] = 'test'
      ENV['OS_AUTH_URL']     = 'http://127.0.0.1:35357/v3'
    end

    before(:each) do
      set_env
    end

    it 'should be false if the project does not exist' do
      klass.expects(:request_timeout).returns(0)
      klass.expects(:openstack)
        .with('project', 'show', '--format', 'shell', ['no_project', '--domain', 'Default'])
        .once
        .raises(Puppet::ExecutionFailure, "Execution of '/usr/bin/openstack project show --format shell no_project' returned 1: No project with a name or ID of 'no_project' exists.")
      expect(klass.fetch_project('no_project', 'Default')).to be_falsey
    end

    it 'should return the project' do
      klass.expects(:openstack)
        .with('project', 'show', '--format', 'shell', ['The Project', '--domain', 'Default'])
        .returns('
name="The Project"
id="the_project_id"
')
      expect(klass.fetch_project('The Project', 'Default')).to eq({:name=>"The Project", :id=>"the_project_id"})
    end
  end

  describe '#fetch_user' do
    let(:set_env) do
      ENV['OS_USERNAME']     = 'test'
      ENV['OS_PASSWORD']     = 'abc123'
      ENV['OS_PROJECT_NAME'] = 'test'
      ENV['OS_AUTH_URL']     = 'http://127.0.0.1:35357/v3'
    end

    before(:each) do
      set_env
    end

    it 'should be false if the user does not exist' do
      klass.expects(:request_timeout).returns(0)
      klass.expects(:openstack)
        .with('user', 'show', '--format', 'shell', ['no_user', '--domain', 'Default'])
        .once
        .raises(Puppet::ExecutionFailure, "Execution of '/usr/bin/openstack user show --format shell no_user' returned 1: No user with a name or ID of 'no_user' exists.")
      expect(klass.fetch_user('no_user', 'Default')).to be_falsey
    end

    it 'should return the user' do
      klass.expects(:openstack)
        .with('user', 'show', '--format', 'shell', ['The User', '--domain', 'Default'])
        .returns('
name="The User"
id="the_user_id"
')
      expect(klass.fetch_user('The User', 'Default')).to eq({:name=>"The User", :id=>"the_user_id"})
    end
  end

  describe '#get_admin_endpoint' do
    it 'should return nothing if there is no keystone config file' do
      expect(klass.get_admin_endpoint).to be_nil
    end

    it 'should use the admin_endpoint from keystone config file with no trailing slash' do
      mock = {'DEFAULT' => {'admin_endpoint' => 'https://keystone.example.com/'}}
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      expect(klass.get_admin_endpoint).to eq('https://keystone.example.com')
    end

    it 'should use the specified bind_host in the admin endpoint' do
      mock = {'DEFAULT' => {'admin_bind_host' => '192.168.56.210', 'admin_port' => '5001' }}
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      expect(klass.get_admin_endpoint).to eq('http://192.168.56.210:5001')
    end

    it 'should use localhost in the admin endpoint if bind_host is 0.0.0.0' do
      mock = {'DEFAULT' => { 'admin_bind_host' => '0.0.0.0', 'admin_port' => '5001' }}
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      expect(klass.get_admin_endpoint).to eq('http://127.0.0.1:5001')
    end

    it 'should use [::1] in the admin endpoint if bind_host is ::0' do
      mock = {'DEFAULT' => { 'admin_bind_host' => '::0', 'admin_port' => '5001' }}
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      expect(klass.get_admin_endpoint).to eq('http://[::1]:5001')
    end

    it 'should use [2620:52:0:23a9::25] in the admin endpoint if bind_host is 2620:52:0:23a9::25' do
      mock = {'DEFAULT' => { 'admin_bind_host' => '2620:52:0:23a9::25', 'admin_port' => '5001' }}
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      expect(klass.get_admin_endpoint).to eq('http://[2620:52:0:23a9::25]:5001')
    end

    it 'should use localhost in the admin endpoint if bind_host is unspecified' do
      mock = {'DEFAULT' => { 'admin_port' => '5001' }}
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      expect(klass.get_admin_endpoint).to eq('http://127.0.0.1:5001')
    end

    it 'should use https if ssl is enabled' do
      mock = {'DEFAULT' => {'admin_bind_host' => '192.168.56.210', 'admin_port' => '5001' }, 'ssl' => {'enable' => 'True'}}
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      expect(klass.get_admin_endpoint).to eq('https://192.168.56.210:5001')
    end

    it 'should use http if ssl is disabled' do
      mock = {'DEFAULT' => {'admin_bind_host' => '192.168.56.210', 'admin_port' => '5001' }, 'ssl' => {'enable' => 'False'}}
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      expect(klass.get_admin_endpoint).to eq('http://192.168.56.210:5001')
    end
  end

  describe '#get_auth_url' do
    it 'should return nothing when OS_AUTH_URL is no defined in either the environment or the openrc file and there is no keystone configuration file' do
      home = ENV['HOME']
      ENV.clear
      File.expects(:exists?).with("#{home}/openrc").returns(false)
      File.expects(:exists?).with('/root/openrc').returns(false)
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(false)
      expect(klass.get_auth_url).to be_nil
    end

    it 'should return the OS_AUTH_URL from the environment' do
      ENV.clear
      ENV['OS_AUTH_URL'] = 'http://127.0.0.1:5001'
      expect(klass.get_auth_url).to eq('http://127.0.0.1:5001')
    end

    it 'should return the OS_AUTH_URL from the openrc file when there is no OS_AUTH_URL in the environment' do
      home = ENV['HOME']
      ENV.clear
      mock = {'OS_AUTH_URL' => 'http://127.0.0.1:5001'}
      klass.expects(:get_os_vars_from_rcfile).with("#{home}/openrc").returns(mock)
      expect(klass.get_auth_url).to eq('http://127.0.0.1:5001')
    end

    it 'should use admin_endpoint when nothing else is available' do
      ENV.clear
      mock = 'http://127.0.0.1:5001'
      klass.expects(:admin_endpoint).returns(mock)
      expect(klass.get_auth_url).to eq('http://127.0.0.1:5001')
    end
  end

  describe '#get_service_url when retrieving the security token' do
    it 'should return nothing when OS_URL is not defined in environment' do
      ENV.clear
      expect(klass.get_service_url).to be_nil
    end

    it 'should return the OS_URL from the environment' do
      ENV['OS_URL'] = 'http://127.0.0.1:5001/v3'
      expect(klass.get_service_url).to eq('http://127.0.0.1:5001/v3')
    end

    it 'should use admin_endpoint with the API version number' do
      ENV.clear
      mock = 'http://127.0.0.1:5001'
      klass.expects(:admin_endpoint).twice.returns(mock)
      expect(klass.get_service_url).to eq('http://127.0.0.1:5001/v3')
    end
  end

  describe '#set_domain_for_name' do
    it 'should raise an error if the domain is not provided' do
      expect do
        klass.set_domain_for_name('name', nil)
      end.to raise_error(Puppet::Error, /Missing domain name for resource/)
    end

    it 'should return the name only when the provided domain is the default domain id' do
      klass.expects(:default_domain_id)
        .returns('default')
      klass.expects(:openstack)
        .with('domain', 'show', '--format', 'shell', 'Default')
        .returns('
name="Default"
id="default"
')
      expect(klass.set_domain_for_name('name', 'Default')).to eq('name')
    end

    it 'should return the name and domain when the provided domain is not the default domain id' do
      klass.expects(:default_domain_id)
        .returns('default')
      klass.expects(:openstack)
        .with('domain', 'show', '--format', 'shell', 'Other Domain')
        .returns('
name="Other Domain"
id="other_domain_id"
')
      expect(klass.set_domain_for_name('name', 'Other Domain')).to eq('name::Other Domain')
    end

    it 'should return the name only if the domain cannot be fetched' do
      klass.expects(:default_domain_id)
        .returns('default')
      klass.expects(:openstack)
        .with('domain', 'show', '--format', 'shell', 'Unknown Domain')
        .returns('')
      expect(klass.set_domain_for_name('name', 'Unknown Domain')).to eq('name')
    end
  end

  describe 'when retrieving the security token' do
    it 'should return nothing if there is no keystone config file' do
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(false)
      expect(klass.get_admin_token).to be_nil
    end

    it 'should return nothing if the keystone config file does not have a DEFAULT section' do
      mock = {}
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      expect(klass.get_admin_token).to be_nil
    end

    it 'should fail if the keystone config file does not contain an admin token' do
      mock = {'DEFAULT' => {'not_a_token' => 'foo'}}
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      expect(klass.get_admin_token).to be_nil
    end

    it 'should parse the admin token if it is in the config file' do
      mock = {'DEFAULT' => {'admin_token' => 'foo'}}
      File.expects(:exists?).with("/etc/keystone/keystone.conf").returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      expect(klass.get_admin_token).to eq('foo')
    end
  end

  describe 'when using domains' do
    before(:each) do
      set_env
    end

    it 'should list all domains when requesting a domain name from an ID' do
      klass.expects(:openstack)
           .with('domain', 'list', '--quiet', '--format', 'csv', [])
           .returns('"ID","Name","Enabled","Description"
"somename","SomeName",True,"default domain"
')
      expect(klass.domain_name_from_id('somename')).to eq('SomeName')
    end
    it 'should lookup a domain when not found in the hash' do
      klass.expects(:openstack)
           .with('domain', 'list', '--quiet', '--format', 'csv', [])
           .returns('"ID","Name","Enabled","Description"
"somename","SomeName",True,"default domain"
')
      klass.expects(:openstack)
           .with('domain', 'show', '--format', 'shell', 'another')
           .returns('
name="AnOther"
id="another"
')
      expect(klass.domain_name_from_id('somename')).to eq('SomeName')
      expect(klass.domain_name_from_id('another')).to eq('AnOther')
    end
    it 'should print an error when there is no such domain' do
      klass.expects(:openstack)
           .with('domain', 'list', '--quiet', '--format', 'csv', [])
           .returns('"ID","Name","Enabled","Description"
"somename","SomeName",True,"default domain"
')
      klass.expects(:openstack)
           .with('domain', 'show', '--format', 'shell', 'doesnotexist')
           .returns('
')
      klass.expects(:err)
           .with('Could not find domain with id [doesnotexist]')
      expect(klass.domain_name_from_id('doesnotexist')).to eq(nil)
    end
  end
end
