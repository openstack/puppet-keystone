require 'spec_helper'

describe 'keystone::federation::openidc' do

  describe 'with invalid params' do
    before do
      params.merge!(:methods => 'external, password, token, oauth1')
    end

    it_raises 'a Puppet::Error', /The external method should be dropped to avoid any interference with openidc/

    before do
      params.merge!(:methods => 'password, token, oauth1')
    end

    it_raises 'a Puppet::Error', /Methods should contain openidc as one of the auth methods./

    before do
      params.merge!(:methods       => 'password, token, oauth1, openidc',
                    :module_plugin => 'keystone.auth.plugins')
    end

    it_raises 'a Puppet:Error', /The plugin for openidc should be keystone.auth.plugins.mapped.Mapped/

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

  on_supported_os({
  }).each do |os,facts|
    let (:facts) do
      facts.merge!(OSDefaults.get_facts({}))
    end

    let(:platform_parameters) do
      case facts[:osfamily]
      when 'Debian'
        {
          :openidc_package_name => 'libapache2-mod-auth-mellon',
        }
      when 'RedHat'
        {
          :openidc_package_name => 'mod_auth_openidc'
        }
      end
    end

    context 'with only required parameters' do
      let :params do
        { :methods => 'password, token, openidc' }
      end

      it 'should have basic params for mellon in Keystone configuration' do
        is_expected.to contain_keystone_config('auth/methods').with_value('password, token, openidc')
        is_expected.to contain_keystone_config('auth/openidc').with_value('keystone.auth.plugins.mapped.Mapped')
      end

      it { is_expected.to contain_concat__fragment('configure_openidc_on_port_5000').with({
        :target => "${keystone::wsgi::apache::priority}-keystone_wsgi_main.conf",
        :order  => params[:template_order],
      })}
    end

    context 'with override default parameters' do
      let :params do
        { :methods => 'password, token, openidc',
          :admin_port => true }
      end

      it 'should have basic params for mellon in Keystone configuration' do
        is_expected.to contain_keystone_config('auth/methods').with_value('password, token, openidc')
        is_expected.to contain_keystone_config('auth/openidc').with_value('keystone.auth.plugins.mapped.Mapped')
      end

      it { is_expected.to contain_concat__fragment('configure_openidc_on_port_5000').with({
        :target => "${keystone::wsgi::apache::priority}-keystone_wsgi_main.conf",
        :order  => params[:template_order],
      })}

      it { is_expected.to contain_concat__fragment('configure_openidc_on_port_35357').with({
        :target => "${keystone::wsgi::apache::priority}-keystone_wsgi_admin.conf",
        :order  => params[:template_order],
      })}
    end

    it { is_expected.to contain_package(platform_parameters[:openidc_package_name]) }

  end

end
