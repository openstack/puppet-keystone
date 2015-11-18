require 'spec_helper'
require 'puppet'
require 'puppet/type/keystone_tenant'

describe Puppet::Type.type(:keystone_tenant) do

  let(:project) do
    Puppet::Type.type(:keystone_tenant).new(
      :id     => 'blah',
      :name   => 'project',
      :domain => 'domain_project'
    )
  end

  it 'should not accept id property' do
    expect { project }.to raise_error(Puppet::Error,
                                      /This is a read only property/)
  end

  describe 'name::domain' do
    include_examples 'parse title correctly',
      :name => 'name',
      :domain => 'domain'
  end
  describe 'name' do
    include_examples 'parse title correctly',
      :name => 'name', :domain => 'Default'
  end
  describe 'name::domain::extra' do
    include_examples 'croak on the title'
  end

  describe '#autorequire' do
    let(:domain_good) do
      Puppet::Type.type(:keystone_domain).new(:title => 'domain_project')
    end

    let(:domain_bad) do
      Puppet::Type.type(:keystone_domain).new(:title => 'another_domain')
    end

    context 'domain autorequire from title' do
      let(:project) do
        Puppet::Type.type(:keystone_tenant).new(:title  => 'tenant::domain_project')
      end
      describe 'should require the correct domain' do
        let(:resources) { [project, domain_good, domain_bad] }
        include_examples 'autorequire the correct resources'
      end
    end
    context 'domain autorequire from parameter' do
      let(:project) do
        Puppet::Type.type(:keystone_tenant).new(:title  => 'tenant',
                                                :domain => 'domain_project')
      end
      describe 'should require the correct domain' do
        let(:resources) { [project, domain_good, domain_bad] }
        include_examples 'autorequire the correct resources'
      end
    end
  end
end
