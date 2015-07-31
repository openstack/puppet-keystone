require 'spec_helper'

describe 'keystone::federation::identity_provider' do

  let :pre_condition do
        "class { 'keystone':
          admin_tokend => 'dummy',
          service_name => 'httpd',
          enable_ssl=> true }"
  end

  let :params do
    { :user                          => 'keystone',
      :certfile                      => '/etc/keystone/ssl/certs/signing_cert.pem',
      :keyfile                       => '/etc/keystone/ssl/private/signing_key.pem',
      :idp_entity_id                 => 'https://keystone.example.com/v3/OS-FEDERATION/saml2/idp',
      :idp_sso_endpoint              => 'https://keystone.example.com/v3/OS-FEDERATION/saml2/sso',
      :idp_metadata_path             => '/etc/keystone/saml2_idp_metadata.xml' }
   end

  let :optional_params do
    { :idp_organization_name         => 'ExampleCompany',
      :idp_organization_display_name => 'Example',
      :idp_organization_url          => 'www.example.com',
      :idp_contact_company           => 'someone',
      :idp_contact_name              => 'name',
      :idp_contact_surname           => 'surname',
      :idp_contact_email             => 'name@example.com',
      :idp_contact_telephone         => '+55000000000',
      :idp_contact_type              => 'other' }
  end

  shared_examples_for 'keystone federation identity provider' do

    it { is_expected.to contain_class('keystone::params') }

    context 'keystone not running under apache' do
      let :pre_condition do
        "class { 'keystone':
          admin_tokend => 'dummy',
          service_name => 'keystone',
          enable_ssl=> true }"
      end

      it_raises 'a Puppet::Error', /Keystone need to be running under Apache for Federation work./
    end

    it 'should have' do
      is_expected.to contain_package('xmlsec1').with(
                 :ensure => 'present',
             )
      is_expected.to contain_package('python-pysaml2').with(
                 :ensure => 'present',
             )
    end

    it 'should configure keystone.conf' do
       is_expected.to contain_keystone_config('saml/certfile').with_value(params[:certfile])
       is_expected.to contain_keystone_config('saml/keyfile').with_value(params[:keyfile])
       is_expected.to contain_keystone_config('saml/idp_entity_id').with_value(params[:idp_entity_id])
       is_expected.to contain_keystone_config('saml/idp_sso_endpoint').with_value(params[:idp_sso_endpoint])
       is_expected.to contain_keystone_config('saml/idp_metadata_path').with_value(params[:idp_metadata_path])
    end

   it { is_expected.to contain_exec('saml_idp_metadata').with(
       :command => "keystone-manage saml_idp_metadata > #{params[:idp_metadata_path]}",
       :creates => "#{params[:idp_metadata_path]}",
    ) }

   it 'creates saml idp metadata file' do
      is_expected.to contain_file("#{params[:idp_metadata_path]}").with(
        :ensure  => 'present',
        :mode    => '0600',
        :owner   => 'keystone',
      )
   end

   context 'configure Keystone with optional params' do
     before :each do
       params.merge!(optional_params)
     end

     it 'should configure keystone.conf' do
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
     end
   end

   context 'with invalid values for idp_contact_type' do
     before do
       params.merge!(:idp_contact_type => 'foobar')
     end

     it_raises 'a Puppet::Error', /Allowed values for idp_contact_type are: technical, support, administrative, billing and other/
   end

  end

end
