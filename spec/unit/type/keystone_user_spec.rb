require 'spec_helper'
require 'puppet'
require 'puppet/type/keystone_user'

describe Puppet::Type.type(:keystone_user) do

  describe 'name::domain' do
    include_examples 'parse title correctly',
      :name => 'name', :domain => 'domain'
  end
  describe 'name' do
    include_examples 'parse title correctly',
      :name => 'name', :domain => 'Default'
  end
  describe 'name::domain::foo' do
    include_examples 'croak on the title'
  end

  describe '#autorequire' do
    let(:domain_good) do
      Puppet::Type.type(:keystone_domain).new(:title => 'domain_user')
    end

    let(:domain_bad) do
      Puppet::Type.type(:keystone_domain).new(:title => 'another_domain')
    end

    context 'domain autorequire from title' do
      let(:user) do
        Puppet::Type.type(:keystone_user).new(:title  => 'foo::domain_user')
      end
      describe 'should require the correct domain' do
        let(:resources) { [user, domain_good, domain_bad] }
        include_examples 'autorequire the correct resources'
      end
    end
    context 'domain autorequire from parameter' do
      let(:user) do
        Puppet::Type.type(:keystone_user).new(
          :title  => 'foo',
          :domain => 'domain_user'
        )
      end
      describe 'should require the correct domain' do
        let(:resources) { [user, domain_good, domain_bad] }
        include_examples 'autorequire the correct resources'
      end
    end
  end
end
