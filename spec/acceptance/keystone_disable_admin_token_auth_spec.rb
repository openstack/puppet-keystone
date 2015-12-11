require 'spec_helper_acceptance'

describe 'basic keystone server with secured pipeline' do
  let(:pp) do
    <<-EOM
    include ::openstack_integration
    include ::openstack_integration::repos
    include ::openstack_integration::mysql
    include ::openstack_integration::keystone

    class { '::keystone::disable_admin_token_auth': }
    class { '::openstack_extras::auth_file':
      password       => 'a_big_secret',
      auth_url       => 'http://127.0.0.1:5000/v3/',
      project_domain => 'default',
      user_domain    => 'default',
      project_name   => 'openstack'
    }
    EOM
  end

  describe 'puppet apply' do
    it 'should work with no errors' do
      apply_manifest(pp, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/etc/keystone/keystone-paste.ini') do
      it { should_not contain('pipeline = .*admin_token_auth') }
    end

    describe 'authentication' do
      it 'should authenticate with password credentials' do
        shell("openstack --os-username admin --os-password a_big_secret --os-project-name openstack --os-auth-url http://127.0.0.1:5000/v2.0 user list") do |r|
          expect(r.stdout).to match(/admin/)
          expect(r.stderr).to be_empty
        end
      end
    end
  end

end
