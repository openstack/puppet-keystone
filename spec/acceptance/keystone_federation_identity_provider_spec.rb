require 'spec_helper_acceptance'

describe 'keystone server running with Apache/WSGI as Identity Provider' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::mysql
      include ::openstack_integration::keystone

      ::keystone::resource::service_identity { 'beaker-ci':
        service_type        => 'beaker',
        service_description => 'beaker service',
        service_name        => 'beaker',
        password            => 'secret',
        public_url          => 'http://127.0.0.1:1234',
        admin_url           => 'http://127.0.0.1:1234',
        internal_url        => 'http://127.0.0.1:1234',
      }
      # v3 admin
      # we don't use ::keystone::roles::admin but still create resources manually:
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
      ::keystone::resource::service_identity { 'beaker-civ3::service_domain':
        service_type        => 'beakerv3',
        service_description => 'beakerv3 service',
        service_name        => 'beakerv3',
        password            => 'secret',
        tenant              => 'servicesv3::service_domain',
        public_url          => 'http://127.0.0.1:1234/v3',
        admin_url           => 'http://127.0.0.1:1234/v3',
        internal_url        => 'http://127.0.0.1:1234/v3',
        user_domain         => 'service_domain',
        project_domain      => 'service_domain',
      }
      class { '::keystone::federation::identity_provider':
        idp_entity_id     => 'http://127.0.0.1:5000/v3/OS-FEDERATION/saml2/idp',
        idp_sso_endpoint  => 'http://127.0.0.1:5000/v3/OS-FEDERATION/saml2/sso',
        idp_metadata_path => '/etc/keystone/saml2_idp_metadata.xml',
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(5000) do
      it { is_expected.to be_listening }
    end

    describe port(35357) do
      it { is_expected.to be_listening }
    end

    describe cron do
      it { is_expected.to have_entry('1 0 * * * keystone-manage token_flush >>/var/log/keystone/keystone-tokenflush.log 2>&1').with_user('keystone') }
    end

    shared_examples_for 'keystone user/tenant/service/role/endpoint resources using v2 API' do |auth_creds|
      it 'should find users in the default domain' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v2.0 --os-identity-api-version 2 user list") do |r|
          expect(r.stdout).to match(/admin/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find tenants in the default domain' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v2.0 --os-identity-api-version 2 project list") do |r|
          expect(r.stdout).to match(/openstack/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find beaker service' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v2.0 --os-identity-api-version 2 service list") do |r|
          expect(r.stdout).to match(/beaker/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find admin role' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v2.0 --os-identity-api-version 2 role list") do |r|
          expect(r.stdout).to match(/admin/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find beaker endpoints' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v2.0 --os-identity-api-version 2 endpoint list --long") do |r|
          expect(r.stdout).to match(/1234/)
          expect(r.stderr).to be_empty
        end
      end
    end
    shared_examples_for 'keystone user/tenant/service/role/endpoint resources using v3 API' do |auth_creds|
      it 'should find beaker user' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 user list") do |r|
          expect(r.stdout).to match(/beaker/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find services tenant' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 project list") do |r|
          expect(r.stdout).to match(/services/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find beaker service' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 service list") do |r|
          expect(r.stdout).to match(/beaker/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find admin role' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 role list") do |r|
          expect(r.stdout).to match(/admin/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find beaker endpoints' do
        shell("openstack #{auth_creds} --os-auth-url http://127.0.0.1:5000/v3 --os-identity-api-version 3 endpoint list") do |r|
          expect(r.stdout).to match(/1234/)
          expect(r.stderr).to be_empty
        end
      end
    end
    describe 'with v2 admin with v2 credentials' do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v2 API',
                       '--os-username admin --os-password a_big_secret --os-project-name openstack'
    end
    describe 'with v2 service with v2 credentials' do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v2 API',
                       '--os-username beaker-ci --os-password secret --os-project-name services'
    end
    describe 'with v2 admin with v3 credentials' do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v3 API',
                       '--os-username admin --os-password a_big_secret --os-project-name openstack --os-user-domain-name Default --os-project-domain-name Default'
    end
    describe "with v2 service with v3 credentials" do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v3 API',
                       '--os-username beaker-ci --os-password secret --os-project-name services --os-user-domain-name Default --os-project-domain-name Default'
    end
    describe 'with v3 admin with v3 credentials' do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v3 API',
                       '--os-username adminv3 --os-password a_big_secret --os-project-name openstackv3 --os-user-domain-name admin_domain --os-project-domain-name admin_domain'
    end
    describe "with v3 service with v3 credentials" do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v3 API',
                       '--os-username beaker-civ3 --os-password secret --os-project-name servicesv3 --os-user-domain-name service_domain --os-project-domain-name service_domain'
    end

  end
end
