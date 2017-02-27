require 'spec_helper'

describe 'keystone::federation::shibboleth' do
  let(:pre_condition) do
    <<-EOS
    include apache

    class { 'keystone::wsgi::apache': }
    EOS
  end

  let :default_params do
    {
      :methods => 'password, token, saml2',
      :template_order => 331,
    }
  end

  shared_examples 'keystone::federation::shibboleth with invalid parameters' do
    context 'external method' do
      let (:params) { default_params.merge(:methods => ['external']) }
      it_raises 'a Puppet::Error', /The external method/
    end

    context 'method missing saml2' do
      let (:params) { default_params.merge(:methods => ['password', 'token', 'oauth1']) }
      it_raises 'a Puppet::Error', /Methods should contain saml2 as one of the auth methods./
    end

    context 'wrong plugin' do
      let (:params) { default_params.merge(:methods => ['password', 'token', 'oauth1', 'saml2'],
                    :module_plugin => 'keystone.auth.plugins') }
      it_raises 'a Puppet::Error', /The plugin for saml and shibboleth should be keystone.auth.plugins.mapped.Mapped/
    end

    context 'no ports' do
      let (:params) { default_params.merge(:admin_port => false,
                    :main_port  => false) }
      it_raises 'a Puppet::Error', /No VirtualHost port to configure, please choose at least one./
    end

    context 'template port too low' do
      let(:params) { default_params.merge(:template_order => 330) }
      it_raises 'a Puppet::Error', /The template order should be greater than 330 and less than 999./
    end

    context 'template port too high' do
      let(:params) { default_params.merge(:template_order => 999) }
      it_raises 'a Puppet::Error', /The template order should be greater than 330 and less than 999./
    end
  end

  shared_examples 'keystone::federation::shibboleth' do
    let(:pre_condition) do
      <<-EOS
      include apache

      class { 'keystone::wsgi::apache': }
      EOS
    end


    context 'with only required parameters' do
      let (:params) { default_params }
      it 'should have basic params for shibboleth in Keystone configuration' do
        is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2')
        is_expected.to contain_keystone_config('auth/saml2').with_value('keystone.auth.plugins.mapped.Mapped')
      end
    end

    context 'with override default parameters' do
      let (:params) { default_params.merge({
        :methods => ['password', 'token', 'saml2', 'somethingelse'],
      }) }

      it 'should have basic params for shibboleth in Keystone configuration' do
        is_expected.to contain_keystone_config('auth/methods').with_value('password,token,saml2,somethingelse')
      end
    end
  end

  shared_examples 'keystone::federation::shibboleth on RedHat' do
    context 'with shibboleth package' do
      let(:pre_condition) do
        <<-EOS
        include apache

        package { 'shibboleth': ensure => present }
        class { 'keystone::wsgi::apache': }
        EOS
      end

      context 'with defaults' do

        let (:params) { default_params }

        it { is_expected.to contain_apache__mod('shib2') }
        it { is_expected.to contain_concat__fragment('configure_shibboleth_on_port_5000').with({
          :target => "10-keystone_wsgi_main.conf",
          :order  => params[:template_order],
        })}
      end
      context 'with overrides' do
        let (:params) { default_params.merge({
          :admin_port => true,
          :template_order => 332
        }) }

        it { is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2') }
        it {is_expected.to contain_keystone_config('auth/saml2').with_value('keystone.auth.plugins.mapped.Mapped') }
        it {
          is_expected.to contain_concat__fragment('configure_shibboleth_on_port_35357').with({
            :target => "10-keystone_wsgi_admin.conf",
            :order  => params[:template_order],
          })
        }
      end
    end


    context 'with shibboleth repo' do
      let(:pre_condition) do
        <<-EOS
        include apache

        yumrepo { 'shibboleth': ensure => present }
        class { 'keystone::wsgi::apache': }
        EOS
      end

      context 'with defaults' do
        let (:params) { default_params }

        it { is_expected.to contain_apache__mod('shib2') }
        it { is_expected.to contain_concat__fragment('configure_shibboleth_on_port_5000').with({
          :target => "10-keystone_wsgi_main.conf",
          :order  => params[:template_order],
        })}
      end
      context 'with overrides' do
        let (:params) { default_params.merge({
          :admin_port => true,
          :template_order => 332
        }) }

        it { is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2') }
        it { is_expected.to contain_keystone_config('auth/saml2').with_value('keystone.auth.plugins.mapped.Mapped') }
        it {
          is_expected.to contain_concat__fragment('configure_shibboleth_on_port_35357').with({
            :target => "10-keystone_wsgi_admin.conf",
            :order  => params[:template_order],
          })
        }
      end

    end

    context 'without repo or package' do
      context 'with defaults' do
        let (:params) { default_params }
        it { is_expected.to_not contain_apache__mod('shib2') }
        it { is_expected.to_not contain_concat__fragment('configure_shibboleth_on_port_5000') }
      end

      context 'with overrides' do
        let (:params) { default_params.merge({
          :admin_port => true,
          :template_order => 332
        }) }

        it { is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2') }
        it { is_expected.to contain_keystone_config('auth/saml2').with_value('keystone.auth.plugins.mapped.Mapped') }
        it { is_expected.to_not contain_concat__fragment('configure_shibboleth_on_port_35357') }
      end
    end
  end

  shared_examples 'keystone::federation::shibboleth on Debian' do
    context 'with defaults' do
      let (:params) { default_params }

      it { is_expected.to contain_apache__mod('shib2') }
      it { is_expected.to contain_concat__fragment('configure_shibboleth_on_port_5000').with({
         :target => "10-keystone_wsgi_main.conf",
         :order  => params[:template_order],
       })}

    end
  end

  on_supported_os({
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      it_behaves_like 'keystone::federation::shibboleth'
      it_behaves_like 'keystone::federation::shibboleth with invalid parameters'
      it_behaves_like "keystone::federation::shibboleth on #{facts[:osfamily]}"
    end
  end
end
