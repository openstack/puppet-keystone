require 'spec_helper'

describe 'keystone::service' do

  let :facts do
    @default_facts.merge({ :osfamily => 'Debian' })
  end

  describe "with default parameters" do
    it { is_expected.to contain_service('keystone').with(
      :ensure     => nil,
      :enable     => true,
      :hasstatus  => true,
      :hasrestart => true,
      :tag        => 'keystone-service',
    ) }
    it { is_expected.to_not contain_exec('validate_keystone_connection') }
  end

  describe "with validation on" do
    let :params do
      {
       :validate => 'true',
       :admin_token => 'admintoken'
      }
    end

    it { is_expected.to contain_service('keystone').with(
      :ensure     => nil,
      :enable     => true,
      :hasstatus  => true,
      :hasrestart => true,
      :tag        => 'keystone-service',
    ) }
    it { is_expected.to contain_exec('validate_keystone_connection') }
  end
end
