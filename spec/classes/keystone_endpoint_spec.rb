require 'spec_helper'

describe 'keystone::endpoint' do

  it { is_expected.to contain_keystone_service('keystone::identity').with(
    :ensure      => 'present',
    :description => 'OpenStack Identity Service'
  )}

  describe 'with default parameters' do
    it { is_expected.to contain_keystone_endpoint('RegionOne/keystone::identity').with(
      :ensure       => 'present',
      :public_url   => 'http://127.0.0.1:5000',
      :admin_url    => 'http://127.0.0.1:35357',
      :internal_url => 'http://127.0.0.1:5000',
      :region       => 'RegionOne'
    )}
  end

  describe 'with overridden parameters' do

    let :params do
      { :version      => 'v42.6',
        :public_url   => 'https://identity.some.tld/the/main/endpoint',
        :admin_url    => 'https://identity-int.some.tld/some/admin/endpoint',
        :internal_url => 'https://identity-int.some.tld/some/internal/endpoint',
        :region       => 'East'
      }
    end

    it { is_expected.to contain_keystone_endpoint('East/keystone::identity').with(
      :ensure       => 'present',
      :public_url   => 'https://identity.some.tld/the/main/endpoint/v42.6',
      :admin_url    => 'https://identity-int.some.tld/some/admin/endpoint/v42.6',
      :internal_url => 'https://identity-int.some.tld/some/internal/endpoint/v42.6',
      :region       => 'East'
    )}
  end

  describe 'with unset version to test backward compatibility' do
    let :params do
      { :version => 'unset' }
    end

    it { is_expected.to contain_keystone_endpoint('RegionOne/keystone::identity').with(
      :ensure       => 'present',
      :public_url   => 'http://127.0.0.1:5000/v2.0',
      :admin_url    => 'http://127.0.0.1:35357/v2.0',
      :internal_url => 'http://127.0.0.1:5000/v2.0'
    )}
  end

  describe 'without internal_url parameter' do

    let :params do
      { :public_url => 'https://identity.some.tld/the/main/endpoint' }
    end

    it 'internal_url should default to public_url' do
      is_expected.to contain_keystone_endpoint('RegionOne/keystone::identity').with(
        :ensure       => 'present',
        :public_url   => 'https://identity.some.tld/the/main/endpoint',
        :internal_url => 'https://identity.some.tld/the/main/endpoint'
      )
    end
  end

  describe 'with domain parameters' do

    let :params do
      { :user_domain    => 'userdomain',
        :project_domain => 'projectdomain',
        :default_domain => 'defaultdomain' }
    end

    it { is_expected.to contain_keystone__resource__service_identity('keystone').with(
      :user_domain    => 'userdomain',
      :project_domain => 'projectdomain',
      :default_domain => 'defaultdomain'
    )}
  end
end
