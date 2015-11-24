require 'spec_helper'
require 'puppet'
require 'puppet/type/keystone_endpoint'

describe Puppet::Type.type(:keystone_endpoint) do

  describe 'region_one/endpoint_name::type_one' do
    include_examples 'parse title correctly',
      :name   => 'endpoint_name',
      :region => 'region_one',
      :type   => 'type_one'
  end

  describe 'new_endpoint_without_region::type' do
    include_examples 'croak on the required parameter',
      'Parameter region failed on Keystone_endpoint[new_endpoint_without_region]:'
  end

  describe '#autorequire' do
    let(:service_one) do
      Puppet::Type.type(:keystone_service).new(:title => 'service_one', :type => 'type_one')
    end

    let(:service_two) do
      Puppet::Type.type(:keystone_service).new(:title => 'service_one::type_two')
    end

    let(:service_three) do
      Puppet::Type.type(:keystone_service).new(:title => 'service_two::type_one')
    end

    context 'domain autorequire from title' do
      let(:endpoint) do
        Puppet::Type.type(:keystone_endpoint).new(:title => 'region_one/service_one::type_one')
      end
      describe 'should require the correct domain' do
        let(:resources) { [endpoint, service_one, service_two] }
        include_examples 'autorequire the correct resources'
      end
    end
    context 'domain autorequire from title without type (to be removed at Mitaka)' do
      let(:endpoint) do
        Puppet::Type.type(:keystone_endpoint).new(:title => 'region_one/service_one')
      end
      describe 'should require the correct domain' do
        let(:resources) { [endpoint, service_one, service_two] }
        include_examples 'autorequire the correct resources'
      end
    end
    context 'domain autorequire from title without type on fq service name (to be removed at Mitaka)' do
      let(:endpoint) do
        Puppet::Type.type(:keystone_endpoint).new(:title => 'region_one/service_two')
      end
      describe 'should require the correct domain' do
        let(:resources) { [endpoint, service_three, service_one] }
        include_examples 'autorequire the correct resources'
      end
    end
  end
end
