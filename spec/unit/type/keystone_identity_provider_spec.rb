require 'spec_helper'
require 'puppet'
require 'puppet/type/keystone_identity_provider'

describe Puppet::Type.type(:keystone_identity_provider) do

  let(:service_provider) do
    Puppet::Type.type(:keystone_identity_provider).new(
      :name => 'foo',
      :remote_ids => ['remoteid_idp1', 'http://remoteid_idp2/saml/meta', 3],
      :description => 'Original description'
    )
  end

  describe '#remote-ids property' do
    it 'should be in sync with unsorted array of remote-ids' do
      remote_ids = service_provider.parameter('remote_ids')
      expect(remote_ids.insync?(
        ['http://remoteid_idp2/saml/meta', 3, 'remoteid_idp1'])).to be_truthy
    end

    it 'should not allow an id with space in it' do
      expect do
        @service_provider = Puppet::Type.type(:keystone_identity_provider).new(
          :name => 'foo',
          :remote_ids => ['remote id one']
        )
      end.to raise_error(Puppet::ResourceError,
                         /Remote id cannot have space in it/)
    end

    it 'should not allow an id with double quote in it' do
      expect do
        @service_provider = Puppet::Type.type(:keystone_identity_provider).new(
          :name => 'foo',
          :remote_ids => ['http://remoteone?id="foo"']
        )
      end.to raise_error(Puppet::ResourceError,
        /double quote: http:\/\/remoteone\?id="foo" at position 20/)
    end
  end

  describe '#description property' do
    it "Can't be modified" do
      description = service_provider.parameter('description')
      expect do
        description.insync?('New description')
      end.to raise_error(
        Puppet::Error,
        /^The description cannot be changed from Original description to New description$/
      )
    end
  end

  describe '#remote_id_file' do
    context 'remote_id_file and remote_ids are both set' do
      it 'must fail' do
        expect do
          @service_provider = Puppet::Type.type(:keystone_identity_provider).new(
            :name => 'foo',
            :remote_ids => ['remoteone'],
            :remote_id_file => '/tmp/remote_ids'
          )
        end.to raise_error(Puppet::ResourceError,
          /Cannot have both remote_ids and remote_id_file/)
      end
    end
    context 'remote_id_file is not an absolute path' do
      it 'must raise a error' do
        expect do
          @service_provider = Puppet::Type.type(:keystone_identity_provider).new(
            :name => 'foo',
            :remote_id_file => 'tmp/remote_ids'
          )
        end.to raise_error(Puppet::ResourceError,
          /You must specify an absolute path name not 'tmp\/remote_ids'/)
      end
    end

    context 'remote_id_file is in sync relative to the ids in the file' do
      let(:service_provider) do
        Puppet::Type.type(:keystone_identity_provider).new(
          :name => 'foo',
          :remote_id_file => '/tmp/remote_ids'
        )
      end
      it 'must be in sync' do
        File.expects(:readlines).with('/tmp/remote_ids').once
          .returns(['  remoteids', '', 'http://secondids  ', '   	'])
        remote_id_file = service_provider.parameter('remote_id_file')
        expect(remote_id_file.insync?(
          ['http://secondids', 'remoteids'])).to be_truthy
      end
    end
  end

  describe '#autorequire' do
    let(:file_good) do
      Puppet::Type.type(:file).new(
        :name   => '/tmp/remote-ids',
        :ensure => :present
      )
    end
    let(:file_bad) do
      Puppet::Type.type(:file).new(
        :name   => '/tmp/another-file',
        :ensure => :present
      )
    end
    let(:service_provider) do
      Puppet::Type.type(:keystone_identity_provider).new(
        :name            => 'foo',
        :remote_id_file  => '/tmp/remote-ids',
        :description     => 'Original description'
      )
    end

    describe 'should autorequire the correct file' do
      let(:resources) { [service_provider, file_good, file_bad] }
      include_examples 'autorequire the correct resources'
    end
  end
end
