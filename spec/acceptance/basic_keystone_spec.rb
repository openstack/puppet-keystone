require 'spec_helper_acceptance'

describe 'basic keystone server with resources' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      # Common resources
      case $::osfamily {
        'Debian': {
          include ::apt
          class { '::openstack_extras::repo::debian::ubuntu':
            release => 'kilo',
            package_require => true,
          }
        }
        'RedHat': {
          class { '::openstack_extras::repo::redhat::redhat':
            release => 'kilo',
          }
          package { 'openstack-selinux': ensure => 'latest' }
        }
        default: {
          fail("Unsupported osfamily (${::osfamily})")
        }
      }

      class { '::mysql::server': }

      # Keystone resources
      class { '::keystone::client': }
      class { '::keystone::cron::token_flush': }
      class { '::keystone::db::mysql':
        password => 'keystone',
      }
      class { '::keystone':
        verbose             => true,
        debug               => true,
        database_connection => 'mysql://keystone:keystone@127.0.0.1/keystone',
        admin_token         => 'admin_token',
        enabled             => true,
      }
      class { '::keystone::roles::admin':
        email    => 'test@example.tld',
        password => 'a_big_secret',
      }
      class { '::keystone::endpoint':
        public_url => "http://127.0.0.1:5000/",
        admin_url  => "http://127.0.0.1:35357/",
      }
      ::keystone::resource::service_identity { 'beaker-ci':
        service_type        => 'beaker',
        service_description => 'beaker service',
        service_name        => 'beaker',
        password            => 'secret',
        public_url          => 'http://127.0.0.1:1234',
        admin_url           => 'http://127.0.0.1:1234',
        internal_url        => 'http://127.0.0.1:1234',
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(5000) do
      it { is_expected.to be_listening.with('tcp') }
    end

    describe port(35357) do
      it { is_expected.to be_listening.with('tcp') }
    end

    describe cron do
      it { should have_entry('1 0 * * * keystone-manage token_flush >>/var/log/keystone/keystone-tokenflush.log 2>&1').with_user('keystone') }
    end

    describe 'test keystone user/tenant/service/role/endpoint resources' do
      it 'should find beaker user' do
        shell('openstack --os-username admin --os-password a_big_secret --os-tenant-name openstack --os-auth-url http://127.0.0.1:5000/v2.0 user list') do |r|
          expect(r.stdout).to match(/beaker/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find services tenant' do
        shell('openstack --os-username admin --os-password a_big_secret --os-tenant-name openstack --os-auth-url http://127.0.0.1:5000/v2.0 project list') do |r|
          expect(r.stdout).to match(/services/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find beaker service' do
        shell('openstack --os-username admin --os-password a_big_secret --os-tenant-name openstack --os-auth-url http://127.0.0.1:5000/v2.0 service list') do |r|
          expect(r.stdout).to match(/beaker/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find admin role' do
        shell('openstack --os-username admin --os-password a_big_secret --os-tenant-name openstack --os-auth-url http://127.0.0.1:5000/v2.0 role list') do |r|
          expect(r.stdout).to match(/admin/)
          expect(r.stderr).to be_empty
        end
      end
      it 'should find beaker endpoints' do
        shell('openstack --os-username admin --os-password a_big_secret --os-tenant-name openstack --os-auth-url http://127.0.0.1:5000/v2.0 endpoint list --long') do |r|
          expect(r.stdout).to match(/1234/)
          expect(r.stderr).to be_empty
        end
      end
    end
  end
end
