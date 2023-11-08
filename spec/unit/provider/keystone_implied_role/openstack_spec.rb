require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_implied_role/openstack'

provider_class = Puppet::Type.type(:keystone_implied_role).provider(:openstack)

describe provider_class do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_SYSTEM_SCOPE'] = 'all'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  before(:each) do
    set_env
  end

  describe 'when creating an implied role' do
    let(:implied_role_attrs) do
      {
        :title  => 'foo@bar',
        :ensure => 'present',
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_implied_role.new(implied_role_attrs)
    end

    let(:provider) do
      provider_class.new(resource)
    end

    describe '#create' do
      it 'creates an implied role' do
        expect(provider.class).to receive(:openstack)
          .with('implied role', 'create', '--format', 'shell',
            ['foo', '--implied-role', 'bar'])
          .and_return('implies="54d545116da64b68bb75244130ba51b2"
prior_role="3553ab20c4dd497a867dd822913b6d30"
')
        provider.create
        expect(provider.exists?).to be_truthy
      end
    end

    describe '#destroy' do
      it 'destroys an implied role' do
        expect(provider.class).to receive(:openstack)
          .with('implied role', 'delete',
            ['foo', '--implied-role', 'bar'])
        provider.destroy
        expect(provider.exists?).to be_falsey
      end

    end

    describe '#exists' do
      context 'when implied role does not exist' do
        subject(:response) do
          response = provider.exists?
        end
        it { is_expected.to be_falsey }
      end
    end

    describe '#instances' do
      it 'finds every role' do
        expect(provider.class).to receive(:openstack)
          .with('implied role', 'list', '--quiet', '--format', 'csv', [])
          .and_return('"Prior Role ID","Prior Role Name","Implied Role ID","Implied Role Name"
"1d7f28c7d646463dba7b0c6c5851c59b","admin","da9eac51634e41fa902de65e4ec7f165","manager"
"d00138e69f7c427693e437f33e3765af","member","906b88ee8a824e96aa93ea887337d8ac","reader"
"da9eac51634e41fa902de65e4ec7f165","manager","d00138e69f7c427693e437f33e3765af","member"
')
        instances = Puppet::Type::Keystone_implied_role::ProviderOpenstack.instances
        expect(instances.count).to eq(3)
        expect(instances[0].role).to eq('admin')
        expect(instances[0].implied_role).to eq('manager')
        expect(instances[1].role).to eq('member')
        expect(instances[1].implied_role).to eq('reader')
        expect(instances[2].role).to eq('manager')
        expect(instances[2].implied_role).to eq('member')
      end
    end
  end
end
