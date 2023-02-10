require 'spec_helper'

describe 'keystone::federation::mellon' do

  let(:pre_condition) do
    <<-EOS
    include apache

    class { 'keystone::wsgi::apache': }
    EOS
  end

  let :params do
    { :methods => 'password, token, saml2',
      :idp_name => 'myidp',
      :protocol_name => 'saml2',
      :template_order => 331,
    }
  end

  context 'with invalid params' do
    before do
      params.merge!({:methods => 'external, password, token, oauth1'})
      it_raises 'a Puppet::Error', /The external method should be dropped to avoid any interference with some Apache + Mellon SP setups, where a REMOTE_USER env variable is always set, even as an empty value./
    end

    before do
      params.merge!({:methods => 'password, token, oauth1'})
      it_raises 'a Puppet::Error', /Methods should contain saml2 as one of the auth methods./
    end

    before do
      params.merge!({:template_port => 330})
      it_raises 'a Puppet::Error', /The template order should be greater than 330 and less than 999./
    end

    before do
      params.merge!({:template_port => 999})
      it_raises 'a Puppet::Error', /The template order should be greater than 330 and less than 999./
    end
  end

  shared_examples 'Federation Mellon' do
    context 'with only required parameters' do
      it 'should enable auth_mellon module' do
        is_expected.to contain_class('apache::mod::auth_mellon')
      end

      it 'should have basic params for mellon in Keystone configuration' do
        is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2')
        is_expected.to contain_keystone_config('auth/saml2').with_ensure('absent')
      end

      it { is_expected.to contain_concat__fragment('configure_mellon_keystone').with({
        # This need to change if priority is changed in keystone::wsgi::apache
        :target => "10-keystone_wsgi.conf",
        :order  => params[:template_order],
      })}
    end

    context 'with websso enabled' do
      before do
        params.merge!({
          :enable_websso => true,
        })
      end

      it 'should have basic params for mellon in Keystone configuration' do
        is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2')
        is_expected.to contain_keystone_config('auth/saml2').with_ensure('absent')
      end

      it 'should have parameters for websso in Keystone configuration' do
        is_expected.to contain_keystone_config('mapped/remote_id_attribute').with_value('MELLON_IDP')
      end

      it { is_expected.to contain_concat__fragment('configure_mellon_keystone').with({
        :target => "10-keystone_wsgi.conf",
        :order  => params[:template_order],
      })}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      it_behaves_like 'Federation Mellon'
    end
  end
end

