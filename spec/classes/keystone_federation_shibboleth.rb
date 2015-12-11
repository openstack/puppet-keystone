require 'spec_helper'

describe 'keystone::federation::shibboleth' do

  describe 'with invalid params' do
    before do
      params.merge!(:methods => 'external, password, token, oauth1')
    end

    it_raises 'a Puppet::Error', /The external method should be dropped to avoid any interference with some Apache + Shibboleth SP setups, where a REMOTE_USER env variable is always set, even as an empty value./

    before do
      params.merge!(:methods => 'password, token, oauth1')
    end

    it_raises 'a Puppet::Error', /Methods should contain saml2 as one of the auth methods./

    before do
      params.merge!(:methods       => 'password, token, oauth1, saml2',
                    :module_plugin => 'keystone.auth.plugins')
    end

    it_raises 'a Puppet:Error', /The plugin for saml and shibboleth should be keystone.auth.plugins.mapped.Mapped/

    before do
      params.merge!(:admin_port => false,
                    :main_port  => false)
    end

    it_raises 'a Puppet:Error', /No VirtualHost port to configure, please choose at least one./

    befode do
      params.merge!(:template_port => 330)
    end

    it_raises 'a Puppet:Error', /The template order should be greater than 330 and less than 999./

    befode do
      params.merge!(:template_port => 999)
    end

    it_raises 'a Puppet:Error', /The template order should be greater than 330 and less than 999./
  end

  context 'on a RedHat osfamily' do
    let :facts do
      { :osfamily                 => 'RedHat',
        :operatingsystemrelease   => '7.0',
        :concat_basedir           => '/var/lib/puppet/concat' }
    end

    context 'with only required parameters' do
      let :params do
        { :methods => 'password, token, saml2' }
      end

      it 'should have basic params for shibboleth in Keystone configuration' do
        is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2')
        is_expected.to contain_keystone_config('auth/saml2').with_value('keystone.auth.plugins.mapped.Mapped')
      end
    end

  end

  context 'on a Debian osfamily' do
    let :facts do
      { :osfamily                 => 'Debian',
        :operatingsystemrelease   => '7.8',
        :concat_basedir           => '/var/lib/puppet/concat' }
    end

    context 'with only required parameters' do
      let :params do
        { :methods => 'password, token, saml2' }
      end

      it 'should have basic params for shibboleth in Keystone configuration' do
        is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2')
        is_expected.to contain_keystone_config('auth/saml2').with_value('keystone.auth.plugins.mapped.Mapped')
      end

      it { is_expected.to contain_concat__fragment('configure_shibboleth_on_port_5000').with({
        :target => "${keystone::wsgi::apache::priority}-keystone_wsgi_main.conf",
        :order  => params[:template_order],
      })}
    end

    context 'with override default parameters' do
      let :params do
        { :methods => 'password, token, saml2',
          :admin_port => true }
      end

      it 'should have basic params for shibboleth in Keystone configuration' do
        is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2')
        is_expected.to contain_keystone_config('auth/saml2').with_value('keystone.auth.plugins.mapped.Mapped')
      end

      it { is_expected.to contain_class('apache::mod::shib') }

      it { is_expected.to contain_concat__fragment('configure_shibboleth_on_port_5000').with({
        :target => "${keystone::wsgi::apache::priority}-keystone_wsgi_main.conf",
        :order  => params[:template_order],
      })}

      it { is_expected.to contain_concat__fragment('configure_shibboleth_on_port_35357').with({
        :target => "${keystone::wsgi::apache::priority}-keystone_wsgi_admin.conf",
        :order  => params[:template_order],
      })}
    end

  end

end
