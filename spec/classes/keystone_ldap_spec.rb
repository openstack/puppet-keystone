require 'spec_helper'

describe 'keystone::ldap' do
  shared_examples 'keystone::ldap' do
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
        :chase_referrals                      => 'False',
        :use_tls                              => 'False',
        :tls_cacertdir                        => '/etc/ssl/certs/',
        :tls_cacertfile                       => '/etc/ssl/certs/ca-certificates.crt',
        :tls_req_cert                         => 'demand',
        :identity_driver                      => 'ldap',
        :use_pool                             => true,
        :pool_size                            => 10,
        :pool_retry_max                       => 3,
        :pool_retry_delay                     => 0.1,
        :pool_connection_timeout              => -1,
        :pool_connection_lifetime             => 600,
        :use_auth_pool                        => true,
        :auth_pool_size                       => 100,
        :auth_pool_connection_lifetime        => 60,
      }
    end

    context 'with parameters' do
      it {
        is_expected.to contain_package('python-ldappool').with(
          :name => platform_params[:python_ldappool_package_name],
        )
      }

      it {
        is_expected.to contain_keystone_config('ldap/url').with_value('ldap://foo')
        is_expected.to contain_keystone_config('ldap/user').with_value('cn=foo,dc=example,dc=com')
        is_expected.to contain_keystone_config('ldap/password').with_value('abcdefg').with_secret(true)
        is_expected.to contain_keystone_config('ldap/suffix').with_value('dc=example,dc=com')
        is_expected.to contain_keystone_config('ldap/query_scope').with_value('sub')
        is_expected.to contain_keystone_config('ldap/page_size').with_value('50')
      }

      it {
        is_expected.to contain_keystone_config('ldap/user_tree_dn').with_value('cn=users,dc=example,dc=com')
        is_expected.to contain_keystone_config('ldap/user_filter').with_value('(memberOf=cn=openstack,cn=groups,cn=accounts,dc=example,dc=com)')
        is_expected.to contain_keystone_config('ldap/user_objectclass').with_value('inetUser')
        is_expected.to contain_keystone_config('ldap/user_id_attribute').with_value('uid')
        is_expected.to contain_keystone_config('ldap/user_name_attribute').with_value('cn')
        is_expected.to contain_keystone_config('ldap/user_description_attribute').with_value('description')
        is_expected.to contain_keystone_config('ldap/user_mail_attribute').with_value('mail')
        is_expected.to contain_keystone_config('ldap/user_enabled_attribute').with_value('UserAccountControl')
        is_expected.to contain_keystone_config('ldap/user_enabled_mask').with_value('2')
        is_expected.to contain_keystone_config('ldap/user_enabled_default').with_value('512')
        is_expected.to contain_keystone_config('ldap/user_enabled_invert').with_value('False')
        is_expected.to contain_keystone_config('ldap/user_attribute_ignore').with_value('')
        is_expected.to contain_keystone_config('ldap/user_default_project_id_attribute').with_value('defaultProject')
        is_expected.to contain_keystone_config('ldap/user_tree_dn').with_value('cn=users,dc=example,dc=com')
        is_expected.to contain_keystone_config('ldap/user_pass_attribute').with_value('krbPassword')
        is_expected.to contain_keystone_config('ldap/user_enabled_emulation').with_value('True')
        is_expected.to contain_keystone_config('ldap/user_enabled_emulation_dn').with_value('cn=openstack-enabled,cn=groups,cn=accounts,dc=example,dc=com')
        is_expected.to contain_keystone_config('ldap/user_additional_attribute_mapping').with_value('description:name, gecos:name')
      }

      it {
        is_expected.to contain_keystone_config('ldap/group_tree_dn').with_value('ou=groups,ou=openstack,dc=example,dc=com')
        is_expected.to contain_keystone_config('ldap/group_filter').with_value('cn=enabled-groups,cn=groups,cn=accounts,dc=example,dc=com')
        is_expected.to contain_keystone_config('ldap/group_objectclass').with_value('organizationalRole')
        is_expected.to contain_keystone_config('ldap/group_id_attribute').with_value('cn')
        is_expected.to contain_keystone_config('ldap/group_member_attribute').with_value('roleOccupant')
        is_expected.to contain_keystone_config('ldap/group_members_are_ids').with_value('True')
        is_expected.to contain_keystone_config('ldap/group_desc_attribute').with_value('description')
        is_expected.to contain_keystone_config('ldap/group_name_attribute').with_value('cn')
        is_expected.to contain_keystone_config('ldap/group_attribute_ignore').with_value('')
        is_expected.to contain_keystone_config('ldap/group_additional_attribute_mapping').with_value('')
      }

      it { is_expected.to contain_keystone_config('ldap/chase_referrals').with_value('False') }

      it {
        is_expected.to contain_keystone_config('ldap/use_tls').with_value('False')
        is_expected.to contain_keystone_config('ldap/tls_cacertdir').with_value('/etc/ssl/certs/')
        is_expected.to contain_keystone_config('ldap/tls_cacertfile').with_value('/etc/ssl/certs/ca-certificates.crt')
        is_expected.to contain_keystone_config('ldap/tls_req_cert').with_value('demand')
      }

      it {
        is_expected.to contain_keystone_config('ldap/use_pool').with_value(true)
        is_expected.to contain_keystone_config('ldap/pool_size').with_value('10')
        is_expected.to contain_keystone_config('ldap/pool_retry_max').with_value(3)
        is_expected.to contain_keystone_config('ldap/pool_retry_delay').with_value(0.1)
        is_expected.to contain_keystone_config('ldap/pool_connection_timeout').with_value(-1)
        is_expected.to contain_keystone_config('ldap/pool_connection_lifetime').with_value(600)
        is_expected.to contain_keystone_config('ldap/use_auth_pool').with_value(true)
        is_expected.to contain_keystone_config('ldap/auth_pool_size').with_value(100)
        is_expected.to contain_keystone_config('ldap/auth_pool_connection_lifetime').with_value(60)
      }

      it { is_expected.to contain_keystone_config('identity/driver').with_value('ldap') }
    end

    context 'with manage_packages set to false' do
      before do
        params.merge!( :manage_packages => false )
      end

      it { is_expected.to_not contain_package('python-ldappool') }
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
        case facts[:osfamily]
        when 'Debian'
          { :python_ldappool_package_name => 'python3-ldappool' }
        when 'RedHat'
          { :python_ldappool_package_name => 'python3-ldappool' }
        end
      end
      it_behaves_like 'keystone::ldap'
    end
  end
end
