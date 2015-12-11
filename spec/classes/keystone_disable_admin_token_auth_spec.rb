require 'spec_helper'

describe 'keystone::disable_admin_token_auth' do
  let :facts do
    @default_facts.merge(:osfamily => 'Debian')
  end

  let :pre_condition do
    'class { "keystone": admin_token => "secret", }'
  end

  it { is_expected.to contain_ini_subsetting('public_api/admin_token_auth') }
  it { is_expected.to contain_ini_subsetting('admin_api/admin_token_auth') }
  it { is_expected.to contain_ini_subsetting('api_v3/admin_token_auth') }
end
