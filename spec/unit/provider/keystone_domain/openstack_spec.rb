require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_domain/openstack'

setup_provider_tests

provider_class = Puppet::Type.type(:keystone_domain).provider(:openstack)

describe provider_class do

  let(:set_env) do
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
        :enabled      => 'True'
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

    before :each do
      set_env
    end

    after :each do
      provider_class.reset
      another_class.reset
    end

    describe '#create' do
      it 'creates a domain' do
        provider_class.expects(:current_default_domain_id).returns('default')
        entry = mock
        provider.expects(:keystone_conf_default_domain_id_entry).returns(entry)

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
        provider_class.expects(:current_default_domain_id).returns('default')
        entry = mock
        provider.expects(:keystone_conf_default_domain_id_entry).returns(entry)

        provider_class.expects(:openstack)
          .with('domain', 'set', ['foo', '--disable'])
        provider_class.expects(:openstack)
          .with('domain', 'delete', 'foo')
        provider.destroy
        expect(provider.exists?).to be_falsey
      end

    end

    describe '#instances' do
      it 'finds every domain' do
        provider_class.expects(:openstack)
          .with('domain', 'list', '--quiet', '--format', 'csv', [])
          .returns('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","foo","foo",True
')
        provider_class.expects(:current_default_domain_id).returns('default')
        instances = provider_class.instances
        expect(instances.count).to eq(1)
      end
    end

    describe '#create default' do
      let(:domain_attrs) do
        {
          :name         => 'new_default',
          :description  => 'New default domain.',
          :ensure       => 'present',
          :enabled      => 'True',
          :is_default   => 'True'
        }
      end

      context 'default_domain_id defined in keystone.conf' do
        it 'creates a default domain' do
          provider_class.expects(:openstack)
            .with('domain', 'create', '--format', 'shell',
            ['new_default', '--enable', '--description', 'New default domain.'])
            .returns('id="1cb05cfed7c24279be884ba4f6520262"
name="foo"
description="foo"
enabled=True
')
          provider_class.expects(:current_default_domain_id).returns('default')
          entry = mock
          provider.expects(:keystone_conf_default_domain_id_entry).returns(entry)
          entry.expects(:create).returns(nil)
          provider.create
          expect(provider.exists?).to be_truthy
        end
      end
    end

    describe '#destroy default' do
      it 'destroys a default domain' do
        provider_class.expects(:current_default_domain_id).returns('my-domainid')
        entry = mock
        provider.expects(:keystone_conf_default_domain_id_entry).returns(entry)

        provider.expects(:is_default).returns(:true)
        provider.expects(:id).twice.returns('my-domainid')
        provider.class.expects(:openstack)
          .with('domain', 'set', ['foo', '--disable'])
        provider.class.expects(:openstack)
          .with('domain', 'delete', 'foo')
        entry.expects(:destroy)

        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end

    describe '#flush' do
      let(:domain_attrs) do
        {
          :name         => 'foo',
          :description  => 'new description',
          :ensure       => 'present',
          :enabled      => 'True',
          :is_default   => 'False'
        }
      end

      it 'changes the description' do
        provider.class.expects(:openstack)
          .with('domain', 'set', ['foo', '--description', 'new description'])
        provider.description=('new description')
        provider.flush
      end

      it 'changes is_default' do
        provider_class.expects(:current_default_domain_id).returns('previous_default_domain-id')
        entry = mock
        provider.expects(:keystone_conf_default_domain_id_entry).returns(entry)
        provider.expects(:id).twice.returns('current_default_domain')
        entry.expects(:create)

        provider.is_default=(:true)
        provider.flush
      end
    end
  end
end
