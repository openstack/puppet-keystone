require 'spec_helper'

describe 'keystone::federation::shibboleth' do

  let(:pre_condition) do
    <<-EOS
    include apache

    class { 'keystone::wsgi::apache': }
    EOS
  end

  let :params do
    { :methods => 'password, token, saml2',
      :template_order => 331
     }
  end


  describe 'with invalid params' do
    before do
      params.merge!(:methods => 'external, password, token, oauth1')
      it_raises 'a Puppet::Error', /The external method should be dropped to avoid any interference with some Apache + Shibboleth SP setups, where a REMOTE_USER env variable is always set, even as an empty value./
    end

    before do
      params.merge!(:methods => 'password, token, oauth1')
      it_raises 'a Puppet::Error', /Methods should contain saml2 as one of the auth methods./
    end

    before do
      params.merge!(:methods       => 'password, token, oauth1, saml2',
                    :module_plugin => 'keystone.auth.plugins')
      it_raises 'a Puppet:Error', /The plugin for saml and shibboleth should be keystone.auth.plugins.mapped.Mapped/
    end

    before do
      params.merge!(:admin_port => false,
                    :main_port  => false)
      it_raises 'a Puppet:Error', /No VirtualHost port to configure, please choose at least one./
    end

    before do
      params.merge!(:template_port => 330)
      it_raises 'a Puppet:Error', /The template order should be greater than 330 and less than 999./
    end

    before do
      params.merge!(:template_port => 999)
      it_raises 'a Puppet:Error', /The template order should be greater than 330 and less than 999./
    end
  end

  shared_examples 'Federation Shibboleth' do
    context 'with only required parameters' do
      it 'should have basic params for shibboleth in Keystone configuration' do
        is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2')
        is_expected.to contain_keystone_config('auth/saml2').with_value('keystone.auth.plugins.mapped.Mapped')
      end

      it { is_expected.to contain_concat__fragment('configure_shibboleth_on_port_5000').with({
        :target => "10-keystone_wsgi_main.conf",
        :order  => params[:template_order],
      })}
    end

    context 'with override default parameters' do
       before do
         params.merge!({
          :admin_port => true })
      end

      it 'should have basic params for shibboleth in Keystone configuration' do
        is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2')
        is_expected.to contain_keystone_config('auth/saml2').with_value('keystone.auth.plugins.mapped.Mapped')
      end

      it { is_expected.to contain_class('apache::mod::shib') }

      it { is_expected.to contain_concat__fragment('configure_shibboleth_on_port_5000').with({
        :target => "10-keystone_wsgi_main.conf",
        :order  => params[:template_order],
      })}

      it { is_expected.to contain_concat__fragment('configure_shibboleth_on_port_35357').with({
        :target => "10-keystone_wsgi_admin.conf",
        :order  => params[:template_order],
      })}
    end
  end

  on_supported_os({
  }).each do |os,facts|
    let (:facts) do
      facts.merge!(OSDefaults.get_facts({}))
    end

    it_behaves_like 'Federation Shibboleth'
  end
end
