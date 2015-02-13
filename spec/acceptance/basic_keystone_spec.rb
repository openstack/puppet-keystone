require 'spec_helper_acceptance'

describe 'basic keystone server with resources' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      # Common resources
      include ::apt
      # some packages are not autoupgraded in trusty.
      # it will be fixed in liberty, but broken in kilo.
      $need_to_be_upgraded = ['python-tz', 'python-pbr']
      apt::source { 'trusty-updates-kilo':
        location          => 'http://ubuntu-cloud.archive.canonical.com/ubuntu/',
        release           => 'trusty-updates',
        required_packages => 'ubuntu-cloud-keyring',
        repos             => 'kilo/main',
        trusted_source    => true,
      } ->
      package { $need_to_be_upgraded:
        ensure  => latest,
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
        public_url => "https://${::fqdn}:5000/",
        admin_url  => "https://${::fqdn}:35357/",
      }
      ::keystone::resource::service_identity { 'beaker-ci':
        service_type        => 'beaker',
        service_description => 'beaker service',
        service_name        => 'beaker',
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

  end
end
