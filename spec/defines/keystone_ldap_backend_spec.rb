require 'spec_helper'

describe 'keystone::ldap_backend' do
  describe 'Using Default domain' do
    let(:title) { 'Default' }
    let(:pre_condition) do
      <<-EOM
      keystone_config {'identity/domain_specific_drivers_enabled': value => true}
      keystone_config {'identity/domain_config_dir': value => '/etc/keystone/domains'}
      file {'/etc/keystone/keystone.conf': ensure => present }
      EOM
    end
    describe 'with basic params' do
      let :params do
        {
          :url => 'ldap://foo',
          :user => 'cn=foo,dc=example,dc=com',
          :password => 'abcdefg',
          :suffix => 'dc=example,dc=com',
          :query_scope => 'sub',
          :page_size => '50',
          :user_tree_dn => 'cn=users,dc=example,dc=com',
          :user_filter => '(memberOf=cn=openstack,cn=groups,cn=accounts,dc=example,dc=com)',
          :user_objectclass => 'inetUser',
          :user_id_attribute => 'uid',
          :user_name_attribute => 'cn',
          :user_mail_attribute => 'mail',
          :user_enabled_attribute => 'UserAccountControl',
          :user_enabled_mask => '2',
          :user_enabled_default => '512',
          :user_enabled_invert => 'False',
          :user_attribute_ignore => '',
          :user_default_project_id_attribute => 'defaultProject',
          :user_allow_create => 'False',
          :user_allow_update => 'False',
          :user_allow_delete => 'False',
          :user_pass_attribute => 'krbPassword',
          :user_enabled_emulation => 'True',
          :user_enabled_emulation_dn => 'cn=openstack-enabled,cn=groups,cn=accounts,dc=example,dc=com',
          :user_additional_attribute_mapping => 'description:name, gecos:name',
          :project_tree_dn => 'ou=projects,ou=openstack,dc=example,dc=com',
          :project_filter => '',
          :project_objectclass => 'organizationalUnit',
          :project_id_attribute => 'ou',
          :project_member_attribute => 'member',
          :project_desc_attribute => 'description',
          :project_name_attribute => 'ou',
          :project_enabled_attribute => 'enabled',
          :project_domain_id_attribute => 'businessCategory',
          :project_attribute_ignore => '',
          :project_allow_create => 'True',
          :project_allow_update => 'True',
          :project_allow_delete => 'True',
          :project_enabled_emulation => 'False',
          :project_enabled_emulation_dn => 'True',
          :project_additional_attribute_mapping => 'cn=enabled,ou=openstack,dc=example,dc=com',
          :role_tree_dn => 'ou=roles,ou=openstack,dc=example,dc=com',
          :role_filter => '',
          :role_objectclass => 'organizationalRole',
          :role_id_attribute => 'cn',
          :role_name_attribute => 'ou',
          :role_member_attribute => 'roleOccupant',
          :role_attribute_ignore => 'description',
          :role_allow_create => 'True',
          :role_allow_update => 'True',
          :role_allow_delete => 'True',
          :role_additional_attribute_mapping => '',
          :group_tree_dn => 'ou=groups,ou=openstack,dc=example,dc=com',
          :group_filter => 'cn=enabled-groups,cn=groups,cn=accounts,dc=example,dc=com',
          :group_objectclass => 'organizationalRole',
          :group_id_attribute => 'cn',
          :group_name_attribute => 'cn',
          :group_member_attribute => 'roleOccupant',
          :group_desc_attribute => 'description',
          :group_attribute_ignore => '',
          :group_allow_create => 'False',
          :group_allow_update => 'False',
          :group_allow_delete => 'False',
          :group_additional_attribute_mapping => '',
          :use_tls => 'False',
          :tls_cacertdir => '/etc/ssl/certs/',
          :tls_cacertfile => '/etc/ssl/certs/ca-certificates.crt',
          :tls_req_cert => 'demand',
          :identity_driver => 'ldap',
          :use_pool => 'True',
          :pool_size => 20,
          :pool_retry_max => 2,
          :pool_retry_delay => 0.2,
          :pool_connection_timeout => 222,
          :pool_connection_lifetime => 222,
          :use_auth_pool => 'True',
          :auth_pool_size => 20,
          :auth_pool_connection_lifetime => 200,
        }
      end
      it { is_expected.to contain_package('python-ldap') }
      it { is_expected.to contain_package('python-ldappool') }
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
        is_expected.to contain_keystone_domain_config('Default::ldap/user_mail_attribute').with_value('mail')
        is_expected.to contain_keystone_domain_config('Default::ldap/user_enabled_attribute').with_value('UserAccountControl')
        is_expected.to contain_keystone_domain_config('Default::ldap/user_enabled_mask').with_value('2')
        is_expected.to contain_keystone_domain_config('Default::ldap/user_enabled_default').with_value('512')
        is_expected.to contain_keystone_domain_config('Default::ldap/user_enabled_invert').with_value('False')
        is_expected.to contain_keystone_domain_config('Default::ldap/user_attribute_ignore').with_value('')
        is_expected.to contain_keystone_domain_config('Default::ldap/user_default_project_id_attribute').with_value('defaultProject')
        is_expected.to contain_keystone_domain_config('Default::ldap/user_tree_dn').with_value('cn=users,dc=example,dc=com')
        is_expected.to contain_keystone_domain_config('Default::ldap/user_allow_create').with_value('False')
        is_expected.to contain_keystone_domain_config('Default::ldap/user_allow_update').with_value('False')
        is_expected.to contain_keystone_domain_config('Default::ldap/user_allow_delete').with_value('False')
        is_expected.to contain_keystone_domain_config('Default::ldap/user_pass_attribute').with_value('krbPassword')
        is_expected.to contain_keystone_domain_config('Default::ldap/user_enabled_emulation').with_value('True')
        is_expected.to contain_keystone_domain_config('Default::ldap/user_enabled_emulation_dn').with_value('cn=openstack-enabled,cn=groups,cn=accounts,dc=example,dc=com')
        is_expected.to contain_keystone_domain_config('Default::ldap/user_additional_attribute_mapping').with_value('description:name, gecos:name')

        # projects
        is_expected.to contain_keystone_domain_config('Default::ldap/project_tree_dn').with_value('ou=projects,ou=openstack,dc=example,dc=com')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_filter').with_value('')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_objectclass').with_value('organizationalUnit')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_id_attribute').with_value('ou')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_member_attribute').with_value('member')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_desc_attribute').with_value('description')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_name_attribute').with_value('ou')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_enabled_attribute').with_value('enabled')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_domain_id_attribute').with_value('businessCategory')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_attribute_ignore').with_value('')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_allow_create').with_value('True')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_allow_update').with_value('True')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_allow_delete').with_value('True')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_enabled_emulation').with_value('False')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_enabled_emulation_dn').with_value('True')
        is_expected.to contain_keystone_domain_config('Default::ldap/project_additional_attribute_mapping').with_value('cn=enabled,ou=openstack,dc=example,dc=com')

        # roles
        is_expected.to contain_keystone_domain_config('Default::ldap/role_tree_dn').with_value('ou=roles,ou=openstack,dc=example,dc=com')
        is_expected.to contain_keystone_domain_config('Default::ldap/role_filter').with_value('')
        is_expected.to contain_keystone_domain_config('Default::ldap/role_objectclass').with_value('organizationalRole')
        is_expected.to contain_keystone_domain_config('Default::ldap/role_id_attribute').with_value('cn')
        is_expected.to contain_keystone_domain_config('Default::ldap/role_name_attribute').with_value('ou')
        is_expected.to contain_keystone_domain_config('Default::ldap/role_member_attribute').with_value('roleOccupant')
        is_expected.to contain_keystone_domain_config('Default::ldap/role_attribute_ignore').with_value('description')
        is_expected.to contain_keystone_domain_config('Default::ldap/role_allow_create').with_value('True')
        is_expected.to contain_keystone_domain_config('Default::ldap/role_allow_update').with_value('True')
        is_expected.to contain_keystone_domain_config('Default::ldap/role_allow_delete').with_value('True')
        is_expected.to contain_keystone_domain_config('Default::ldap/role_additional_attribute_mapping').with_value('')

        # groups
        is_expected.to contain_keystone_domain_config('Default::ldap/group_tree_dn').with_value('ou=groups,ou=openstack,dc=example,dc=com')
        is_expected.to contain_keystone_domain_config('Default::ldap/group_filter').with_value('cn=enabled-groups,cn=groups,cn=accounts,dc=example,dc=com')
        is_expected.to contain_keystone_domain_config('Default::ldap/group_objectclass').with_value('organizationalRole')
        is_expected.to contain_keystone_domain_config('Default::ldap/group_id_attribute').with_value('cn')
        is_expected.to contain_keystone_domain_config('Default::ldap/group_member_attribute').with_value('roleOccupant')
        is_expected.to contain_keystone_domain_config('Default::ldap/group_desc_attribute').with_value('description')
        is_expected.to contain_keystone_domain_config('Default::ldap/group_name_attribute').with_value('cn')
        is_expected.to contain_keystone_domain_config('Default::ldap/group_attribute_ignore').with_value('')
        is_expected.to contain_keystone_domain_config('Default::ldap/group_allow_create').with_value('False')
        is_expected.to contain_keystone_domain_config('Default::ldap/group_allow_update').with_value('False')
        is_expected.to contain_keystone_domain_config('Default::ldap/group_allow_delete').with_value('False')
        is_expected.to contain_keystone_domain_config('Default::ldap/group_additional_attribute_mapping').with_value('')

        # tls
        is_expected.to contain_keystone_domain_config('Default::ldap/use_tls').with_value('False')
        is_expected.to contain_keystone_domain_config('Default::ldap/tls_cacertdir').with_value('/etc/ssl/certs/')
        is_expected.to contain_keystone_domain_config('Default::ldap/tls_cacertfile').with_value('/etc/ssl/certs/ca-certificates.crt')
        is_expected.to contain_keystone_domain_config('Default::ldap/tls_req_cert').with_value('demand')

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
    end
  end

  describe 'Using non Default domain' do
    let(:title) { 'foobar' }
    let :params do
      {
        :url => 'ldap://foo',
        :user => 'cn=foo,dc=example,dc=com'
      }
    end
    let(:pre_condition) do
      <<-EOM
      keystone_config {'identity/domain_specific_drivers_enabled': value => true}
      keystone_config {'identity/domain_config_dir': value => '/etc/keystone/domains'}
      file {'/etc/keystone/keystone.conf': ensure => present }
      EOM
    end
    it 'should use the domain from the title' do
      is_expected.to contain_keystone_domain_config('foobar::ldap/url').with_value('ldap://foo')
      is_expected.to contain_keystone_domain_config('foobar::ldap/user').with_value('cn=foo,dc=example,dc=com')
    end
  end

  describe 'checks' do
    let(:title) { 'domain' }
    context 'Missing identity/domain_specific_drivers_enabled' do
      let(:pre_condition) do
      <<-EOM
      keystone_config {'identity/domain_config_dir': value => '/etc/keystone/domains'}
      file {'/etc/keystone/keystone.conf': ensure => present }
      EOM
      end
      it_raises 'a Puppet::Error', /You should add/
    end

    context 'Missing identity/domain_config_dir' do
      let(:pre_condition) do
      <<-EOM
      keystone_config {'identity/domain_specific_drivers_enabled': value => true}
      file {'/etc/keystone/keystone.conf': ensure => present }
      EOM
      end
      it_raises 'a Puppet::Error', /You should add/
    end

  end
end
