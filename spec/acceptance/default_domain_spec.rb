require 'spec_helper_acceptance'

describe 'basic keystone server with changed domain id' do
  after(:context) do
    clean_up_manifest = <<-EOM
      class { '::keystone':
            verbose             => true,
            debug               => true,
            database_connection => 'mysql+pymysql://keystone:keystone@127.0.0.1/keystone',
            admin_token         => 'admin_token',
            enabled             => true,
      }

      keystone_config { 'identity/default_domain_id': ensure => absent}
    EOM
    apply_manifest(clean_up_manifest, :catch_failures => true)
  end

  context 'new domain id' do
    let(:pp) do
      <<-EOM
      Exec { logoutput => 'on_failure' }

      # make sure apache is stopped before keystone eventlet
      # in case of wsgi was run before
      class { '::apache':
        service_ensure => 'stopped',
      }
      Service['httpd'] -> Service['keystone']

      # Common resources
      case $::osfamily {
        'Debian': {
          include ::apt
          class { '::openstack_extras::repo::debian::ubuntu':
            release         => 'liberty',
            repo            => 'proposed',
            package_require => true,
          }
        }
        'RedHat': {
          class { '::openstack_extras::repo::redhat::redhat':
            manage_rdo => false,
            repo_hash => {
              'openstack-common-testing' => {
                'baseurl'  => 'http://cbs.centos.org/repos/cloud7-openstack-common-testing/x86_64/os/',
                'descr'    => 'openstack-common-testing',
                'gpgcheck' => 'no',
              },
              'openstack-liberty-testing' => {
                'baseurl'  => 'http://cbs.centos.org/repos/cloud7-openstack-liberty-testing/x86_64/os/',
                'descr'    => 'openstack-liberty-testing',
                'gpgcheck' => 'no',
              },
              'openstack-liberty-trunk' => {
                'baseurl'  => 'http://trunk.rdoproject.org/centos7-liberty/current-passed-ci/',
                'descr'    => 'openstack-liberty-trunk',
                'gpgcheck' => 'no',
              },
            },
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
        database_connection => 'mysql+pymysql://keystone:keystone@127.0.0.1/keystone',
        admin_token         => 'admin_token',
        enabled             => true,
        default_domain      => 'my_default_domain'
      }
      keystone_tenant { 'project_in_my_default_domain':
        ensure      => present,
        enabled     => true,
        description => 'Project in another default domain',
      }
      keystone_user { 'user_in_my_default_domain':
        ensure      => present,
        enabled     => true,
        email       => 'test@example.tld',
        password    => 'a_big_secret',
      }
      keystone_user_role { 'user_in_my_default_domain@project_in_my_default_domain':
        ensure         => present,
        roles          => ['admin'],
      }
      keystone_domain { 'other_domain': ensure => present }
      keystone_user { 'user_in_my_default_domain::other_domain':
          ensure      => present,
          enabled     => true,
          email       => 'test@example.tld',
          password    => 'a_big_secret',
      }
      keystone_tenant { 'project_in_my_default_domain::other_domain':
          ensure      => present,
          enabled     => true,
          description => 'Project in other domain',
       }
      keystone_user_role { 'user_in_my_default_domain@::other_domain':
        ensure         => present,
        user_domain    => 'other_domain',
        roles          => ['admin'],
      }
      EOM
    end

    describe 'puppet apply' do
      it 'should work with no errors and catch deprecation warning' do
        apply_manifest(pp, :catch_failures => true) do |result|
          expect(result.stderr)
            .to include_regexp([/Keystone_tenant\[project_in_my_default_domain\]\/domain: Support for a resource without.*. Currently using 'my_default_domain' as default domain/,
                                /Keystone_user\[user_in_my_default_domain\]\/domain/,
                                /Keystone_user_role\[user_in_my_default_domain@project_in_my_default_domain\]\/user_domain/,
                                /Keystone_user_role\[user_in_my_default_domain@project_in_my_default_domain\]\/project_domain/])
        end
      end
      it 'should be idempotent' do
        apply_manifest(pp, :catch_changes => true) do |result|
          expect(result.stderr)
            .to include_regexp(/Warning: \/Keystone_tenant.*Currently using 'my_default_domain'/)
        end
      end
    end
    describe 'puppet resources are successful created' do
      it 'for tenant' do
        shell('puppet resource keystone_tenant') do |result|
          expect(result.stdout)
            .to include_regexp([/keystone_tenant { 'project_in_my_default_domain::my_default_domain':/,
                                /keystone_tenant { 'project_in_my_default_domain::other_domain':/])
        end
      end
      it 'for user' do
        shell('puppet resource keystone_user') do |result|
          expect(result.stdout)
            .to include_regexp([/keystone_user { 'user_in_my_default_domain::my_default_domain':/,
                                /keystone_user { 'user_in_my_default_domain::other_domain':/])
        end
      end
      it 'for role' do
        shell('puppet resource keystone_user_role') do |result|
          expect(result.stdout)
            .to include_regexp([/keystone_user_role { 'user_in_my_default_domain::my_default_domain@project_in_my_default_domain::my_default_domain':/,
                                /keystone_user_role { 'user_in_my_default_domain::other_domain@::other_domain':/])
        end
      end
    end
  end
end
