require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_identity_provider/openstack'

describe Puppet::Type.type(:keystone_identity_provider).provider(:openstack) do
  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000/v3'
  end

  let(:id_provider_attrs) do
    {
      :name         => 'idp_one',
      :enabled      => true,
      :description  => 'Nice id provider',
      :remote_ids   => ['entityid_idp1', 'http://entityid_idp2/saml/meta', 3],
      :ensure       => :present
    }
  end

  let(:resource) do
    Puppet::Type::Keystone_identity_provider.new(id_provider_attrs)
  end

  let(:provider) { described_class.new(resource) }

  before(:example) { set_env }
  describe '#create success' do
    it 'creates an identity provider' do
      described_class.expects(:openstack)
        .with(
              'identity provider', 'create',
              '--format', 'shell', [
                '--remote-id', 'entityid_idp1',
                '--remote-id', 'http://entityid_idp2/saml/meta',
                '--remote-id', '3',
                '--enable',
                '--description', 'Nice id provider',
                'idp_one'
              ]
             )
        .once
        .returns(
        <<-EOR
description="Nice id provider"
enabled="True"
id="idp_one"
remote_ids="[u'entityid_idp1', u'http://entityid_idp2/saml/meta', u'3']"
EOR
      )
      provider.create
      expect(provider.exists?).to be_truthy
    end
  end
  describe '#create failure' do
    it 'fails with an helpfull message when hitting remote-id duplicate.' do
      described_class.expects(:openstack)
        .with(
              'identity provider', 'create',
              '--format', 'shell', [
                '--remote-id', 'entityid_idp1',
                '--remote-id', 'http://entityid_idp2/saml/meta',
                '--remote-id', '3',
                '--enable',
                '--description', 'Nice id provider',
                'idp_one'
              ]
             )
        .once
        .raises(Puppet::ExecutionFailure,
                'openstack Conflict occurred attempting to' \
                  ' store identity_provider')
      expect { provider.create }
        .to raise_error(Puppet::Error::OpenstackDuplicateRemoteId)
    end
  end

  describe '#create with a remote-id-file' do
    let(:id_provider_attrs) do
      {
        :name           => 'idp_one',
        :enabled        => true,
        :description    => 'Nice id provider',
        :remote_id_file => '/tmp/remoteids',
        :ensure         => :present
      }
    end
    it 'create a resource whit remote id in a file' do
      described_class.expects(:openstack)
        .with(
              'identity provider', 'create',
              '--format', 'shell', [
                '--remote-id-file', '/tmp/remoteids',
                '--enable',
                '--description', 'Nice id provider',
                'idp_one'
              ]
             )
        .once
        .returns(
        <<-EOR
description="Nice id provider"
enabled="True"
id="idp_one"
remote_ids="[u'entityid_idp1', u'http://entityid_idp2/saml/meta', u'3']"
EOR
      )
      provider.create
      expect(provider.exists?).to be_truthy

    end
  end

  describe '#destroy' do
    it 'destroy an identity provider' do
      provider.instance_variable_get('@property_hash')[:id] = 'idp_one'
      described_class.expects(:openstack)
        .with(
              'identity provider', 'delete', 'idp_one'
             )
      provider.destroy
      expect(provider.exists?).to be_falsy
    end
  end

  describe '#instances' do
    it 'finds every identity provider' do
      described_class.expects(:openstack)
        .with(
              'identity provider', 'list',
              '--quiet', '--format', 'csv', []
             )
        .once
        .returns(
        <<-EOR
"ID","Enabled","Description"
"idp_one",True,""
"idp_two",False,"Idp two description"
EOR
      )
      described_class.expects(:openstack)
        .with(
              'identity provider', 'show',
              '--format', 'shell', 'idp_one'
             )
        .once
        .returns(
        <<-EOR
description="None"
enabled="True"
id="idp_one"
remote_ids="[u'entityid_idp1', u'http://entityid_idp2/saml/meta', u'3']"
EOR
      )
      described_class.expects(:openstack)
        .with(
              'identity provider', 'show',
              '--format', 'shell', 'idp_two'
             )
        .once
        .returns(
        <<-EOR
description="Idp two description"
enabled="False"
id="idp_two"
remote_ids="[]"
EOR
      )
      described_class.expects(:openstack)
        .with('--version', '', [])
        .twice
        .returns("openstack 1.7.0\n")
      instances =
        Puppet::Type::Keystone_identity_provider::ProviderOpenstack.instances
      expect(instances.count).to eq(2)
      expect(instances[0].description).to be_empty
      expect(instances[1].enabled).to be_falsy
    end
  end

  describe '#update' do
    context 'remote_ids' do
      it 'changes the remote_ids' do
        provider.expects(:id).returns('1234')
        described_class.expects(:openstack)
          .with(
                'identity provider', 'set',
                [
                  '--remote-id', 'entityid_idp1',
                  '--remote-id', 'http://entityid_idp2/saml/meta',
                  '1234'
                ]
               )
          .once
        provider.remote_ids = ['entityid_idp1', 'http://entityid_idp2/saml/meta']
      end
    end
    context 'with remote_id_file' do
      it 'changes the remote_id_file' do
        provider.expects(:id).returns('1234')
        described_class.expects(:openstack)
          .with(
                'identity provider', 'set',
                ['--remote-id-file', '/tmp/new_file', '1234']
               )
          .once
        provider.remote_id_file = '/tmp/new_file'
      end
    end
    context 'enabled' do
      it 'changes the enable to true' do
        provider.expects(:id).returns('1234')
        described_class.expects(:openstack)
          .with(
                'identity provider', 'set',
                ['--enable', '1234']
               )
          .once
        provider.enabled = :true
      end
      it 'changes the enable to false' do
        provider.expects(:id).returns('1234')
        described_class.expects(:openstack)
          .with(
                'identity provider', 'set',
                ['--disable', '1234']
               )
          .once
        provider.enabled = :false
      end
    end
  end

  describe '#prefetch' do
    let(:resources_catalog) { { 'idp_one' => provider } }
    let(:found_resource) do
      existing = described_class.new
      existing.instance_variable_set('@property_hash',
        :name        => 'idp_one',
        :id          => 'idp_one',
        :description => '',
        :enabled     => true,
        :remote_ids  => [
          'entityid_idp1',
          'http://entityid_idp2/saml/meta',
          '3'],
        :ensure      => :present
      )
      existing
    end
    it 'fill the resource with the right provider' do
      described_class.expects(:instances)
        .once
        .returns([found_resource])
      expect(resources_catalog['idp_one'].provider).to be_absent
      described_class.prefetch(resources_catalog)
      expect(resources_catalog['idp_one'].provider).not_to be_absent
    end
  end

  describe '#clean_remote_ids' do
    context 'before python-openstackclient/+bug/1478995' do
      let(:edge_cases_remote_ids) do
        {
          %q|[u'http://remoteid?id=idp_one&name=ldap', u"http://remoteid_2?id='idp'"]| =>
            ['http://remoteid?id=idp_one&name=ldap', "http://remoteid_2?id='idp'"],
          %q|[u'http://remoteid?id=idp_one&name=ldap']| => ['http://remoteid?id=idp_one&name=ldap']
        }
      end
      it 'should handle tricky cases' do
        described_class.expects(:openstack)
          .with('--version', '', [])
          .twice
          .returns("openstack 1.7.0\n")
        edge_cases_remote_ids.each do |edge_case, solution|
          expect(described_class.clean_remote_ids(edge_case)).to eq(solution)
        end
      end
    end
    context 'after python-openstackclient/+bug/1478995' do
      let(:remote_ids) do
        [
          "http://remoteid?id=idp_one&name=ldap, http://remoteid_2?id='idp'",
            ['http://remoteid?id=idp_one&name=ldap', "http://remoteid_2?id='idp'"]
        ]
      end
      it 'should handle the new output' do
        described_class.expects(:openstack)
          .with('--version', '', [])
          .once
          .returns("openstack 1.9.0\n")
        expect(described_class.clean_remote_ids(remote_ids[0])).to eq(remote_ids[1])
      end
    end
  end
end
