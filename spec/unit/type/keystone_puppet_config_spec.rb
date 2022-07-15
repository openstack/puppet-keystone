require 'spec_helper'
require 'puppet'
require 'puppet/type/keystone_puppet_config'

describe 'Puppet::Type.type(:keystone_puppet_config)' do
  before :each do
    @keystone_puppet_config = Puppet::Type.type(:keystone_puppet_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:keystone_puppet_config).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not expect a name with whitespace' do
    expect {
      Puppet::Type.type(:keystone_puppet_config).new(:name => 'f oo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should fail when there is no section' do
    expect {
      Puppet::Type.type(:keystone_puppet_config).new(:name => 'foo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should not require a value when ensure is absent' do
    Puppet::Type.type(:keystone_puppet_config).new(:name => 'DEFAULT/foo', :ensure => :absent)
  end

  it 'should accept a valid value' do
    @keystone_puppet_config[:value] = 'bar'
    expect(@keystone_puppet_config[:value]).to eq('bar')
  end

  it 'should accept a value with whitespace' do
    @keystone_puppet_config[:value] = 'b ar'
    expect(@keystone_puppet_config[:value]).to eq('b ar')
  end

  it 'should accept valid ensure values' do
    @keystone_puppet_config[:ensure] = :present
    expect(@keystone_puppet_config[:ensure]).to eq(:present)
    @keystone_puppet_config[:ensure] = :absent
    expect(@keystone_puppet_config[:ensure]).to eq(:absent)
  end

  it 'should not accept invalid ensure values' do
    expect {
      @keystone_puppet_config[:ensure] = :latest
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

  it 'should autorequire the config file' do
    catalog = Puppet::Resource::Catalog.new
    config_file = Puppet::Type.type(:file).new(:name => '/etc/keystone/puppet.conf')
    catalog.add_resource config_file, @keystone_puppet_config
    dependency = @keystone_puppet_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@keystone_puppet_config)
    expect(dependency[0].source).to eq(config_file)
  end
end
