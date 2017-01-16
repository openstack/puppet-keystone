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
      params.merge!({:methods       => 'password, token, oauth1, saml2',
                     :module_plugin => 'keystone.auth.plugins'})
      it_raises 'a Puppet::Error', /The plugin for saml and mellon should be keystone.auth.plugins.mapped.Mapped/
    end

    before do
      params.merge!({:admin_port => false,
                     :main_port  => false})
      it_raises 'a Puppet::Error', /No VirtualHost port to configure, please choose at least one./
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
      it 'should have basic params for mellon in Keystone configuration' do
        is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2')
        is_expected.to contain_keystone_config('auth/saml2').with_value('keystone.auth.plugins.mapped.Mapped')
      end

      it { is_expected.to contain_concat__fragment('configure_mellon_on_port_5000').with({
        # This need to change if priority is changed in keystone::wsgi::apache
        :target => "10-keystone_wsgi_main.conf",
        :order  => params[:template_order],
      })}
    end

    context 'with override default parameters' do
      before do
        params.merge!({
          :admin_port => true })
      end

      it 'should have basic params for mellon in Keystone configuration' do
        is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2')
        is_expected.to contain_keystone_config('auth/saml2').with_value('keystone.auth.plugins.mapped.Mapped')
      end

      it { is_expected.to contain_concat__fragment('configure_mellon_on_port_5000').with({
        # This need to change if priority is changed in keystone::wsgi::apache
        :target => "10-keystone_wsgi_main.conf",
        :order  => params[:template_order],
      })}

      it { is_expected.to contain_concat__fragment('configure_mellon_on_port_35357').with({
        # This need to change if priority is changed in keystone::wsgi::apache
        :target => "10-keystone_wsgi_admin.conf",
        :order  => params[:template_order],
      })}
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      it_behaves_like 'Federation Mellon'

      case [:osfamily]
      when 'Debian'
        it { is_expected.to contain_package('libapache2-mod-auth-mellon') }
      when 'RedHat'
        it { is_expected.to contain_package('mod_auth_mellon') }
      end
    end
  end
end

