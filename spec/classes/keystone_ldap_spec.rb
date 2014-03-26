require 'spec_helper'

describe 'keystone::ldap' do
  describe 'with basic params' do
    let :params do 
      {
        :url => 'ldap://foo',
        :user => 'cn=foo,dc=example,dc=com',
        :password => 'abcdefg',
        :user_tree_dn => 'cn=users,dc=example,dc=com',
        :user_allow_create => 'False',
        :user_allow_update => 'False',
        :user_allow_delete => 'False',
      }
    end
    it { should contain_package('python-ldap') }
    it 'should have basic params' do
      should contain_keystone_config('ldap/url').with_value('ldap://foo')
      should contain_keystone_config('ldap/user').with_value('cn=foo,dc=example,dc=com')
      should contain_keystone_config('ldap/password').with_value('abcdefg').with_secret(true)
      should contain_keystone_config('ldap/user_tree_dn').with_value('cn=users,dc=example,dc=com')
      should contain_keystone_config('ldap/user_allow_create').with_value('False')
      should contain_keystone_config('ldap/user_allow_update').with_value('False')
      should contain_keystone_config('ldap/user_allow_delete').with_value('False')
    end
  end
end
