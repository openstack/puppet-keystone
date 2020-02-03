require 'spec_helper'

describe 'keystone::db::mysql' do
  let :params do
    {}
  end

  shared_examples 'keystone::db::mysql' do
    context 'with required params' do
      before do
        params.merge!( :password => 'keystone_default_password' )
      end

      it { is_expected.to contain_class('keystone::deps') }

      it { is_expected.to contain_openstacklib__db__mysql('keystone').with(
        :user          => 'keystone',
        :password_hash => '*B552157B14BCEDDCEAA06767A012F31BDAA9CE3D',
        :dbname        => 'keystone',
        :host          => '127.0.0.1',
        :charset       => 'utf8',
        :collate       => 'utf8_general_ci',
      )}
    end

    context 'with overriden params' do
      before do
        params.merge!( :password      => 'keystonepass',
                       :dbname        => 'keystonedb',
                       :user          => 'keystoneuser',
                       :host          => '1.2.3.4',
                       :charset       => 'latin2',
                       :collate       => 'latin2_general_ci',
                       :allowed_hosts => '4.3.2.1' )
      end

      it { is_expected.to contain_class('keystone::deps') }

      it { is_expected.to contain_openstacklib__db__mysql('keystone').with(
        :user          => 'keystoneuser',
        :password_hash => '*706BFA85E15D0C1D8467D0D81D784F6A04CE4ABB',
        :dbname        => 'keystonedb',
        :host          => '1.2.3.4',
        :charset       => 'latin2',
        :collate       => 'latin2_general_ci',
        :allowed_hosts => '4.3.2.1',
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'keystone::db::mysql'
    end
  end
end
