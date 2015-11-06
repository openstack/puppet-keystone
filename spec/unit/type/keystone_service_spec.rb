require 'spec_helper'
require 'puppet'
require 'puppet/type/keystone_service'

describe Puppet::Type.type(:keystone_service) do

  let(:project) do
    Puppet::Type.type(:keystone_service).new(
      :id   => 'blah',
      :name => 'foo',
      :type => 'foo-type'
    )
  end

  include_examples 'croak on read-only parameter',
    :title => 'service::type', :id => '12345',
    :_prefix => 'Parameter id failed on Keystone_service[service::type]:'

  describe 'service::type' do
    include_examples 'parse title correctly', :name => 'service', :type => 'type'
  end

  describe 'new_service_without_type' do
    include_examples 'croak on the required parameter',
      'Parameter type failed on Keystone_service[new_service_without_type]:'
  end

  describe 'new_service_with_type_as_parameter' do
    include_examples 'succeed with the required parameters', :type => 'type'
  end

end
