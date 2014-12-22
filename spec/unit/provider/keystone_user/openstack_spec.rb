require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_user/openstack'

provider_class = Puppet::Type.type(:keystone_user).provider(:openstack)

describe provider_class do

  describe 'when updating a user' do

    let(:user_attrs) do
      {
        :name         => 'foo',
        :ensure       => 'present',
        :enabled      => 'True',
        :password     => 'foo',
        :tenant       => 'foo',
        :email        => 'foo@example.com',
        :auth         => {
          'username'    => 'test',
          'password'    => 'abc123',
          'tenant_name' => 'foo',
          'auth_url'    => 'http://127.0.0.1:5000/v2.0',
        }
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_user.new(user_attrs)
    end

    let(:provider) do
      provider_class.new(resource)
    end

    describe '#create' do
      it 'creates a user' do
        provider.class.stubs(:openstack)
                      .with('user', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Project","Email","Enabled"
"1cb05cfed7c24279be884ba4f6520262","foo","foo","foo@example.com",True
')
        provider.class.stubs(:openstack)
                      .with('user', 'create', [['foo', '--enable', '--password', 'foo', '--project', 'foo', '--email', 'foo@example.com', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
        provider.create
        expect(provider.exists?).to be_truthy
      end
    end

    describe '#destroy' do
      it 'destroys a user' do
        provider.class.stubs(:openstack)
                      .with('user', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Project","Email","Enabled"')
        provider.class.stubs(:openstack)
                      .with('user', 'delete', [['foo', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
        provider.destroy
        expect(provider.exists?).to be_falsey
      end

    end

    describe '#exists' do
      context 'when user exists' do

        subject(:response) do
          provider.class.stubs(:openstack)
                        .with('user', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                        .returns('"ID","Name","Project","Email","Enabled"
"1cb05cfed7c24279be884ba4f6520262","foo","foo","foo@example.com",True
')
          response = provider.exists?
        end

        it { is_expected.to be_truthy }
      end

      context 'when user does not exist' do

        subject(:response) do
          provider.class.stubs(:openstack)
                        .with('user', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                        .returns('"ID","Name","Project","Email","Enabled"')
          response = provider.exists?
        end

        it { is_expected.to be_falsey }
      end
    end

    describe '#instances' do
      it 'finds every user' do
        provider.class.stubs(:openstack)
                      .with('user', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Project","Email","Enabled"
"1cb05cfed7c24279be884ba4f6520262","foo","foo","foo@example.com",True
')
        instances = provider.instances
        expect(instances.count).to eq(1)
      end
    end

  end
end
