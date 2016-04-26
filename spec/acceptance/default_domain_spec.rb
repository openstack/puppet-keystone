require 'spec_helper_acceptance'

describe 'basic keystone server with changed domain id' do
  after(:context) do
    clean_up_manifest = <<-EOM
      include ::openstack_integration::keystone

      keystone_config { 'identity/default_domain_id': ensure => absent}
    EOM
    apply_manifest(clean_up_manifest, :catch_failures => true)
  end

  context 'new domain id' do
    let(:pp) do
      <<-EOM
      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::mysql

      class { '::openstack_integration::keystone':
        default_domain => 'my_default_domain',
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
            .to include_regexp([/Puppet::Type::Keystone_tenant::ProviderOpenstack: Support for a resource without the domain.*using 'Default'.*default domain id is '/])
        end
      end
      it 'should be idempotent' do
        apply_manifest(pp, :catch_changes => true) do |result|
          expect(result.stderr)
            .to include_regexp([/Puppet::Type::Keystone_tenant::ProviderOpenstack: Support for a resource without the domain.*using 'Default'.*default domain id is '/])
        end
      end
    end
    describe 'puppet resources are successful created' do
      it 'for tenant' do
        shell('puppet resource keystone_tenant') do |result|
          expect(result.stdout)
            .to include_regexp([/keystone_tenant { 'project_in_my_default_domain':/,
                                /keystone_tenant { 'project_in_my_default_domain::other_domain':/])
        end
      end
    end
  end
end
