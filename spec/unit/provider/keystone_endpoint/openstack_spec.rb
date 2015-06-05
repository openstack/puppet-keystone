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
        :name         => 'region/endpoint',
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
        provider.class.expects(:openstack)
          .with('endpoint', 'create', '--format', 'shell', ['endpoint', 'admin', 'http://127.0.0.1:5002', '--region', 'region'])
          .returns('admin_url="http://127.0.0.1:5002"
id="endpoint1_id"
region="region"
')
        provider.class.expects(:openstack)
          .with('endpoint', 'create', '--format', 'shell', ['endpoint', 'internal', 'http://127.0.0.1:5001', '--region', 'region'])
          .returns('internal_url="http://127.0.0.1:5001"
id="endpoint2_id"
region="region"
')
        provider.class.expects(:openstack)
          .with('endpoint', 'create', '--format', 'shell', ['endpoint', 'public', 'http://127.0.0.1:5000', '--region', 'region'])
          .returns('public_url="http://127.0.0.1:5000"
id="endpoint3_id"
region="region"
')
        provider.create
        expect(provider.exists?).to be_truthy
        expect(provider.id).to eq('endpoint1_id,endpoint2_id,endpoint3_id')
      end
    end

    describe '#destroy' do
      it 'destroys an endpoint' do
        provider.instance_variable_get('@property_hash')[:id] = 'endpoint1_id,endpoint2_id,endpoint3_id'
        provider.class.expects(:openstack)
          .with('endpoint', 'delete', 'endpoint1_id')
        provider.class.expects(:openstack)
          .with('endpoint', 'delete', 'endpoint2_id')
        provider.class.expects(:openstack)
          .with('endpoint', 'delete', 'endpoint3_id')
        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end

    describe '#exists' do
      context 'when tenant does not exist' do
        subject(:response) do
          response = provider.exists?
        end

        it { is_expected.to be_falsey }
      end
    end

    describe '#instances' do
      it 'finds every tenant' do
        provider.class.expects(:openstack)
          .with('endpoint', 'list', '--quiet', '--format', 'csv', [])
          .returns('"ID","Region","Service Name","Service Type","Enabled","Interface","URL"
"endpoint1_id","RegionOne","keystone","identity",True,"admin","http://127.0.0.1:5002"
"endpoint2_id","RegionOne","keystone","identity",True,"internal","https://127.0.0.1:5001"
"endpoint3_id","RegionOne","keystone","identity",True,"public","https://127.0.0.1:5000"
')
        instances = Puppet::Type::Keystone_endpoint::ProviderOpenstack.instances
        expect(instances.count).to eq(1)
      end
    end
  end
end
