require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_domain/openstack'

setup_provider_tests

provider_class = Puppet::Type.type(:keystone_domain).provider(:openstack)

describe provider_class do

  shared_examples 'authenticated with environment variables' do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:35357/v2.0'
  end

  describe 'when managing a domain' do

    let(:domain_attrs) do
      {
        :name         => 'foo',
        :description  => 'foo',
        :ensure       => 'present',
        :enabled      => 'True',
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_domain.new(domain_attrs)
    end

    let(:provider) do
      provider_class.new(resource)
    end

    let(:another_class) do
      class AnotherKlass < Puppet::Provider::Keystone
        @credentials = Puppet::Provider::Openstack::CredentialsV3.new
      end
      AnotherKlass
    end

    after :each do
      provider_class.reset
      another_class.reset
    end

    it_behaves_like 'authenticated with environment variables' do
      describe '#create' do
        it 'creates a domain' do
          # keystone.conf
          File.expects(:exists?).returns(true)
          kcmock = {
            'identity' => {'default_domain_id' => ' default'}
          }
          Puppet::Util::IniConfig::File.expects(:new).returns(kcmock)
          kcmock.expects(:read).with('/etc/keystone/keystone.conf')
          provider.class.expects(:openstack)
                        .with('domain', 'create', '--format', 'shell', ['foo', '--enable', '--description', 'foo'])
                        .returns('id="1cb05cfed7c24279be884ba4f6520262"
name="foo"
description="foo"
enabled=True
')
          provider.create
          expect(provider.exists?).to be_truthy
        end

      end

      describe '#destroy' do
        it 'destroys a domain' do
          provider.instance_variable_get('@property_hash')[:id] = 'my-domainid'
          # keystone.conf
          File.expects(:exists?).returns(true)
          kcmock = {
            'identity' => {'default_domain_id' => ' default'}
          }
          Puppet::Util::IniConfig::File.expects(:new).returns(kcmock)
          kcmock.expects(:read).with('/etc/keystone/keystone.conf')
          provider.class.expects(:openstack)
                        .with('domain', 'set', ['foo', '--disable'])
          provider.class.expects(:openstack)
                        .with('domain', 'delete', 'foo')
          provider.destroy
          expect(provider.exists?).to be_falsey
        end

      end

      describe '#instances' do
        it 'finds every domain' do
          provider.class.expects(:openstack)
                        .with('domain', 'list', '--quiet', '--format', 'csv', [])
                        .returns('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","foo","foo",True
')
          instances = provider_class.instances
          expect(instances.count).to eq(1)
        end
      end

      describe '#create default' do
        let(:domain_attrs) do
          {
            :name         => 'foo',
            :description  => 'foo',
            :ensure       => 'present',
            :enabled      => 'True',
            :is_default   => 'True',
          }
        end

        it 'creates a default domain' do
          File.expects(:exists?).twice.returns(true)
          mock = {
            'identity' => {'default_domain_id' => ' default'}
          }
          Puppet::Util::IniConfig::File.expects(:new).twice.returns(mock)
          mock.expects(:read).twice.with('/etc/keystone/keystone.conf')
          mock.expects(:store)
          provider.class.expects(:openstack)
                        .with('domain', 'create', '--format', 'shell', ['foo', '--enable', '--description', 'foo'])
                        .returns('id="1cb05cfed7c24279be884ba4f6520262"
name="foo"
description="foo"
enabled=True
')
          expect(provider.class.default_domain_id).to eq('default')
          expect(another_class.default_domain_id).to eq('default')
          provider.create
          expect(provider.exists?).to be_truthy
          expect(mock['identity']['default_domain_id']).to eq('1cb05cfed7c24279be884ba4f6520262')
          expect(provider.class.default_domain_id).to eq('1cb05cfed7c24279be884ba4f6520262')
          expect(another_class.default_domain_id).to eq('1cb05cfed7c24279be884ba4f6520262')
        end
      end

      describe '#destroy default' do
        it 'destroys a default domain' do
          provider.instance_variable_get('@property_hash')[:is_default] = true
          provider.instance_variable_get('@property_hash')[:id] = 'my-domainid'
          # keystone.conf
          File.expects(:exists?).returns(true)
          kcmock = {
            'identity' => {'default_domain_id' => ' my-domainid'}
          }
          Puppet::Util::IniConfig::File.expects(:new).returns(kcmock)
          kcmock.expects(:read).with('/etc/keystone/keystone.conf')
          kcmock.expects(:store)
          provider.class.expects(:openstack)
                        .with('domain', 'set', ['foo', '--disable'])
          provider.class.expects(:openstack)
                        .with('domain', 'delete', 'foo')
          provider.destroy
          expect(provider.exists?).to be_falsey
          expect(kcmock['identity']['default_domain_id']).to eq('default')
          expect(provider.class.default_domain_id).to eq('default')
          expect(another_class.default_domain_id).to eq('default')
        end
      end

      describe '#flush' do
        let(:domain_attrs) do
          {
            :name         => 'foo',
            :description  => 'new description',
            :ensure       => 'present',
            :enabled      => 'True',
            :is_default   => 'True',
          }
        end

        it 'changes the description' do
          provider.class.expects(:openstack)
                        .with('domain', 'set', ['foo', '--description', 'new description'])
          provider.description=('new description')
          provider.flush
        end

        it 'changes is_default' do
          # keystone.conf
          File.expects(:exists?).returns(true)
          kcmock = {
            'identity' => {'default_domain_id' => ' my-domainid'}
          }
          Puppet::Util::IniConfig::File.expects(:new).returns(kcmock)
          kcmock.expects(:read).with('/etc/keystone/keystone.conf')
          provider.is_default=(true)
          provider.flush
        end
      end
    end
  end
end
