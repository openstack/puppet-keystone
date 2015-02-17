require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_service/openstack'

provider_class = Puppet::Type.type(:keystone_service).provider(:openstack)

describe provider_class do

  describe 'when creating a service' do

    let(:service_attrs) do
      {
        :name         => 'foo',
        :description  => 'foo',
        :ensure       => 'present',
        :type         => 'foo',
        :auth         => {
          'username'    => 'test',
          'password'    => 'abc123',
          'tenant_name' => 'foo',
          'auth_url'    => 'http://127.0.0.1:5000/v2.0',
        }
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_service.new(service_attrs)
    end

    let(:provider) do
      provider_class.new(resource)
    end

    describe '#create' do
      it 'creates a service' do
        provider.class.stubs(:openstack)
                      .with('service', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Type","Description"
"1cb05cfed7c24279be884ba4f6520262","foo","foo","foo"
')
        provider.class.stubs(:openstack)
                      .with('service', 'create', '--format', 'shell', [['foo', '--description', 'foo', '--type', 'foo', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('description="foo"
enabled="True"
id="8f0dd4c0abc44240998fbb3f5089ecbf"
name="foo"
type="foo"
')
        provider.create
        expect(provider.exists?).to be_truthy
      end
    end

    describe '#destroy' do
      it 'destroys a service' do
        provider.class.stubs(:openstack)
                      .with('service', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Type","Description"')
        provider.class.stubs(:openstack)
                      .with('service', 'delete', [['foo', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
        provider.destroy
        expect(provider.exists?).to be_falsey
      end

    end

    describe '#exists' do
      context 'when service exists' do

        subject(:response) do
          provider.class.stubs(:openstack)
                        .with('service', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                        .returns('"ID","Name","Type","Description"
"1cb05cfed7c24279be884ba4f6520262","foo","foo","foo"
')
          response = provider.exists?
        end

        it { is_expected.to be_truthy }
      end

      context 'when service does not exist' do

        subject(:response) do
          provider.class.stubs(:openstack)
                        .with('service', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                        .returns('"ID","Name","Type","Description"')
          response = provider.exists?
        end

        it { is_expected.to be_falsey }
      end
    end

    describe '#instances' do
      it 'finds every service' do
        provider.class.stubs(:openstack)
                      .with('service', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Type","Description"
"1cb05cfed7c24279be884ba4f6520262","foo","foo","foo"
')
        instances = provider.instances
        expect(instances.count).to eq(1)
      end
    end

  end
end
