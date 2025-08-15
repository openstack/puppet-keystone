require 'spec_helper'

describe 'keystone::ldap_backend' do
  shared_examples 'keystone::ldap_backend' do

    context 'Using Default domain' do
      let(:title) { 'Default' }
      let(:pre_condition) do
        <<-EOM
        class { 'keystone':
          using_domain_config => true
        }
        EOM
      end

      context 'with basic params' do
        let :params do
          {
            :url                                  => 'ldap://foo',
            :user                                 => 'cn=foo,dc=example,dc=com',
            :password                             => 'abcdefg',
            :suffix                               => 'dc=example,dc=com',
            :query_scope                          => 'sub',
            :page_size                            => '50',
            :user_tree_dn                         => 'cn=users,dc=example,dc=com',
            :user_filter                          => '(memberOf=cn=openstack,cn=groups,cn=accounts,dc=example,dc=com)',
            :user_objectclass                     => 'inetUser',
            :user_id_attribute                    => 'uid',
            :user_name_attribute                  => 'cn',
            :user_description_attribute           => 'description',
            :user_mail_attribute                  => 'mail',
            :user_enabled_attribute               => 'UserAccountControl',
            :user_enabled_mask                    => '2',
            :user_enabled_default                 => '512',
            :user_enabled_invert                  => 'False',
            :user_attribute_ignore                => '',
            :user_default_project_id_attribute    => 'defaultProject',
            :user_pass_attribute                  => 'krbPassword',
            :user_enabled_emulation               => 'True',
            :user_enabled_emulation_dn            => 'cn=openstack-enabled,cn=groups,cn=accounts,dc=example,dc=com',
            :user_additional_attribute_mapping    => 'description:name, gecos:name',
            :group_tree_dn                        => 'ou=groups,ou=openstack,dc=example,dc=com',
            :group_filter                         => 'cn=enabled-groups,cn=groups,cn=accounts,dc=example,dc=com',
            :group_objectclass                    => 'organizationalRole',
            :group_id_attribute                   => 'cn',
            :group_name_attribute                 => 'cn',
            :group_member_attribute               => 'roleOccupant',
            :group_members_are_ids                => 'True',
            :group_desc_attribute                 => 'description',
            :group_attribute_ignore               => '',
            :group_additional_attribute_mapping   => '',
            :group_ad_nesting                     => 'True',
            :chase_referrals                      => 'False',
            :use_tls                              => 'False',
            :tls_cacertdir                        => '/etc/ssl/certs/',
            :tls_cacertfile                       => '/etc/ssl/certs/ca-certificates.crt',
            :tls_req_cert                         => 'demand',
            :identity_driver                      => 'ldap',
            :connection_timeout                   => 111,
            :use_pool                             => 'True',
            :pool_size                            => 20,
            :pool_retry_max                       => 2,
            :pool_retry_delay                     => 0.2,
            :pool_connection_timeout              => 222,
            :pool_connection_lifetime             => 222,
            :use_auth_pool                        => 'True',
            :auth_pool_size                       => 20,
            :auth_pool_connection_lifetime        => 200,
          }
        end

        it {
          is_expected.to contain_package('python-ldappool').with(
            :name => platform_params[:python_ldappool_package_name],
          )
        }
        it 'should prepare the config file' do
          is_expected.to contain_file('/etc/keystone/domains/keystone.Default.conf').with(
            :ensure => 'file',
            :mode   => '0640',
            :owner  => 'root',
            :group  => 'keystone'
          )
        end
        it 'should have basic params' do
          # basic params
          is_expected.to contain_keystone_domain_config('Default::ldap/url').with_value('ldap://foo')
          is_expected.to contain_keystone_domain_config('Default::ldap/user').with_value('cn=foo,dc=example,dc=com')
          is_expected.to contain_keystone_domain_config('Default::ldap/password').with_value('abcdefg').with_secret(true)
          is_expected.to contain_keystone_domain_config('Default::ldap/suffix').with_value('dc=example,dc=com')
          is_expected.to contain_keystone_domain_config('Default::ldap/query_scope').with_value('sub')
          is_expected.to contain_keystone_domain_config('Default::ldap/page_size').with_value('50')

          # users
          is_expected.to contain_keystone_domain_config('Default::ldap/user_tree_dn').with_value('cn=users,dc=example,dc=com')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_filter').with_value('(memberOf=cn=openstack,cn=groups,cn=accounts,dc=example,dc=com)')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_objectclass').with_value('inetUser')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_id_attribute').with_value('uid')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_name_attribute').with_value('cn')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_description_attribute').with_value('description')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_mail_attribute').with_value('mail')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_enabled_attribute').with_value('UserAccountControl')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_enabled_mask').with_value('2')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_enabled_default').with_value('512')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_enabled_invert').with_value('False')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_attribute_ignore').with_value('')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_default_project_id_attribute').with_value('defaultProject')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_tree_dn').with_value('cn=users,dc=example,dc=com')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_pass_attribute').with_value('krbPassword')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_enabled_emulation').with_value('True')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_enabled_emulation_dn').with_value('cn=openstack-enabled,cn=groups,cn=accounts,dc=example,dc=com')
          is_expected.to contain_keystone_domain_config('Default::ldap/user_additional_attribute_mapping').with_value('description:name, gecos:name')

          # groups
          is_expected.to contain_keystone_domain_config('Default::ldap/group_tree_dn').with_value('ou=groups,ou=openstack,dc=example,dc=com')
          is_expected.to contain_keystone_domain_config('Default::ldap/group_filter').with_value('cn=enabled-groups,cn=groups,cn=accounts,dc=example,dc=com')
          is_expected.to contain_keystone_domain_config('Default::ldap/group_objectclass').with_value('organizationalRole')
          is_expected.to contain_keystone_domain_config('Default::ldap/group_id_attribute').with_value('cn')
          is_expected.to contain_keystone_domain_config('Default::ldap/group_member_attribute').with_value('roleOccupant')
          is_expected.to contain_keystone_domain_config('Default::ldap/group_members_are_ids').with_value('True')
          is_expected.to contain_keystone_domain_config('Default::ldap/group_desc_attribute').with_value('description')
          is_expected.to contain_keystone_domain_config('Default::ldap/group_name_attribute').with_value('cn')
          is_expected.to contain_keystone_domain_config('Default::ldap/group_attribute_ignore').with_value('')
          is_expected.to contain_keystone_domain_config('Default::ldap/group_additional_attribute_mapping').with_value('')
          is_expected.to contain_keystone_domain_config('Default::ldap/group_ad_nesting').with_value('True')

          # referrals
          is_expected.to contain_keystone_domain_config('Default::ldap/chase_referrals').with_value('False')

          # tls
          is_expected.to contain_keystone_domain_config('Default::ldap/use_tls').with_value('False')
          is_expected.to contain_keystone_domain_config('Default::ldap/tls_cacertdir').with_value('/etc/ssl/certs/')
          is_expected.to contain_keystone_domain_config('Default::ldap/tls_cacertfile').with_value('/etc/ssl/certs/ca-certificates.crt')
          is_expected.to contain_keystone_domain_config('Default::ldap/tls_req_cert').with_value('demand')

          is_expected.to contain_keystone_domain_config('Default::ldap/connection_timeout').with_value('111')

          # ldap pooling
          is_expected.to contain_keystone_domain_config('Default::ldap/use_pool').with_value('True')
          is_expected.to contain_keystone_domain_config('Default::ldap/pool_size').with_value('20')
          is_expected.to contain_keystone_domain_config('Default::ldap/pool_retry_max').with_value('2')
          is_expected.to contain_keystone_domain_config('Default::ldap/pool_retry_delay').with_value('0.2')
          is_expected.to contain_keystone_domain_config('Default::ldap/pool_connection_timeout').with_value('222')
          is_expected.to contain_keystone_domain_config('Default::ldap/pool_connection_lifetime').with_value('222')
          is_expected.to contain_keystone_domain_config('Default::ldap/use_auth_pool').with_value('True')
          is_expected.to contain_keystone_domain_config('Default::ldap/auth_pool_size').with_value('20')
          is_expected.to contain_keystone_domain_config('Default::ldap/auth_pool_connection_lifetime').with_value('200')

          # drivers
          is_expected.to contain_keystone_domain_config('Default::identity/driver').with_value('ldap')
        end

        context 'with keystone domain creation enabled' do
          before do
            params.merge! ({
              :create_domain_entry => true
            })
          end
          it 'creates the keystone domain and refreshes the service' do
            is_expected.to contain_keystone_domain(title).with(
              :ensure  => 'present',
              :enabled => true
            )
          end
        end
      end
    end

    context 'Using non Default domain' do
      let(:title) { 'foobar' }
      let :params do
        {
          :url => 'ldap://foo',
          :user => 'cn=foo,dc=example,dc=com'
        }
      end
      let(:pre_condition) do
        <<-EOM
        class { 'keystone':
          using_domain_config => true
        }
        EOM
      end
      it 'should use the domain from the title' do
        is_expected.to contain_keystone_domain_config('foobar::ldap/url').with_value('ldap://foo')
        is_expected.to contain_keystone_domain_config('foobar::ldap/user').with_value('cn=foo,dc=example,dc=com')
      end
    end

    context 'checks' do
      let(:title) { 'domain' }
      context 'with domain specific drivers disabled' do
        let(:pre_condition) do
        <<-EOM
        class { 'keystone': }
        EOM
        end

        it { should raise_error(Puppet::Error) }
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          { :python_ldappool_package_name => 'python3-ldappool' }
        when 'RedHat'
          { :python_ldappool_package_name => 'python3-ldappool' }
        end
      end
      it_behaves_like 'keystone::ldap_backend'
    end
  end
end
