require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_endpoint/openstack'

describe Puppet::Type.type(:keystone_endpoint).provider(:openstack) do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  describe 'when managing an endpoint' do

    let(:endpoint_attrs) do
      {
        :title        => 'region/endpoint',
        :ensure       => 'present',
        :public_url   => 'http://127.0.0.1:5000',
        :internal_url => 'http://127.0.0.1:5001',
        :admin_url    => 'http://127.0.0.1:5002'
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_endpoint.new(endpoint_attrs)
    end

    let(:provider) do
      described_class.new(resource)
    end

    before(:each) do
      set_env
      described_class.endpoints = nil
      described_class.services  = nil
    end

    describe '#create' do
      before(:each) do
        described_class.expects(:openstack)
          .with('endpoint', 'create', '--format', 'shell',
                ['service_id1', 'admin', 'http://127.0.0.1:5002', '--region', 'region'])
          .returns('admin_url="http://127.0.0.1:5002"
id="endpoint1_id"
region="region"
')
        described_class.expects(:openstack)
          .with('endpoint', 'create', '--format', 'shell',
                ['service_id1', 'internal', 'http://127.0.0.1:5001', '--region', 'region'])
          .returns('internal_url="http://127.0.0.1:5001"
id="endpoint2_id"
region="region"
')
        described_class.expects(:openstack)
          .with('endpoint', 'create', '--format', 'shell',
                ['service_id1', 'public', 'http://127.0.0.1:5000', '--region', 'region'])
          .returns('public_url="http://127.0.0.1:5000"
id="endpoint3_id"
region="region"
')
        described_class.expects(:openstack)
          .with('service', 'list', '--quiet', '--format', 'csv', [])
          .returns('"ID","Name","Type"
"service_id1","endpoint","type_one"
')
      end
      context 'without the type' do
        it 'creates an endpoint' do
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.id).to eq('endpoint1_id,endpoint2_id,endpoint3_id')
        end
      end
      context 'with the type' do
        let(:endpoint_attrs) do
          {
            :title        => 'region/endpoint',
            :ensure       => 'present',
            :public_url   => 'http://127.0.0.1:5000',
            :internal_url => 'http://127.0.0.1:5001',
            :admin_url    => 'http://127.0.0.1:5002',
            :type         => 'type_one'
          }
        end

        it 'creates an endpoint' do
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.id).to eq('endpoint1_id,endpoint2_id,endpoint3_id')
        end
      end
    end

    describe '#destroy' do
      it 'destroys an endpoint' do
        provider.instance_variable_get('@property_hash')[:id] = 'endpoint1_id,endpoint2_id,endpoint3_id'
        described_class.expects(:openstack)
          .with('endpoint', 'delete', 'endpoint1_id')
        described_class.expects(:openstack)
          .with('endpoint', 'delete', 'endpoint2_id')
        described_class.expects(:openstack)
          .with('endpoint', 'delete', 'endpoint3_id')
        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end

    describe '#exists' do
      context 'when tenant does not exist' do
        subject(:response) do
          provider.exists?
        end

        it { is_expected.to be_falsey }
      end
    end

    describe '#instances' do
      context 'basic' do
        it 'finds every tenant' do
          described_class.expects(:openstack)
            .with('endpoint', 'list', '--quiet', '--format', 'csv', [])
            .returns('"ID","Region","Service Name","Service Type","Enabled","Interface","URL"
"endpoint1_id","RegionOne","keystone","identity",True,"admin","http://127.0.0.1:5002"
"endpoint2_id","RegionOne","keystone","identity",True,"internal","https://127.0.0.1:5001"
"endpoint3_id","RegionOne","keystone","identity",True,"public","https://127.0.0.1:5000"
')
          instances = described_class.instances
          expect(instances.count).to eq(1)
        end
      end
      context 'many different region' do
        it 'should not mix up the endpoints' do
          described_class.expects(:openstack)
            .with('endpoint', 'list', '--quiet', '--format', 'csv', [])
            .returns('"ID","Region","Service Name","Service Type","Enabled","Interface","URL"
"endpoint1_id","RegionOne","keystone","identity",True,"admin","http://One-127.0.0.1:5002"
"endpoint2_id","RegionOne","keystone","identity",True,"internal","https://One-127.0.0.1:5001"
"endpoint3_id","RegionOne","keystone","identity",True,"public","https://One-127.0.0.1:5000"
"endpoint4_id","RegionTwo","keystone","identity",True,"admin","http://Two-127.0.0.1:5002"
"endpoint5_id","RegionTwo","keystone","identity",True,"internal","https://Two-127.0.0.1:5001"
"endpoint6_id","RegionTwo","keystone","identity",True,"public","https://Two-127.0.0.1:5000"
"endpoint7_id","RegionThree","keystone","identity",True,"admin","http://Three-127.0.0.1:5002"
"endpoint8_id","RegionThree","keystone","identity",True,"internal","https://Three-127.0.0.1:5001"
"endpoint9_id","RegionThree","keystone","identity",True,"public","https://Three-127.0.0.1:5000"
"endpoint10_id","RegionFour","keystone","identity",True,"admin","http://Four-127.0.0.1:5002"
"endpoint11_id","RegionFour","keystone","identity",True,"internal","https://Four-127.0.0.1:5001"
"endpoint12_id","RegionFour","keystone","identity",True,"public","https://Four-127.0.0.1:5000"
"endpoint13_id","RegionFive","keystone","identity",True,"admin","http://Five-127.0.0.1:5002"
"endpoint14_id","RegionFive","keystone","identity",True,"internal","https://Five-127.0.0.1:5001"
"endpoint15_id","RegionFive","keystone","identity",True,"public","https://Five-127.0.0.1:5000"
"endpoint16_id","RegionSix","keystone","identity",True,"admin","http://Six-127.0.0.1:5002"
"endpoint17_id","RegionSix","keystone","identity",True,"internal","https://Six-127.0.0.1:5001"
"endpoint18_id","RegionSix","keystone","identity",True,"public","https://Six-127.0.0.1:5000"
"endpoint19_id","RegionSeven","keystone","identity",True,"admin","http://Seven-127.0.0.1:5002"
"endpoint20_id","RegionSeven","keystone","identity",True,"internal","https://Seven-127.0.0.1:5001"
"endpoint21_id","RegionSeven","keystone","identity",True,"public","https://Seven-127.0.0.1:5000"
')
          instances = described_class.instances
          expect(instances).to have_array_of_instances_hash([
            {:name=>"RegionOne/keystone::identity",
              :ensure=>:present,
              :id=>"endpoint1_id,endpoint2_id,endpoint3_id",
              :region=>"RegionOne",
              :admin_url=>"http://One-127.0.0.1:5002",
              :internal_url=>"https://One-127.0.0.1:5001",
              :public_url=>"https://One-127.0.0.1:5000"},
            {:name=>"RegionTwo/keystone::identity",
              :ensure=>:present,
              :id=>"endpoint4_id,endpoint5_id,endpoint6_id",
              :region=>"RegionTwo",
              :admin_url=>"http://Two-127.0.0.1:5002",
              :internal_url=>"https://Two-127.0.0.1:5001",
              :public_url=>"https://Two-127.0.0.1:5000"},
            {:name=>"RegionThree/keystone::identity",
              :ensure=>:present,
              :id=>"endpoint7_id,endpoint8_id,endpoint9_id",
              :region=>"RegionThree",
              :admin_url=>"http://Three-127.0.0.1:5002",
              :internal_url=>"https://Three-127.0.0.1:5001",
              :public_url=>"https://Three-127.0.0.1:5000"},
            {:name=>"RegionFour/keystone::identity",
              :ensure=>:present,
              :id=>"endpoint10_id,endpoint11_id,endpoint12_id",
              :region=>"RegionFour",
              :admin_url=>"http://Four-127.0.0.1:5002",
              :internal_url=>"https://Four-127.0.0.1:5001",
              :public_url=>"https://Four-127.0.0.1:5000"},
            {:name=>"RegionFive/keystone::identity",
              :ensure=>:present,
              :id=>"endpoint13_id,endpoint14_id,endpoint15_id",
              :region=>"RegionFive",
              :admin_url=>"http://Five-127.0.0.1:5002",
              :internal_url=>"https://Five-127.0.0.1:5001",
              :public_url=>"https://Five-127.0.0.1:5000"},
            {:name=>"RegionSix/keystone::identity",
              :ensure=>:present,
              :id=>"endpoint16_id,endpoint17_id,endpoint18_id",
              :region=>"RegionSix",
              :admin_url=>"http://Six-127.0.0.1:5002",
              :internal_url=>"https://Six-127.0.0.1:5001",
              :public_url=>"https://Six-127.0.0.1:5000"},
            {:name=>"RegionSeven/keystone::identity",
              :ensure=>:present,
              :id=>"endpoint19_id,endpoint20_id,endpoint21_id",
              :region=>"RegionSeven",
              :admin_url=>"http://Seven-127.0.0.1:5002",
              :internal_url=>"https://Seven-127.0.0.1:5001",
              :public_url=>"https://Seven-127.0.0.1:5000"}])
        end
      end
    end

    describe '#prefetch' do
      context 'working: fq or nfq and matching resource' do
        before(:each) do
          described_class.expects(:openstack)
            .with('endpoint', 'list', '--quiet', '--format', 'csv', [])
            .returns('"ID","Region","Service Name","Service Type","Enabled","Interface","URL"
"endpoint1_id","RegionOne","keystone","identity",True,"admin","http://127.0.0.1:5002"
"endpoint2_id","RegionOne","keystone","identity",True,"internal","https://127.0.0.1:5001"
"endpoint3_id","RegionOne","keystone","identity",True,"public","https://127.0.0.1:5000"
')
        end
        context '#fq resource in title' do
          let(:resources) do
            [Puppet::Type.type(:keystone_endpoint).new(:title => 'RegionOne/keystone::identity', :ensure => :present),
              Puppet::Type.type(:keystone_endpoint).new(:title => 'RegionOne/keystone::identityv3', :ensure => :present)]
          end
          include_examples 'prefetch the resources'
        end
        context '#fq resource' do
          let(:resources) do
            [Puppet::Type.type(:keystone_endpoint).new(:title => 'keystone', :region => 'RegionOne', :type => 'identity', :ensure => :present),
              Puppet::Type.type(:keystone_endpoint).new(:title => 'RegionOne/keystone::identityv3', :ensure => :present)]
          end
          include_examples 'prefetch the resources'
        end
        context '#nfq resource in title matching existing endpoint' do
          let(:resources) do
            [Puppet::Type.type(:keystone_endpoint).new(:title => 'RegionOne/keystone', :ensure => :present),
              Puppet::Type.type(:keystone_endpoint).new(:title => 'RegionOne/keystone::identityv3', :ensure => :present)]
          end
          include_examples 'prefetch the resources'
        end
        context '#nfq resource matching existing endpoint' do
          let(:resources) do
            [Puppet::Type.type(:keystone_endpoint).new(:title => 'keystone', :region => 'RegionOne', :ensure => :present),
              Puppet::Type.type(:keystone_endpoint).new(:title => 'RegionOne/keystone::identityv3', :ensure => :present)]
          end
          include_examples 'prefetch the resources'
        end
      end

      context 'not working' do
        context 'too many type' do
          before(:each) do
            described_class.expects(:openstack)
              .with('endpoint', 'list', '--quiet', '--format', 'csv', [])
              .returns('"ID","Region","Service Name","Service Type","Enabled","Interface","URL"
"endpoint1_id","RegionOne","keystone","identity",True,"admin","http://127.0.0.1:5002"
"endpoint2_id","RegionOne","keystone","identity",True,"internal","https://127.0.0.1:5001"
"endpoint3_id","RegionOne","keystone","identity",True,"public","https://127.0.0.1:5000"
"endpoint4_id","RegionOne","keystone","identityv3",True,"admin","http://127.0.0.1:5002"
"endpoint5_id","RegionOne","keystone","identityv3",True,"internal","https://127.0.0.1:5001"
"endpoint6_id","RegionOne","keystone","identityv3",True,"public","https://127.0.0.1:5000"
')
          end
          it "should fail as it's not possible to get the right type here" do
            existing = Puppet::Type.type(:keystone_endpoint)
              .new(:title => 'RegionOne/keystone', :ensure => :present)
            resource = mock
            r = []
            r << existing

            catalog = Puppet::Resource::Catalog.new
            r.each { |res| catalog.add_resource(res) }
            m_value = mock
            m_first = mock
            resource.expects(:values).returns(m_value)
            m_value.expects(:first).returns(m_first)
            m_first.expects(:catalog).returns(catalog)
            m_first.expects(:class).returns(described_class.resource_type)
            expect { described_class.prefetch(resource) }
              .to raise_error(Puppet::Error,
                              /endpoint matching RegionOne\/keystone: identity identityv3/)
          end
        end
      end

      context 'not any type but existing service' do
        before(:each) do
          described_class.expects(:openstack)
            .with('endpoint', 'list', '--quiet', '--format', 'csv', [])
            .returns('"ID","Region","Service Name","Service Type","Enabled","Interface","URL"
"endpoint1_id","RegionOne","keystone","identity",True,"admin","http://127.0.0.1:5002"
"endpoint2_id","RegionOne","keystone","identity",True,"internal","https://127.0.0.1:5001"
"endpoint3_id","RegionOne","keystone","identity",True,"public","https://127.0.0.1:5000"
')
          described_class.expects(:openstack)
            .with('service', 'list', '--quiet', '--format', 'csv', [])
            .returns('"ID","Name","Type"
"service1_id","keystonev3","identity"
')
        end
        it 'should be successful' do
          existing = Puppet::Type.type(:keystone_endpoint)
            .new(:title => 'RegionOne/keystonev3', :ensure => :present)
          resource = mock
          r = []
          r << existing

          catalog = Puppet::Resource::Catalog.new
          r.each { |res| catalog.add_resource(res) }
          m_value = mock
          m_first = mock
          resource.expects(:values).returns(m_value)
          m_value.expects(:first).returns(m_first)
          m_first.expects(:catalog).returns(catalog)
          m_first.expects(:class).returns(described_class.resource_type)

          expect { described_class.prefetch(resource) }.not_to raise_error
          expect(existing.provider.ensure).to eq(:absent)
        end
      end
    end

    describe '#flush' do
      let(:endpoint_attrs) do
        {
          :title        => 'region/service_1',
          :ensure       => 'present',
          :public_url   => 'http://127.0.0.1:5000',
          :internal_url => 'http://127.0.0.1:5001',
          :admin_url    => 'http://127.0.0.1:4999',
          :type         => 'service_type1'
        }
      end
      context '#update a missing endpoint' do
        it 'creates an endpoint' do
          described_class.expects(:openstack)
            .with('endpoint', 'create', '--format', 'shell',
                  ['service_id_1', 'admin', 'http://127.0.0.1:4999',
                   '--region', 'region'])
            .returns(<<-eoo
enabled="True"
id="endpoint1_id"
interface="internal"
region="None"
region_id="None"
service_id="service_id_1"
service_name="service_1"
service_type="service_type1"
url="http://127.0.0.1:5001"
          eoo
                    )

          provider.expects(:property_flush)
            .times(5)
            .returns({:admin_url => 'http://127.0.0.1:4999'})
          provider.expects(:property_hash)
            .twice
            .returns({:id => ',endpoint2_id,endpoint3_id'})
          provider.expects(:service_id)
            .returns('service_id_1')
          provider.flush
          expect(provider.exists?).to be_truthy
          expect(provider.id).to eq('endpoint1_id,endpoint2_id,endpoint3_id')
        end
      end

      context 'adjust a url' do
        it 'update the url' do
          described_class.expects(:openstack)
            .with('endpoint', 'set',
                  ['endpoint1_id', '--url=http://127.0.0.1:4999'])
          provider.expects(:property_flush)
            .times(4)
            .returns({:admin_url => 'http://127.0.0.1:4999'})
          provider.expects(:property_hash)
            .twice
            .returns({:id => 'endpoint1_id,endpoint2_id,endpoint3_id'})
          provider.flush
          expect(provider.exists?).to be_truthy
          expect(provider.id).to eq('endpoint1_id,endpoint2_id,endpoint3_id')
        end
      end
    end
  end
end
