require 'spec_helper'

describe 'keystone::service' do

  describe "with default parameters" do
    it { should contain_service('keystone').with(
      :ensure     => 'running',
      :enable     => true,
      :hasstatus  => true,
      :hasrestart => true
    ) }
    it { should_not contain_exec('validate_keystone_connection') }
  end

  describe "with validation on" do
    let :params do
      {
       :validate => 'true',
       :admin_token => 'admintoken'
      }
    end

    it { should contain_service('keystone').with(
      :ensure     => 'running',
      :enable     => true,
      :hasstatus  => true,
      :hasrestart => true
    ) }
    it { should contain_exec('validate_keystone_connection') }
  end
end
