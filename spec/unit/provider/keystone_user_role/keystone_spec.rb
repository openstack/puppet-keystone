require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_user_role/keystone'

provider_class = Puppet::Type.type(:keystone_user_role).provider(:keystone)

describe provider_class do

  describe '#get_user_and_tenant' do

    let :user do
      'username@example.org'
    end

    let :tenant do
      'test'
    end

    let :resource do
      Puppet::Type::Keystone_user_role.new(
        {
          :name      => "#{user}@#{tenant}",
          :roles     => [ '_member_' ],
        }
      )
    end

    let :provider do
      provider_class.new(resource)
    end

    before :each do
      provider_class.expects(:get_user_and_tenant).with(user,tenant).returns([user,tenant])
    end

    it 'should handle an email address as username' do
      provider.get_user_and_tenant.should == [ user, tenant ]
    end
  end
end
