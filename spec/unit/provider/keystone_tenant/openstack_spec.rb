require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_tenant/openstack'

provider_class = Puppet::Type.type(:keystone_tenant).provider(:openstack)

describe provider_class do

  describe 'when updating a tenant' do

    let(:tenant_attrs) do
      {
        :name         => 'foo',
        :description  => 'foo',
        :ensure       => 'present',
        :enabled      => 'True',
        :auth         => {
          'username'    => 'test',
          'password'    => 'abc123',
          'tenant_name' => 'foo',
          'auth_url'    => 'http://127.0.0.1:5000/v2.0',
        }
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_tenant.new(tenant_attrs)
    end

    let(:provider) do
      provider_class.new(resource)
    end

    describe '#create' do
      it 'creates a tenant' do
        provider.class.stubs(:openstack)
                      .with('project', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","foo","foo",True
')
        provider.class.stubs(:openstack)
                      .with('project', 'create', '--format', 'shell', [['foo', '--enable', '--description', 'foo', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('description="foo"
enabled="True"
name="foo"
')
        provider.create
        expect(provider.exists?).to be_truthy
      end
    end

    describe '#destroy' do
      it 'destroys a tenant' do
        provider.class.stubs(:openstack)
                      .with('project', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Description","Enabled"')
        provider.class.stubs(:openstack)
                      .with('project', 'delete', [['foo', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
        provider.destroy
        expect(provider.exists?).to be_falsey
      end

    end

    describe '#exists' do
      context 'when tenant exists' do

        subject(:response) do
          provider.class.stubs(:openstack)
                        .with('project', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                        .returns('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","foo","foo",True
')
          response = provider.exists?
        end

        it { is_expected.to be_truthy }
      end

      context 'when tenant does not exist' do

        subject(:response) do
          provider.class.stubs(:openstack)
                        .with('project', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Description","Enabled"')
          response = provider.exists?
        end

        it { is_expected.to be_falsey }
      end
    end

    describe '#instances' do
      it 'finds every tenant' do
        provider.class.stubs(:openstack)
                      .with('project', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","foo","foo",True
')
        instances = provider.instances
        expect(instances.count).to eq(1)
      end
    end

  end
end
