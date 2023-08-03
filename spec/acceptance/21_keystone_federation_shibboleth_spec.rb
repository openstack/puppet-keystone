require 'spec_helper_acceptance'

describe 'keystone server running with Apache/WSGI as Service Provider with Shibboleth' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include openstack_integration
      include openstack_integration::repos
      include openstack_integration::apache
      include openstack_integration::mysql
      include openstack_integration::memcached
      include openstack_integration::keystone

      keystone::resource::service_identity { 'ci':
        service_type        => 'ci',
        service_description => 'ci service',
        service_name        => 'ci',
        password            => 'secret',
        public_url          => 'http://127.0.0.1:1234',
        admin_url           => 'http://127.0.0.1:1234',
        internal_url        => 'http://127.0.0.1:1234',
      }
      # v3 admin
      keystone_domain { 'admin_domain':
        ensure      => present,
        enabled     => true,
        description => 'Domain for admin v3 users',
      }
      keystone_domain { 'service_domain':
        ensure      => present,
        enabled     => true,
        description => 'Domain for admin v3 users',
      }
      keystone_tenant { 'servicesv3::service_domain':
        ensure      => present,
        enabled     => true,
        description => 'Tenant for the openstack services',
      }
      keystone_tenant { 'openstackv3::admin_domain':
        ensure      => present,
        enabled     => true,
        description => 'admin tenant',
      }
      keystone_user { 'adminv3::admin_domain':
        ensure      => present,
        enabled     => true,
        email       => 'test@example.tld',
        password    => 'a_big_secret',
      }
      keystone_user_role { 'adminv3::admin_domain@openstackv3::admin_domain':
        ensure => present,
        roles  => ['admin'],
      }
      # service user exists only in the service_domain - must
      # use v3 api
      keystone::resource::service_identity { 'civ3::service_domain':
        service_type        => 'civ3',
        service_description => 'civ3 service',
        service_name        => 'civ3',
        password            => 'secret',
        tenant              => 'servicesv3::service_domain',
        public_url          => 'http://127.0.0.1:1234/v3',
        admin_url           => 'http://127.0.0.1:1234/v3',
        internal_url        => 'http://127.0.0.1:1234/v3',
        user_domain         => 'service_domain',
        project_domain      => 'service_domain',
      }
      class { 'keystone::federation::shibboleth':
        methods => 'password, token, oauth1, saml2',
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(5000) do
      it { is_expected.to be_listening }
    end

    shared_examples_for 'keystone user/tenant/service/role/endpoint resources using v3 API' do |auth_creds|
      it 'should find ci user' do
        command("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 user list") do |r|
          expect(r.stdout).to match(/ci/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find services tenant' do
        command("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 project list") do |r|
          expect(r.stdout).to match(/services/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find ci service' do
        command("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 service list") do |r|
          expect(r.stdout).to match(/ci/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find admin role' do
        command("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 role assignment list --names") do |r|
          expect(r.stdout).to match(/admin/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find ci endpoints' do
        command("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 endpoint list") do |r|
          expect(r.stdout).to match(/1234/)
          expect(r.stderr).to be_empty
        end
      end
    end
    describe 'with v2 admin with v3 credentials' do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v3 API',
                       '--os-username admin --os-password a_big_secret --os-project-name openstack --os-user-domain-name Default --os-project-domain-name Default'
    end
    describe "with v2 service with v3 credentials" do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v3 API',
                       '--os-username ci --os-password secret --os-project-name services --os-user-domain-name Default --os-project-domain-name Default'
    end
    describe 'with v3 admin with v3 credentials' do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v3 API',
                       '--os-username adminv3 --os-password a_big_secret --os-project-name openstackv3 --os-user-domain-name admin_domain --os-project-domain-name admin_domain'
    end
    describe "with v3 service with v3 credentials" do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v3 API',
                       '--os-username civ3 --os-password secret --os-project-name servicesv3 --os-user-domain-name service_domain --os-project-domain-name service_domain'
    end

  end
end
