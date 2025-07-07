require 'spec_helper'

describe 'keystone::resource::service_user' do

  let (:title) { 'keystone_config' }

  let :params do
    { :username     => 'keystone',
      :password     => 'secret' }
  end

  shared_examples 'shared examples' do
    context 'with only required parameters' do
      it 'configures keystone service_user' do
        is_expected.to contain_keystone_config('service_user/username').with_value('keystone')
        is_expected.to contain_keystone_config('service_user/password').with_value('secret').with_secret(true)
        is_expected.to contain_keystone_config('service_user/auth_url').with_value('http://127.0.0.1:5000')
        is_expected.to contain_keystone_config('service_user/project_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('service_user/project_domain_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('service_user/user_domain_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('service_user/system_scope').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('service_user/send_service_user_token').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('service_user/insecure').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('service_user/auth_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('service_user/auth_version').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('service_user/cafile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('service_user/certfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('service_user/keyfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('service_user/region_name').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'set all keystone service_user parameters' do
      before do
        params.merge! ({
          :username                     => 'username',
          :password                     => 'hardpassword',
          :auth_url                     => 'http://127.1.1.127:5000/',
          :project_name                 => 'services',
          :user_domain_name             => 'MyDomain',
          :project_domain_name          => 'OurDomain',
          :send_service_user_token      =>  true,
          :insecure                     =>  true,
          :auth_type                    => 'password',
          :auth_version                 => '3',
          :cafile                       => 'cafile.pem',
          :certfile                     => 'certfile.crt',
          :keyfile                      => 'somekey.key',
          :region_name                  => 'MyRegion',
        })
      end
      it 'override keystone service_user parameters' do
        is_expected.to contain_keystone_config('service_user/username').with_value(params[:username])
        is_expected.to contain_keystone_config('service_user/password').with_value(params[:password]).with_secret(true)
        is_expected.to contain_keystone_config('service_user/auth_url').with_value(params[:auth_url])
        is_expected.to contain_keystone_config('service_user/project_name').with_value( params[:project_name] )
        is_expected.to contain_keystone_config('service_user/project_domain_name').with_value(params[:project_domain_name])
        is_expected.to contain_keystone_config('service_user/user_domain_name').with_value(params[:user_domain_name])
        is_expected.to contain_keystone_config('service_user/system_scope').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_keystone_config('service_user/send_service_user_token').with_value(params[:send_service_user_token])
        is_expected.to contain_keystone_config('service_user/insecure').with_value(params[:insecure])
        is_expected.to contain_keystone_config('service_user/auth_version').with_value(params[:auth_version])
        is_expected.to contain_keystone_config('service_user/cafile').with_value(params[:cafile])
        is_expected.to contain_keystone_config('service_user/certfile').with_value(params[:certfile])
        is_expected.to contain_keystone_config('service_user/keyfile').with_value(params[:keyfile])
        is_expected.to contain_keystone_config('service_user/region_name').with_value(params[:region_name])
      end

      context 'set system_scope' do
        before do
          params.merge! ({
            :project_name        => 'services',
            :project_domain_name => 'Default',
            :system_scope        => 'all',
          })
        end
        it 'override system_scope but ignore project parameters' do
          is_expected.to contain_keystone_config('service_user/project_name').with_value('<SERVICE DEFAULT>')
          is_expected.to contain_keystone_config('service_user/project_domain_name').with_value('<SERVICE DEFAULT>')
          is_expected.to contain_keystone_config('service_user/system_scope').with_value(params[:system_scope])
        end
      end
    end

    context 'without password required parameter' do
      let :params do
        params.delete(:password)
      end
      it { expect { is_expected.to raise_error(Puppet::Error) } }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      include_examples 'shared examples'
    end
  end

end
