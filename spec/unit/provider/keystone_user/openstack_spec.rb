require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_user/openstack'

provider_class = Puppet::Type.type(:keystone_user).provider(:openstack)

describe provider_class do

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

  describe 'when updating a user' do

    describe '#create' do
      it 'creates a user' do
        provider.class.stubs(:openstack)
                      .with('user', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Project","Email","Enabled"
"1cb05cfed7c24279be884ba4f6520262","foo","foo","foo@example.com",True
')
        provider.class.stubs(:openstack)
                      .with('user', 'create', '--format', 'shell', [['foo', '--enable', '--password', 'foo', '--project', 'foo', '--email', 'foo@example.com', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('email="foo@example.com"
enabled="True"
id="12b23f07d4a3448d8189521ab09610b0"
name="foo"
project_id="5e2001b2248540f191ff22627dc0c2d7"
username="foo"
')
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

    describe '#tenant' do
      it 'gets the tenant with default backend' do
        provider.class.stubs(:openstack)
                      .with('user', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Project","Email","Enabled"
"1cb05cfed7c24279be884ba4f6520262","foo","foo","foo@example.com",True
')
        tenant = provider.tenant
        expect(tenant).to eq('foo')
      end
      it 'gets the tenant with LDAP backend' do
        provider.class.stubs(:openstack)
                      .with('user', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Project","Email","Enabled"
"1cb05cfed7c24279be884ba4f6520262","foo","","foo@example.com",True
')
        provider.class.expects(:openstack)
                      .with('user role', 'list', '--quiet', '--format', 'csv', [['foo', '--project', 'foo', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Project","User"
"1cb05cfed7c24279be884ba4f6520262","foo","foo","foo"
')
        tenant = provider.tenant
        expect(tenant).to eq('foo')
      end
    end
    describe '#tenant=' do
      context 'when using default backend' do
        it 'sets the tenant' do
          provider.class.expects(:openstack)
                        .with('user', 'set', [['foo', '--project', 'bar', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
           provider.class.expects(:openstack)
                         .with('user role', 'list', '--quiet', '--format', 'csv', [['foo', '--project', 'bar', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                         .returns('"ID","Name","Project","User"
"1cb05cfed7c24279be884ba4f6520262","foo","foo","foo"
')
          provider.tenant=('bar')
        end
      end
      context 'when using LDAP read-write backend' do
        it 'sets the tenant when _member_ role exists' do
          provider.class.expects(:openstack)
                        .with('user', 'set', [['foo', '--project', 'bar', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
           provider.class.expects(:openstack)
                         .with('user role', 'list', '--quiet', '--format', 'csv', [['foo', '--project', 'bar', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                         .returns('')
          provider.class.expects(:openstack)
                        .with('role', 'show', '--format', 'shell', [['_member_', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                        .returns('name="_member_"')
          provider.class.expects(:openstack)
                        .with('role', 'add', [['_member_', '--project', 'bar', '--user', 'foo', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
          provider.tenant=('bar')
        end
        it 'sets the tenant when _member_ role does not exist' do
          provider.class.expects(:openstack)
                        .with('user', 'set', [['foo', '--project', 'bar', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
           provider.class.expects(:openstack)
                         .with('user role', 'list', '--quiet', '--format', 'csv', [['foo', '--project', 'bar', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                         .returns('')
          provider.class.expects(:openstack)
                        .with('role', 'show', '--format', 'shell', [['_member_', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                        .raises(Puppet::ExecutionFailure, 'no such role _member_')
          provider.class.expects(:openstack)
                        .with('role', 'create', '--format', 'shell', [['_member_', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])                      
                        .returns('name="_member_"')
          provider.class.expects(:openstack)
                        .with('role', 'add', [['_member_', '--project', 'bar', '--user', 'foo', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
          provider.tenant=('bar')
        end
      end
      context 'when using LDAP read-only backend' do
        it 'sets the tenant when _member_ role exists' do
          provider.class.expects(:openstack)
                        .with('user', 'set', [['foo', '--project', 'bar', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                        .raises(Puppet::ExecutionFailure, 'You are not authorized to perform the requested action: LDAP user update')
           provider.class.expects(:openstack)
                         .with('user role', 'list', '--quiet', '--format', 'csv', [['foo', '--project', 'bar', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                         .returns('')
          provider.class.expects(:openstack)
                        .with('role', 'show', '--format', 'shell', [['_member_', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                        .returns('name="_member_"')
          provider.class.expects(:openstack)
                        .with('role', 'add', [['_member_', '--project', 'bar', '--user', 'foo', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
          provider.tenant=('bar')
        end
        it 'sets the tenant and gets an unexpected exception message' do
          provider.class.expects(:openstack)
                        .with('user', 'set', [['foo', '--project', 'bar', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                        .raises(Puppet::ExecutionFailure, 'unknown error message')
          expect{ provider.tenant=('bar') }.to raise_error(Puppet::ExecutionFailure, /unknown error message/)
        end
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
        :tenant       => 'foo',
        :email        => 'foo@example.com',
        :auth         => {
          'username'    => 'test',
          'password'    => 'abc123',
          'tenant_name' => 'foo',
          'auth_url'    => 'https://127.0.0.1:5000/v2.0',
        }
      }
    end

    it 'checks the password with HTTPS' do
      httpobj = mock('Net::HTTP')
      httpobj.stubs(:use_ssl=).with(true)
      httpobj.stubs(:verify_mode=)
      Net::HTTP.stubs(:start).returns(httpobj)
      reqobj = mock('Net::HTTP::Post')
      reqobj.stubs(:body=)
      reqobj.stubs(:content_type=)
      Net::HTTP::Post.stubs(:start).returns(reqobj)
      respobj = mock('Net::HTTPResponse')
      respobj.stubs(:code).returns('200')
      httpobj.stubs(:request).returns(respobj)
      password = provider.password
      expect(password).to eq('foo')
    end
    it 'fails the password check with HTTPS' do
      httpobj = mock('Net::HTTP')
      httpobj.stubs(:use_ssl=).with(true)
      httpobj.stubs(:verify_mode=)
      Net::HTTP.stubs(:start).returns(httpobj)
      reqobj = mock('Net::HTTP::Post')
      reqobj.stubs(:body=)
      reqobj.stubs(:content_type=)
      Net::HTTP::Post.stubs(:start).returns(reqobj)
      respobj = mock('Net::HTTPResponse')
      respobj.stubs(:code).returns('401')
      httpobj.stubs(:request).returns(respobj)
      password = provider.password
      expect(password).to eq(nil)
    end

    describe 'when updating a user with unmanaged password' do

      let(:user_attrs) do
        {
          :name             => 'foo',
          :ensure           => 'present',
          :enabled          => 'True',
          :password         => 'foo',
          :replace_password => 'False',
          :tenant           => 'foo',
          :email            => 'foo@example.com',
          :auth             => {
            'username'      => 'test',
            'password'      => 'abc123',
            'tenant_name'   => 'foo',
            'auth_url'      => 'http://127.0.0.1:5000/v2.0',
          }
        }
      end

      let(:resource) do
        Puppet::Type::Keystone_user.new(user_attrs)
      end

      let :provider do
        provider_class.new(resource)
      end

      it 'should not try to check password' do
        expect(provider.password).to eq('foo')
      end
    end

  end
end
