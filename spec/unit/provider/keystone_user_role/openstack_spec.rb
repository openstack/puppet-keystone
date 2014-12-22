require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_user_role/openstack'

provider_class = Puppet::Type.type(:keystone_user_role).provider(:openstack)

describe provider_class do

  describe 'when updating a user\'s role' do

    let(:user_role_attrs) do
      {
        :name         => 'foo@example.com@foo',
        :ensure       => 'present',
        :roles        => ['foo', 'bar'],
        :auth         => {
          'username'    => 'test',
          'password'    => 'abc123',
          'tenant_name' => 'foo',
          'auth_url'    => 'http://127.0.0.1:5000/v2.0',
        }
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_user_role.new(user_role_attrs)
    end

    let(:provider) do
      provider_class.new(resource)
    end

    before(:each) do
      provider.class.stubs(:openstack)
                    .with('user', 'list', '--quiet', '--format', 'csv', [['--project', 'foo', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                    .returns('"ID","Name"
"1cb05cfed7c24279be884ba4f6520262","foo@example.com"
')
      provider.class.stubs(:openstack)
                    .with('project', 'list', '--quiet', '--format', 'csv', [['--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                    .returns('"ID","Name"
"1cb05cfed7c24279be884ba4f6520262","foo"
')
    end

    describe '#create' do
      it 'adds all the roles to the user' do
        provider.class.stubs(:openstack)
                      .with('user role', 'list', '--quiet', '--format', 'csv', [['--project', 'foo', 'foo@example.com', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Project","User"
"1cb05cfed7c24279be884ba4f6520262","foo","foo","foo@example.com"
"1cb05cfed7c24279be884ba4f6520263","bar","foo","foo@example.com"
')
        provider.class.stubs(:openstack)
                      .with('role', 'add', [['foo', '--project', 'foo', '--user', 'foo@example.com', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
        provider.class.stubs(:openstack)
                      .with('role', 'add', [['bar', '--project', 'foo', '--user', 'foo@example.com', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
        provider.create
        expect(provider.exists?).to be_truthy
      end
    end

    describe '#destroy' do
      it 'removes all the roles from a user' do
        provider.class.stubs(:openstack)
                      .with('user role', 'list', '--quiet', '--format', 'csv', [['--project', 'foo', 'foo@example.com', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Project","User"')
        provider.class.stubs(:openstack)
                      .with('role', 'remove', [['foo', '--project', 'foo', '--user', 'foo@example.com', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
        provider.class.stubs(:openstack)
                      .with('role', 'remove', [['bar', '--project', 'foo', '--user', 'foo@example.com', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
        provider.destroy
        expect(provider.exists?).to be_falsey
      end

    end

    describe '#exists' do
      subject(:response) do
        provider.class.stubs(:openstack)
                      .with('user role', 'list', '--quiet', '--format', 'csv', [['--project', 'foo', 'foo@example.com', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Project","User"
"1cb05ed7c24279be884ba4f6520262","foo","foo","foo@example.com"
"1cb05ed7c24279be884ba4f6520262","bar","foo","foo@example.com"
')
        response = provider.exists?
      end

      it { is_expected.to be_truthy }

    end

  end
end
