require 'spec_helper_acceptance'

describe 'keystone server running with Apache/WSGI with resources' do

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
        '--os-username adminv3 --os-password a_big_secret --os-project-name openstackv3' \
        ' --os-user-domain-name admin_domain --os-project-domain-name admin_domain'

    end
    describe "with v3 service with v3 credentials" do
      include_examples 'keystone user/tenant/service/role/endpoint resources using v3 API',
        '--os-username beaker-civ3 --os-password secret --os-project-name servicesv3 --os-user-domain-name service_domain --os-project-domain-name service_domain'

    end
  end
  describe 'composite namevar quick test' do
    context 'similar resources different naming' do
      let(:pp) do
        <<-EOM
        keystone_tenant { 'openstackv3':
          ensure      => present,
          enabled     => true,
          description => 'admin tenant',
          domain      => 'admin_domain'
        }
        keystone_user { 'adminv3::useless_when_the_domain_is_set':
          ensure      => present,
          enabled     => true,
          email       => 'test@example.tld',
          password    => 'a_big_secret',
          domain      => 'admin_domain'
        }
        keystone_user_role { 'adminv3::admin_domain@openstackv3::admin_domain':
          ensure         => present,
          roles          => ['admin'],
        }
        EOM
      end
      it 'should not do any modification' do
        apply_manifest(pp, :catch_changes => true)
      end
    end
  end
  describe 'composite namevar for keystone_service' do
    let(:pp) do
      <<-EOM
      keystone_service { 'service_1::type_1': ensure => present }
      keystone_service { 'service_1': type => 'type_2', ensure => present }
      EOM
    end
    it 'should be possible to create two services different only by their type' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'composite namevar for keystone_service and keystone_endpoint' do
    let(:pp) do
      <<-EOM
      keystone_service { 'service_1::type_1': ensure => present }
      keystone_service { 'service_1': type => 'type_2', ensure => present }
      keystone_endpoint { 'RegionOne/service_1::type_2':
        ensure => present,
        public_url => 'http://public_service1_type2',
        internal_url => 'http://internal_service1_type2',
        admin_url => 'http://admin_service1_type2'
      }
      keystone_endpoint { 'service_1':
        ensure => present,
        region => 'RegionOne',
        type => 'type_1',
        public_url   => 'http://public_service1_type1/',
        internal_url => 'http://internal_service1_type1/',
        admin_url    => 'http://admin_service1_type1/'
      }
      EOM
    end
    it 'should be possible to create two services different only by their type' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
    describe 'puppet service are created' do
      it 'for service' do
        shell('puppet resource keystone_service') do |result|
          expect(result.stdout)
            .to include_regexp([/keystone_service { 'service_1::type_1':/,
                                /keystone_service { 'service_1::type_2':/])
        end
      end
    end
    describe 'puppet endpoints are created' do
      it 'for service' do
        shell('puppet resource keystone_endpoint') do |result|
          expect(result.stdout)
            .to include_regexp([/keystone_endpoint { 'RegionOne\/service_1::type_1':/,
                                /keystone_endpoint { 'RegionOne\/service_1::type_2':/])
        end
      end
    end
  end

  context '#keystone_domain_config' do
    # make sure everything is clean before playing the manifest
    shared_examples 'clean_domain_configuration', :clean_domain_cfg => true do
      before(:context) do
        hosts.each do |host|
          on host, 'rm -rf /etc/keystone/domains >/dev/null 2>&1'
          on host, 'rm -rf /tmp/keystone.*.conf >/dev/null 2>&1'
        end
      end
    end

    context 'one domain configuration', :clean_domain_cfg => true  do
      context 'simple use case' do
        it_behaves_like 'puppet_apply_success', <<-EOM
          file { '/etc/keystone/domains': ensure => directory }
          keystone_domain_config { 'services::ldap/url':
            value => 'http://auth.com/1',
          }
        EOM

        context '/etc/keystone/domains/keystone.services.conf' do
          # the idiom

          # note: cannot use neither instance variable nor let on
          # parameter for shared_example
          it_behaves_like 'a_valid_configuration', <<-EOC

[ldap]
url=http://auth.com/1
EOC
        end
      end

      context 'with a non default identity/domain_config_dir' do
        it_behaves_like 'puppet_apply_success', <<-EOM
        keystone_config { 'identity/domain_config_dir': value => '/tmp' }
        keystone_domain_config { 'services::ldap/url':
          value => 'http://auth.com/1',
        }
        EOM

        context '/tmp/keystone.services.conf' do
          it_behaves_like 'a_valid_configuration', <<-EOC

[ldap]
url=http://auth.com/1
EOC
        end
      end
    end

    context 'with a multiple configurations', :clean_domain_cfg => true do
      it_behaves_like 'puppet_apply_success', <<-EOM
      file { '/etc/keystone/domains': ensure => directory }
      keystone_config { 'identity/domain_config_dir': value => '/etc/keystone/domains' }
      keystone_domain_config { 'services::ldap/url':
        value => 'http://auth.com/1',
      }
      keystone_domain_config { 'services::http/url':
        value => 'http://auth.com/2',
      }
      keystone_domain_config { 'external::ldap/url':
        value => 'http://ext-auth.com/1',
      }
      EOM

      describe command('puppet resource keystone_domain_config') do
        its(:exit_status) { is_expected.to eq(0) }
        its(:stdout) { is_expected.to eq(<<EOO) }
keystone_domain_config { 'external::ldap/url':
  ensure => 'present',
  value  => 'http://ext-auth.com/1',
}
keystone_domain_config { 'services::http/url':
  ensure => 'present',
  value  => 'http://auth.com/2',
}
keystone_domain_config { 'services::ldap/url':
  ensure => 'present',
  value  => 'http://auth.com/1',
}
EOO
      end

      describe '/etc/keystone/domains/keystone.services.conf' do
        it_behaves_like 'a_valid_configuration', <<EOC

[http]
url=http://auth.com/2

[ldap]
url=http://auth.com/1
EOC
      end
      describe '/etc/keystone/domains/keystone.external.conf' do
        it_behaves_like 'a_valid_configuration', <<EOC

[ldap]
url=http://ext-auth.com/1
EOC
      end
    end

    context 'checking that the purge is working' do
      it_behaves_like 'puppet_apply_success', <<-EOM
      resources { 'keystone_domain_config': purge => true }
      keystone_domain_config { 'services::ldap/url':
        value => 'http://auth.com/1',
      }
      EOM

      context '/etc/keystone/domains/keystone.services.conf' do
        it_behaves_like 'a_valid_configuration', <<-EOC

[http]

[ldap]
url=http://auth.com/1
EOC
      end
    end
    context '#ldap_backend', :clean_domain_cfg => true do
      context 'manifest' do
        let(:pp) do
      <<-EOM
      class { '::openstack_integration::keystone':
        default_domain      => 'default_domain',
        using_domain_config => true,
      }
      keystone_domain { 'domain_1_ldap_backend': ensure => present }
      keystone_domain { 'domain_2_ldap_backend': ensure => present }
      keystone::ldap_backend { 'domain_1_ldap_backend':
        url  => 'ldap://foo',
        user => 'cn=foo,dc=example,dc=com',
        identity_driver => 'ldap',
      }
      keystone::ldap_backend { 'domain_2_ldap_backend':
        url  => 'ldap://bar',
        user => 'cn=bar,dc=test,dc=com',
        identity_driver => 'ldap',
      }
      EOM
        end
        it 'should apply the manifest correctly' do
          apply_manifest(pp, :accept_all_exit_codes => true)
          # Cannot really test it as keystone will try to connect to
          # the ldap backend when it restarts.  But the ldap server
          # which doesn't exit.  The next "test" clean everything up
          # to have a working keystone again.

          # TODO: Sould we add a working ldap server ?
        end
        context '/etc/keystone/domains/keystone.domain_1_ldap_backend.conf' do
          it_behaves_like 'a_valid_configuration', <<-EOC

[ldap]
use_pool=False
pool_retry_delay=0.1
url=ldap://foo
auth_pool_size=100
auth_pool_connection_lifetime=60
user=cn=foo,dc=example,dc=com
pool_connection_timeout=-1
use_auth_pool=False
pool_connection_lifetime=600
pool_size=10
pool_retry_max=3
EOC
        end

        context '/etc/keystone/domains/keystone.domain_2_ldap_backend.conf' do
          it_behaves_like 'a_valid_configuration', <<-EOC

[ldap]
pool_retry_delay=0.1
url=ldap://bar
user=cn=bar,dc=test,dc=com
use_pool=False
pool_retry_max=3
pool_size=10
auth_pool_size=100
auth_pool_connection_lifetime=60
use_auth_pool=False
pool_connection_lifetime=600
pool_connection_timeout=-1
EOC
        end
      end
      context 'clean up', :clean_domain_cfg => true do
        # we must revert the changes as ldap backend is not fully
        # functional and are "domain read only".  All subsequent tests
        # will fail without this.
        it_behaves_like 'puppet_apply_success', <<-EOM
        keystone_config {
          'identity/driver': value => 'sql';
          'credential/driver': ensure => absent;
          'assignment/driver': ensure => absent;
          'identity/domain_specific_drivers_enabled': ensure => absent;
          'identity/domain_config_dir': ensure => absent;
        }
        EOM
      end
    end
  end
end
