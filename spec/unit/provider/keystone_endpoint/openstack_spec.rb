require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_endpoint/openstack'

provider_class = Puppet::Type.type(:keystone_endpoint).provider(:openstack)

describe provider_class do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  describe 'when managing an endpoint' do

    let(:endpoint_attrs) do
      {
        :name         => 'foo/bar',
        :ensure       => 'present',
        :public_url   => 'http://127.0.0.1:5000',
        :internal_url => 'http://127.0.0.1:5001',
        :admin_url    => 'http://127.0.0.1:5002',
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_endpoint.new(endpoint_attrs)
    end

    let(:provider) do
      provider_class.new(resource)
    end

    before(:each) do
      set_env
    end

    describe '#create' do
      it 'creates an endpoint' do
        provider.class.stubs(:openstack)
          .with('endpoint', 'list', '--quiet', '--format', 'csv', '--long')
          .returns('"ID","Region","Service Name","Service Type","PublicURL","AdminURL","InternalURL"
"1cb05cfed7c24279be884ba4f6520262","foo","bar","","http://127.0.0.1:5000/v2.0","http://127.0.0.1:5001/v2.0","http://127.0.0.1:5002/v2.0"
'
                  )
        provider.class.stubs(:openstack)
          .with('endpoint', 'create', '--format', 'shell', ['bar', '--region', 'foo', '--publicurl', 'http://127.0.0.1:5000', '--internalurl', 'http://127.0.0.1:5001', '--adminurl', 'http://127.0.0.1:5002'])
          .returns('adminurl="http://127.0.0.1:5002"
id="3a5c4378981e4112a0d44902a43e16ef"
internalurl="http://127.0.0.1:5001"
publicurl="http://127.0.0.1:5000"
region="foo"
service_id="8137d72980fd462192f276585a002426"
service_name="bar"
service_type="test"
'
                  )
        provider.create
        expect(provider.exists?).to be_truthy
      end
    end

    describe '#destroy' do
      it 'destroys an endpoint' do
        provider.class.stubs(:openstack)
          .with('endpoint', 'list', '--quiet', '--format', 'csv', '--long')
          .returns('"ID","Region","Service Name","Service Type","PublicURL","AdminURL","InternalURL"
"1cb05cfed7c24279be884ba4f6520262","foo","bar","test","http://127.0.0.1:5000","http://127.0.0.1:5001","http://127.0.0.1:5002"
'
                  )
        provider.class.stubs(:openstack)
          .with('endpoint', 'delete', [])
        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end

    describe '#exists' do
      context 'when tenant does not exist' do
        subject(:response) do
          provider.class.stubs(:openstack)
            .with('endpoint', 'list', '--quiet', '--format', 'csv', '--long')
            .returns('"ID","Region","Service Name","Service Type","PublicURL","AdminURL","InternalURL"')
          response = provider.exists?
        end

        it { is_expected.to be_falsey }
      end
    end

    describe '#instances' do
      it 'finds every tenant' do
        provider.class.stubs(:openstack)
          .with('endpoint', 'list', '--quiet', '--format', 'csv', '--long')
          .returns('"ID","Region","Service Name","Service Type","PublicURL","AdminURL","InternalURL"
"3a5c4378981e4112a0d44902a43e16ef","foo","bar","test","http://127.0.0.1:5000","http://127.0.0.1:5001","http://127.0.0.1:5002"
'
                  )
        instances = Puppet::Type::Keystone_endpoint::ProviderOpenstack.instances
        expect(instances.count).to eq(1)
      end
    end
  end
end
