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
        is_expected.to contain_keystone_config('auth/saml2').with_ensure('absent')
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
        it { is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2') }
        it { is_expected.to contain_keystone_config('auth/saml2').with_ensure('absent') }
        it { is_expected.to contain_concat__fragment('configure_shibboleth_keystone').with({
          :target => "10-keystone_wsgi.conf",
          :order  => params[:template_order],
        })}
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
        it { is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2') }
        it { is_expected.to contain_keystone_config('auth/saml2').with_ensure('absent') }
        it { is_expected.to contain_concat__fragment('configure_shibboleth_keystone').with({
          :target => "10-keystone_wsgi.conf",
          :order  => params[:template_order],
        })}
      end
    end

    context 'without repo or package' do
      context 'with defaults' do
        let (:params) { default_params }
        it { is_expected.to_not contain_apache__mod('shib2') }
        it { is_expected.to contain_keystone_config('auth/methods').with_value('password, token, saml2') }
        it { is_expected.to contain_keystone_config('auth/saml2').with_ensure('absent') }
        it { is_expected.to_not contain_concat__fragment('configure_shibboleth_keystone') }
      end
    end
  end

  shared_examples 'keystone::federation::shibboleth on Debian' do
    context 'with defaults' do
      let (:params) { default_params }

      it { is_expected.to contain_apache__mod('shib2') }
      it { is_expected.to contain_concat__fragment('configure_shibboleth_keystone').with({
         :target => "10-keystone_wsgi.conf",
         :order  => params[:template_order],
       })}

    end
  end

  on_supported_os({
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_behaves_like 'keystone::federation::shibboleth'
      it_behaves_like 'keystone::federation::shibboleth with invalid parameters'
      it_behaves_like "keystone::federation::shibboleth on #{facts[:os]['family']}"
    end
  end
end
