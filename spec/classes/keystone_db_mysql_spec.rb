require 'spec_helper'

describe 'keystone::db::mysql' do

  let :pre_condition do
    [
      'include mysql::server',
      'include keystone::db::sync'
    ]
  end

  let :facts do
    @default_facts.merge({ :osfamily => 'Debian' })
  end

  let :params do
    {
      :password      => 'keystone_default_password',
    }
  end

  describe 'with only required params' do
    it { is_expected.to contain_openstacklib__db__mysql('keystone').with(
      :user          => 'keystone',
      :password_hash => '*B552157B14BCEDDCEAA06767A012F31BDAA9CE3D',
      :dbname        => 'keystone',
      :host          => '127.0.0.1',
      :charset       => 'utf8',
      :collate       => 'utf8_general_ci',
    )}
  end

  describe "overriding allowed_hosts param to array" do
    let :params do
      {
        :password       => 'keystonepass',
        :allowed_hosts  => ['127.0.0.1','%']
      }
    end

    it { is_expected.to contain_openstacklib__db__mysql('keystone').with(
      :user          => 'keystone',
      :password_hash => '*706BFA85E15D0C1D8467D0D81D784F6A04CE4ABB',
      :dbname        => 'keystone',
      :host          => '127.0.0.1',
      :charset       => 'utf8',
      :collate       => 'utf8_general_ci',
      :allowed_hosts => ['127.0.0.1','%'],
    )}

  end
  describe "overriding allowed_hosts param to string" do
    let :params do
      {
        :password       => 'keystonepass2',
        :allowed_hosts  => '192.168.1.1'
      }
    end

    it { is_expected.to contain_openstacklib__db__mysql('keystone').with(
      :user          => 'keystone',
      :password_hash => '*47651CDAAB340A79CC838378072877FFFBF0B239',
      :dbname        => 'keystone',
      :host          => '127.0.0.1',
      :charset       => 'utf8',
      :collate       => 'utf8_general_ci',
      :allowed_hosts => '192.168.1.1',
    )}

  end

  describe "overriding allowed_hosts param equals to host param " do
    let :params do
      {
        :password       => 'keystonepass2',
        :allowed_hosts  => '127.0.0.1'
      }
    end

    it { is_expected.to contain_openstacklib__db__mysql('keystone').with(
      :user          => 'keystone',
      :password_hash => '*47651CDAAB340A79CC838378072877FFFBF0B239',
      :dbname        => 'keystone',
      :host          => '127.0.0.1',
      :charset       => 'utf8',
      :collate       => 'utf8_general_ci',
      :allowed_hosts => '127.0.0.1',
    )}

  end

end
