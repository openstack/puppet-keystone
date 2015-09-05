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

  let(:another_class) do
    class AnotherKlass < Puppet::Provider::Keystone
      @credentials = Puppet::Provider::Openstack::CredentialsV3.new
    end
    AnotherKlass
  end

  after :each do
    klass.reset
    another_class.reset
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
    it 'name_and_domain should return the resource domain' do
      expect(klass.name_and_domain('foo::in_name', 'from_resource', 'default')).to eq(['foo', 'from_resource'])
    end
    it 'name_and_domain should return the default domain' do
      expect(klass.name_and_domain('foo', nil, 'default')).to eq(['foo', 'default'])
    end
    it 'name_and_domain should return the domain part of the name' do
      expect(klass.name_and_domain('foo::in_name', nil, 'default')).to eq(['foo', 'in_name'])
    end
    it 'should return the default domain name using the default_domain_id from keystone.conf' do
      ENV['OS_USERNAME']     = 'test'
      ENV['OS_PASSWORD']     = 'abc123'
      ENV['OS_PROJECT_NAME'] = 'test'
      ENV['OS_AUTH_URL']     = 'http://127.0.0.1:35357/v3'
      mock = {
        'DEFAULT' => {
          'admin_endpoint' => 'http://127.0.0.1:35357',
          'admin_token'    => 'admin_token'
        },
        'identity' => {'default_domain_id' => 'somename'}
      }
      File.expects(:exists?).with('/etc/keystone/keystone.conf').returns(true)
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      klass.expects(:openstack)
           .with('domain', 'list', '--quiet', '--format', 'csv', [])
           .returns('"ID","Name","Enabled","Description"
"somename","SomeName",True,"default domain"
')
      expect(klass.name_and_domain('foo')).to eq(['foo', 'SomeName'])
    end
    it 'should return the default_domain_id from one class set in another class' do
      ENV['OS_USERNAME']     = 'test'
      ENV['OS_PASSWORD']     = 'abc123'
      ENV['OS_PROJECT_NAME'] = 'test'
      ENV['OS_AUTH_URL']     = 'http://127.0.0.1:35357/v3'
      klass.expects(:openstack)
           .with('domain', 'list', '--quiet', '--format', 'csv', [])
           .returns('"ID","Name","Enabled","Description"
"default","Default",True,"default domain"
"somename","SomeName",True,"some domain"
')
      another_class.expects(:openstack)
                   .with('domain', 'list', '--quiet', '--format', 'csv', [])
                   .returns('"ID","Name","Enabled","Description"
"default","Default",True,"default domain"
"somename","SomeName",True,"some domain"
')
      expect(klass.default_domain).to eq('Default')
      expect(another_class.default_domain).to eq('Default')
      klass.default_domain_id = 'somename'
      expect(klass.default_domain).to eq('SomeName')
      expect(another_class.default_domain).to eq('SomeName')
    end
    it 'should return Default if default_domain_id is not configured' do
      ENV['OS_USERNAME']     = 'test'
      ENV['OS_PASSWORD']     = 'abc123'
      ENV['OS_PROJECT_NAME'] = 'test'
      ENV['OS_AUTH_URL']     = 'http://127.0.0.1:35357/v3'
      mock = {}
      Puppet::Util::IniConfig::File.expects(:new).returns(mock)
      File.expects(:exists?).with('/etc/keystone/keystone.conf').returns(true)
      mock.expects(:read).with('/etc/keystone/keystone.conf')
      klass.expects(:openstack)
           .with('domain', 'list', '--quiet', '--format', 'csv', [])
           .returns('"ID","Name","Enabled","Description"
"default","Default",True,"default domain"
')
      expect(klass.name_and_domain('foo')).to eq(['foo', 'Default'])
    end
    it 'should list all domains when requesting a domain name from an ID' do
      ENV['OS_USERNAME']     = 'test'
      ENV['OS_PASSWORD']     = 'abc123'
      ENV['OS_PROJECT_NAME'] = 'test'
      ENV['OS_AUTH_URL']     = 'http://127.0.0.1:35357/v3'
      klass.expects(:openstack)
           .with('domain', 'list', '--quiet', '--format', 'csv', [])
           .returns('"ID","Name","Enabled","Description"
"somename","SomeName",True,"default domain"
')
      expect(klass.domain_name_from_id('somename')).to eq('SomeName')
    end
    it 'should lookup a domain when not found in the hash' do
      ENV['OS_USERNAME']     = 'test'
      ENV['OS_PASSWORD']     = 'abc123'
      ENV['OS_PROJECT_NAME'] = 'test'
      ENV['OS_AUTH_URL']     = 'http://127.0.0.1:35357/v3'
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
      ENV['OS_USERNAME']     = 'test'
      ENV['OS_PASSWORD']     = 'abc123'
      ENV['OS_PROJECT_NAME'] = 'test'
      ENV['OS_AUTH_URL']     = 'http://127.0.0.1:35357/v3'
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
