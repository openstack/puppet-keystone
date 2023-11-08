require 'spec_helper'
require 'puppet'
require 'puppet/type/keystone_implied_role'

describe Puppet::Type.type(:keystone_implied_role) do

  describe 'role@implied_role' do
    include_examples 'parse title correctly',
      :role         => 'role',
      :implied_role => 'implied_role'
  end

  describe '#autorequire' do
    let(:child) do
      Puppet::Type.type(:keystone_role).new(:title => 'child')
    end

    let(:parent) do
      Puppet::Type.type(:keystone_role).new(:title => 'parent')
    end

    let(:another) do
      Puppet::Type.type(:keystone_role).new(:title => 'another')
    end

    context 'role autorequire from title' do
      let(:implied_role) do
        Puppet::Type.type(:keystone_implied_role).new(:title  => 'child@parent')
      end
      describe 'should require the correct domain' do
        let(:resources) { [implied_role, child, parent, another] }
        include_examples 'autorequire the correct resources'
      end
    end
  end
end
