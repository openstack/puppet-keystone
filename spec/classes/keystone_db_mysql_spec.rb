require 'spec_helper'

describe 'keystone::db::mysql' do
  let :params do
    {}
  end

  shared_examples 'keystone::db::mysql' do
    context 'with required params' do
      before do
        params.merge!( :password => 'keystonepass' )
      end

      it { is_expected.to contain_class('keystone::deps') }

      it { is_expected.to contain_openstacklib__db__mysql('keystone').with(
        :user     => 'keystone',
        :password => 'keystonepass',
        :dbname   => 'keystone',
        :host     => '127.0.0.1',
        :charset  => 'utf8',
        :collate  => 'utf8_general_ci',
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
        :password      => 'keystonepass',
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
