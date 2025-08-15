require 'spec_helper'

describe 'keystone::federation::identity_provider' do
  let :params do
    {
      :user                          => 'keystone',
      :certfile                      => '/etc/keystone/ssl/certs/signing_cert.pem',
      :keyfile                       => '/etc/keystone/ssl/private/signing_key.pem',
      :idp_entity_id                 => 'https://keystone.example.com/v3/OS-FEDERATION/saml2/idp',
      :idp_sso_endpoint              => 'https://keystone.example.com/v3/OS-FEDERATION/saml2/sso',
      :idp_metadata_path             => '/etc/keystone/saml2_idp_metadata.xml'
    }
   end

  let :optional_params do
    {
      :idp_organization_name         => 'ExampleCompany',
      :idp_organization_display_name => 'Example',
      :idp_organization_url          => 'www.example.com',
      :idp_contact_company           => 'someone',
      :idp_contact_name              => 'name',
      :idp_contact_surname           => 'surname',
      :idp_contact_email             => 'name@example.com',
      :idp_contact_telephone         => '+55000000000',
      :idp_contact_type              => 'other'
    }
  end

  shared_examples 'keystone::federation::identity_provider' do
    let :pre_condition do
      "include apache
       class { 'keystone':
         service_name => 'httpd',
       }"
    end

    context 'with required params' do
      it { is_expected.to contain_class('keystone::params') }

      it { is_expected.to contain_package('xmlsec1').with(
        :ensure => 'present',
      )}

      it {
        is_expected.to contain_keystone_config('saml/certfile').with_value(params[:certfile])
        is_expected.to contain_keystone_config('saml/keyfile').with_value(params[:keyfile])
        is_expected.to contain_keystone_config('saml/idp_entity_id').with_value(params[:idp_entity_id])
        is_expected.to contain_keystone_config('saml/idp_sso_endpoint').with_value(params[:idp_sso_endpoint])
        is_expected.to contain_keystone_config('saml/idp_metadata_path').with_value(params[:idp_metadata_path])
      }

      it { is_expected.to contain_exec('saml_idp_metadata').with(
        :command => "keystone-manage saml_idp_metadata > #{params[:idp_metadata_path]}",
        :creates => "#{params[:idp_metadata_path]}",
      )}

      it { is_expected.to contain_file("#{params[:idp_metadata_path]}").with(
        :ensure => 'file',
        :mode   => '0600',
        :owner  => 'keystone',
      )}
    end

    context 'with keystone optional params' do
      before do
        params.merge!(optional_params)
      end

      it {
        is_expected.to contain_keystone_config('saml/certfile').with_value(params[:certfile])
        is_expected.to contain_keystone_config('saml/keyfile').with_value(params[:keyfile])
        is_expected.to contain_keystone_config('saml/idp_entity_id').with_value(params[:idp_entity_id])
        is_expected.to contain_keystone_config('saml/idp_sso_endpoint').with_value(params[:idp_sso_endpoint])
        is_expected.to contain_keystone_config('saml/idp_metadata_path').with_value(params[:idp_metadata_path])
        is_expected.to contain_keystone_config('saml/idp_organization_name').with_value(params[:idp_organization_name])
        is_expected.to contain_keystone_config('saml/idp_organization_display_name').with_value(params[:idp_organization_display_name])
        is_expected.to contain_keystone_config('saml/idp_organization_url').with_value(params[:idp_organization_url])
        is_expected.to contain_keystone_config('saml/idp_contact_company').with_value(params[:idp_contact_company])
        is_expected.to contain_keystone_config('saml/idp_contact_name').with_value(params[:idp_contact_name])
        is_expected.to contain_keystone_config('saml/idp_contact_surname').with_value(params[:idp_contact_surname])
        is_expected.to contain_keystone_config('saml/idp_contact_email').with_value(params[:idp_contact_email])
        is_expected.to contain_keystone_config('saml/idp_contact_telephone').with_value(params[:idp_contact_telephone])
        is_expected.to contain_keystone_config('saml/idp_contact_type').with_value(params[:idp_contact_type])
      }
    end

    context 'with invalid values for idp_contact_type' do
      before do
        params.merge!(:idp_contact_type => 'foobar')
      end

      it { is_expected.to raise_error(Puppet::Error, /Allowed values for idp_contact_type are: technical, support, administrative, billing and other/) }
    end
  end

  shared_examples 'keystone::federation::identity_provider without Apache' do
    let :pre_condition do
      "class { 'keystone':
         service_name => '#{platform_params[:keystone_service]}',
       }"
    end

    context 'with default parameters' do
      it { is_expected.to raise_error(Puppet::Error, /Keystone need to be running under Apache for Federation work./) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let (:platform_params) do
        if facts[:os]['family'] == 'RedHat'
          keystone_service = 'openstack-keystone'
          python_pysaml2_package_name = 'python3-pysaml2'
        else
          keystone_service = 'keystone'
          python_pysaml2_package_name = 'python3-pysaml2'
        end
        {
          :keystone_service            => keystone_service,
          :python_pysaml2_package_name => python_pysaml2_package_name
        }
      end

      it_behaves_like 'keystone::federation::identity_provider'
      it_behaves_like 'keystone::federation::identity_provider without Apache'
    end
  end
end
