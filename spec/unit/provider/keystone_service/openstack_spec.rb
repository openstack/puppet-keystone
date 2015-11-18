require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_service/openstack'

provider_class = Puppet::Type.type(:keystone_service).provider(:openstack)

describe provider_class do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000/v3'
  end

  before(:each) do
    set_env
  end

  describe 'when managing service' do

    let(:resource_attrs) do
      {
        :name         => 'service_one',
        :description  => 'Service One',
        :ensure       => 'present',
        :type         => 'type_one'
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_service.new(resource_attrs)
    end

    let(:provider) do
      provider_class.new(resource)
    end

    describe '#create' do
      before(:each) do
        provider_class.expects(:openstack)
          .with('service', 'create', '--format', 'shell',
                ['type_one', '--name', 'service_one', '--description', 'Service One'])
          .returns('description="Service One"
enabled="True"
id="8f0dd4c0abc44240998fbb3f5089ecbf"
name="service_one"
type="type_one"
')
      end
      include_examples 'create the correct resource', [
        {
          'expected_results' => {
            :type        => 'type_one',
            :id          => '8f0dd4c0abc44240998fbb3f5089ecbf',
            :name        => 'service_one',
            :description => 'Service One'
          }
        },
        {
          'type in title' => {
            :title       => 'service_one::type_one',
            :description => 'Service One'
          }
        },
        {
          'type in parameter' => {
            :title       => 'service_one',
            :type        => 'type_one',
            :description => 'Service One'
          }
        }
      ]

    end
    describe '#destroy' do
      it 'destroys a service' do
        provider_class.expects(:openstack)
          .with('service', 'delete', [])
        provider.destroy
        expect(provider.exists?).to be_falsey
      end

      context 'when service does not exist' do
        subject(:response) do
          provider.exists?
        end
        it { is_expected.to be_falsey }
      end
    end

    describe '#instances' do
      it 'finds every service' do
        provider_class.expects(:openstack)
          .with('service', 'list', '--quiet', '--format', 'csv', '--long')
          .returns('"ID","Name","Type","Description"
"8f0dd4c0abc44240998fbb3f5089ecbf","service_one","type_one","Service One"
')
        instances = provider_class.instances
        expect(instances.count).to eq(1)
      end
    end
  end

  context '#prefetch' do
    before(:each) do
      # This call done by self.instance in prefetch in what make the
      # resource exists.
      provider_class.expects(:openstack)
        .with('service', 'list', '--quiet', '--format', 'csv', '--long')
        .returns('"ID","Name","Type","Description"
"8f0dd4c0abc44240998fbb3f5089ecbf","service_1","type_1",""
')
    end
    let(:service_1) do
      Puppet::Type::Keystone_service.new(:title => 'service_1::type_1')
    end
    let(:service_2) do
      Puppet::Type::Keystone_service.new(:title => 'service_1', :type => 'type_2')
    end
    let(:resources) { [service_1, service_2] }
    include_examples 'prefetch the resources'
  end

  context 'duplicate detection' do
    let(:service_1) do
      Puppet::Type::Keystone_service.new(:title => 'service_1::type_1')
    end
    let(:service_2) do
      Puppet::Type::Keystone_service.new(:title => 'service_1', :type => 'type_1')
    end
    let(:resources) { [service_1, service_2] }
    include_examples 'detect duplicate resource'
  end
end
