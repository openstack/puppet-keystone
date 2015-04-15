# TODO: This should be extracted into openstacklib during the Kilo cycle
# Load libraries from aviator here to simulate how they live together in a real puppet run
$LOAD_PATH.push(File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'modules', 'aviator', 'lib'))
require 'puppet'
require 'spec_helper'
require 'puppet/provider/openstack'


describe Puppet::Provider::Openstack do

  before(:each) do
    ENV['OS_USERNAME']    = nil
    ENV['OS_PASSWORD']    = nil
    ENV['OS_TENANT_NAME'] = nil
    ENV['OS_AUTH_URL']    = nil
  end

  let(:type) do
    Puppet::Type.newtype(:test_resource) do
      newparam(:name, :namevar => true)
      newparam(:auth)
      newparam(:log_file)
    end
  end

  shared_examples 'authenticating with environment variables' do
    it 'makes a successful request' do
      ENV['OS_USERNAME']    = 'test'
      ENV['OS_PASSWORD']    = 'abc123'
      ENV['OS_TENANT_NAME'] = 'test'
      ENV['OS_AUTH_URL']    = 'http://127.0.0.1:35357/v2.0'
      if provider.class == Class
        provider.stubs(:openstack)
                .with('project', 'list', '--quiet', '--format', 'csv', [[ '--long' ]])
                .returns('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","test","Test tenant",True
')
      else
        provider.class.stubs(:openstack)
                    .with('project', 'list', '--quiet', '--format', 'csv', [[ '--long' ]])
                    .returns('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","test","Test tenant",True
')
      end
      response = provider.request('project', 'list', nil, nil, '--long' )
      expect(response.first[:description]).to match /Test tenant/
    end
  end

  shared_examples 'it has no credentials' do
    it 'fails to authenticate' do
      expect{ provider.request('project', 'list', nil, nil, '--long') }.to raise_error(Puppet::Error::OpenstackAuthInputError, /No credentials provided/)
    end
  end

  describe '#request' do

    context 'with valid password credentials in parameters' do
      let(:resource_attrs) do
        {
          :name         => 'stubresource',
          :auth         => {
            'username'    => 'test',
            'password'    => 'abc123',
            'tenant_name' => 'test',
            'auth_url'    => 'http://127.0.0.1:5000/v2.0',
          }
        }
      end
      let(:provider) do
        Puppet::Provider::Openstack.new(type.new(resource_attrs))
      end

      it 'makes a successful request' do
        provider.class.stubs(:openstack)
                      .with('project', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'test', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","test","Test tenant",True
')
        response = provider.request('project', 'list', nil, resource_attrs[:auth], '--long')
        expect(response.first[:description]).to match /Test tenant/
      end
    end

    context 'with valid openrc file in parameters' do
      mock = "export OS_USERNAME='test'\nexport OS_PASSWORD='abc123'\nexport OS_TENANT_NAME='test'\nexport OS_AUTH_URL='http://127.0.0.1:5000/v2.0'"
      let(:resource_attrs) do
        {
          :name         => 'stubresource',
          :auth         => {
            'openrc' => '/root/openrc'
          }
        }
      end
      let(:provider) do
        Puppet::Provider::Openstack.new(type.new(resource_attrs))
      end

      it 'makes a successful request' do
        File.expects(:open).with('/root/openrc').returns(StringIO.new(mock))
        provider.class.stubs(:openstack)
                      .with('project', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'test', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","test","Test tenant",True
')
        response = provider.request('project', 'list', nil, resource_attrs[:auth], '--long')
        expect(response.first[:description]).to match /Test tenant/
      end
    end

    context 'with valid service token in parameters' do
      let(:resource_attrs) do
        {
          :name         => 'stubresource',
          :auth         => {
            'token' => 'secrettoken',
            'auth_url'      => 'http://127.0.0.1:5000/v2.0'
          }
        }
      end
      let(:provider) do
        Puppet::Provider::Openstack.new(type.new(resource_attrs))
      end

      it 'makes a successful request' do
        provider.class.stubs(:openstack)
                      .with('project', 'list', '--quiet', '--format', 'csv', [['--long', '--os-token', 'secrettoken', '--os-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name","Description","Enabled"
"1cb05cfed7c24279be884ba4f6520262","test","Test tenant",True
')
        response = provider.request('project', 'list', nil, resource_attrs[:auth], '--long')
        expect(response.first[:description]).to match /Test tenant/
      end

      it 'makes a successful show request' do
        provider.class.stubs(:openstack)
                      .with('project', 'show', '--format', 'shell', [['test', '--os-token', 'secrettoken', '--os-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('ID="1cb05cfed7c24279be884ba4f6520262"
Name="test"
Description="Test Tenant"
Enabled="True"
')
        response = provider.request('project', 'show', 'test', resource_attrs[:auth])
        expect(response[:description]).to match /Test Tenant/
        expect(response[:id]).to match /1cb05cfed7c24279be884ba4f6520262/
        expect(response[:name]).to match /test/
        expect(response[:enabled]).to match /True/
      end

    end

    context 'with valid password credentials in environment variables' do
      it_behaves_like 'authenticating with environment variables' do
        let(:resource_attrs) do
          {
            :name => 'stubresource',
          }
        end
        let(:provider) do
          Puppet::Provider::Openstack.new(type.new(resource_attrs))
        end
      end
    end

    context 'with no valid credentials' do
      it_behaves_like 'it has no credentials' do
        let(:resource_attrs) do
          {
            :name => 'stubresource',
          }
        end
        let(:provider) do
          Puppet::Provider::Openstack.new(type.new(resource_attrs))
        end
      end
    end

    context 'it retries on connection errors' do
      let(:resource_attrs) do
        {
          :name         => 'stubresource',
          :auth         => {
            'username'    => 'test',
            'password'    => 'abc123',
            'tenant_name' => 'test',
            'auth_url'    => 'http://127.0.0.1:5000/v2.0',
          }
        }
      end
      let(:provider) do
        Puppet::Provider::Openstack.new(type.new(resource_attrs))
      end
      it 'retries' do
        provider.class.stubs(:openstack)
                      .with('project', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'test', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .raises(Puppet::ExecutionFailure, 'Unable to establish connection')
                      .then
                      .returns('')
        provider.class.expects(:sleep).with(2).returns(nil)
        provider.request('project', 'list', nil, resource_attrs[:auth], '--long')
      end
    end
  end


  describe '::request' do

    context 'with valid password credentials in environment variables' do
      it_behaves_like 'authenticating with environment variables' do
        let(:resource_attrs) do
          {
            :name => 'stubresource',
          }
        end
        let(:provider) do
          Puppet::Provider::Openstack.dup
        end
      end
    end

    context 'with no valid credentials' do
      it_behaves_like 'it has no credentials' do
        let(:provider) { Puppet::Provider::Openstack.dup }
      end
    end

  end

  describe 'parse_csv' do
    context 'with mixed stderr' do
      text = "ERROR: Testing\n\"field\",\"test\",1,2,3\n"
      csv = Puppet::Provider::Openstack.parse_csv(text)
      it 'should ignore non-CSV text at the beginning of the input' do
        expect(csv).to be_kind_of(Array)
        expect(csv[0]).to match_array(['field', 'test', '1', '2', '3'])
        expect(csv.size).to eq(1)
      end
    end

    context 'with \r\n line endings' do
      text = "ERROR: Testing\r\n\"field\",\"test\",1,2,3\r\n"
      csv = Puppet::Provider::Openstack.parse_csv(text)
      it 'ignore the carriage returns' do
        expect(csv).to be_kind_of(Array)
        expect(csv[0]).to match_array(['field', 'test', '1', '2', '3'])
        expect(csv.size).to eq(1)
      end
    end

    context 'with embedded newlines' do
      text = "ERROR: Testing\n\"field\",\"te\nst\",1,2,3\n"
      csv = Puppet::Provider::Openstack.parse_csv(text)
      it 'should parse correctly' do
        expect(csv).to be_kind_of(Array)
        expect(csv[0]).to match_array(['field', "te\nst", '1', '2', '3'])
        expect(csv.size).to eq(1)
      end
    end
  end

end
