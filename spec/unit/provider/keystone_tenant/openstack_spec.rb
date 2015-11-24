require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_tenant/openstack'

setup_provider_tests

provider_class = Puppet::Type.type(:keystone_tenant).provider(:openstack)

describe provider_class do

  after :each do
    provider_class.reset
  end

  let(:resource_attrs) do
    {
      :name         => 'project_one',
      :description  => 'Project One',
      :ensure       => 'present',
      :enabled      => 'True'
    }
  end

  let(:resource) do
    Puppet::Type::Keystone_tenant.new(resource_attrs)
  end

  let(:provider) do
    provider_class.new(resource)
  end

  def before_hook(domainlist, provider_class)
    if domainlist
      provider_class.expects(:openstack).once
        .with('domain', 'list', '--quiet', '--format', 'csv', [])
        .returns('"ID","Name","Enabled","Description"
"domain_one_id","domain_one",True,"project_one domain"
"domain_two_id","domain_two",True,"domain_two domain"
"another_domain_id","another_domain",True,"another domain"
"disabled_domain_id","disabled_domain",False,"disabled domain"
"default","Default",True,"the default domain"
')
    end
  end

  before :each, :domainlist => true do
    before_hook(true, provider_class)
  end

  before :each, :domainlist => false do
    before_hook(false, provider_class)
  end

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:35357/v3'
  end

  before(:each) do
    set_env
  end

  describe 'when managing a tenant' do

    describe '#create', :domainlist => false do
      it 'creates a tenant' do
        provider.class.expects(:openstack)
          .with('project', 'create', '--format', 'shell', ['project_one', '--enable', '--description', 'Project One', '--domain', 'Default'])
          .returns('description="Project One"
enabled="True"
name="project_one"
id="project_one"
domain_id="domain_one_id"
')
        provider.create
        expect(provider.exists?).to be_truthy
      end
    end

    describe '#destroy', :domainlist => false do
      it 'destroys a tenant' do
        provider.instance_variable_get('@property_hash')[:id] = 'my-project-id'
        provider.class.expects(:openstack)
          .with('project', 'delete', 'my-project-id')
        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end

    context 'when tenant does not exist', :domainlist => false do
      it 'exists? should be false' do
        expect(provider.exists?).to be_falsey
      end
    end

    describe '#instances', :domainlist => true do
      it 'finds every tenant' do
        provider_class.expects(:openstack)
          .with('project', 'list', '--quiet', '--format', 'csv', '--long')
          .returns('"ID","Name","Domain ID","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","project_one","domain_one_id","Project One",True
"2cb05cfed7c24279be884ba4f6520262","project_one","domain_two_id","Project One, domain Two",True
')
        instances = provider.class.instances
        expect(instances[0].name).to eq('project_one::domain_one')
        expect(instances[0].domain).to eq('domain_one')
        expect(instances[1].name).to eq('project_one::domain_two')
        expect(instances[1].domain).to eq('domain_two')
      end
    end

    describe '#prefetch' do
      before(:each) do
        provider_class.expects(:domain_name_from_id).with('default').returns('Default')
        provider_class.expects(:domain_name_from_id).with('domain_two_id').returns('domain_two')
        # There are one for self.instance and one for each Puppet::Type.type calls.
        provider.class.expects(:openstack)
          .with('project', 'list', '--quiet', '--format', 'csv', '--long')
          .returns('"ID","Name","Domain ID","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","project_one","default","A project",True
"2cb05cfed7c24279be884ba4f6520262","project_one","domain_two_id","A domain_two",True
')
      end
      let(:resources) do
        [Puppet::Type.type(:keystone_tenant).new(:title => 'project_one', :ensure => :absent),
          Puppet::Type.type(:keystone_tenant).new(:title => 'non_existant', :ensure => :absent)]
      end
      include_examples 'prefetch the resources'
    end

    describe '#flush' do
      context '.enable' do
        describe '-> false' do
          it 'properly set enable to false' do
            provider_class.expects(:openstack)
              .with('project', 'set', ['37b7086693ec482389799da5dc546fa4', '--disable'])
              .returns('""')
            provider.expects(:id).returns('37b7086693ec482389799da5dc546fa4')
            provider.enabled = :false
            provider.flush
          end
        end
        describe '-> true' do
          it 'properly set enable to true' do
            provider_class.expects(:openstack)
              .with('project', 'set', ['37b7086693ec482389799da5dc546fa4', '--enable'])
              .returns('""')
            provider.expects(:id).returns('37b7086693ec482389799da5dc546fa4')
            provider.enabled = :true
            provider.flush
          end
        end
      end
      context '.description' do
        it 'change the description' do
          provider_class.expects(:openstack)
            .with('project', 'set', ['37b7086693ec482389799da5dc546fa4',
                                     '--description=new description'])
            .returns('""')
          provider.expects(:id).returns('37b7086693ec482389799da5dc546fa4')
          provider.expects(:resource).returns(:description => 'new description')
          provider.description = 'new description'
          provider.flush
        end
      end
      context '.enable/description' do
        it 'properly change the enable and the description' do
          provider_class.expects(:openstack)
            .with('project', 'set', ['37b7086693ec482389799da5dc546fa4', '--disable',
                                     '--description=new description'])
            .returns('""')
          provider.expects(:id).returns('37b7086693ec482389799da5dc546fa4')
          provider.expects(:resource).returns(:description => 'new description')
          provider.enabled = :false
          provider.description = 'new description'
          provider.flush
        end
      end
    end
  end

  context 'when managing a tenant using v3 domain' do
    describe '#create' do
      describe 'with domain in resource', :domainlist => false do
        before(:each) do
          provider_class.expects(:openstack)
            .with('project', 'create', '--format', 'shell', ['project_one', '--enable', '--description', 'Project One', '--domain', 'domain_one'])
            .returns('description="Project One"
enabled="True"
name="project_one"
id="project-id"
domain_id="domain_one_id"
')
        end
        include_examples 'create the correct resource', [
          {
            'expected_results' => {
              :domain => 'domain_one',
              :id     => 'project-id',
              :name   => 'project_one'
            }
          },
          {
            'domain in parameter' => {
              :name        => 'project_one',
              :description => 'Project One',
              :ensure      => 'present',
              :enabled     => 'True',
              :domain      => 'domain_one'
            }
          },
          {
            'domain in title' => {
              :title       => 'project_one::domain_one',
              :description => 'Project One',
              :ensure      => 'present',
              :enabled     => 'True'
            }
          },
          {
            'domain in parameter override domain in title' => {
              :title       => 'project_one::domain_two',
              :description => 'Project One',
              :ensure      => 'present',
              :enabled     => 'True',
              :domain      => 'domain_one'
            }
          }
        ]
      end
    end

    describe '#prefetch' do
      before(:each) do
        provider_class.expects(:domain_name_from_id)
          .with('domain_one_id').returns('domain_one')
        provider_class.expects(:domain_name_from_id)
          .with('domain_two_id').returns('domain_two')
        provider_class.expects(:openstack)
          .with('project', 'list', '--quiet', '--format', 'csv', '--long')
          .returns('"ID","Name","Domain ID","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","name","domain_one_id","A project_one",True
"2cb05cfed7c24279be884ba4f6520262","project_one","domain_two_id","A domain_two",True
')
      end
      let(:resources) do
        [
          Puppet::Type.type(:keystone_tenant)
            .new(:title => 'name::domain_one', :ensure => :absent),
          Puppet::Type.type(:keystone_tenant)
            .new(:title => 'noex::domain_one', :ensure => :absent)
        ]
      end
      include_examples 'prefetch the resources'
    end

    context 'different name, identical resource' do
      let(:resources) do
        [
          Puppet::Type.type(:keystone_tenant)
            .new(:title => 'name::domain_one', :ensure => :present),
          Puppet::Type.type(:keystone_tenant)
            .new(:title => 'name', :domain => 'domain_one', :ensure => :present)
        ]
      end
      include_examples 'detect duplicate resource'
    end
  end
end
