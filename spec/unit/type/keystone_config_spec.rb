require 'spec_helper'
# this hack is required for now to ensure that the path is set up correctly
# to retrive the parent provider
$LOAD_PATH.push(
  File.join(
    File.dirname(__FILE__),
    '..',
    '..',
    'fixtures',
    'modules',
    'inifile',
    'lib')
)
require 'puppet'
require 'puppet/type/keystone_config'

describe 'Puppet::Type.type(:keystone_config)' do
  before :each do
    @keystone_config = Puppet::Type.type(:keystone_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

 it 'should require a name' do
    expect {
      Puppet::Type.type(:keystone_config).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not expect a name with whitespace' do
    expect {
      Puppet::Type.type(:keystone_config).new(:name => 'f oo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should fail when there is no section' do
    expect {
      Puppet::Type.type(:keystone_config).new(:name => 'foo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should not require a value when ensure is absent' do
    Puppet::Type.type(:keystone_config).new(:name => 'DEFAULT/foo', :ensure => :absent)
  end

  it 'should accept a valid value' do
    @keystone_config[:value] = 'bar'
    expect(@keystone_config[:value]).to eq('bar')
  end

  it 'should not accept a value with whitespace' do
    @keystone_config[:value] = 'b ar'
    expect(@keystone_config[:value]).to eq('b ar')
  end

  it 'should accept valid ensure values' do
    @keystone_config[:ensure] = :present
    expect(@keystone_config[:ensure]).to eq(:present)
    @keystone_config[:ensure] = :absent
    expect(@keystone_config[:ensure]).to eq(:absent)
  end

  it 'should not accept invalid ensure values' do
    expect {
      @keystone_config[:ensure] = :latest
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'keystone')
    catalog.add_resource package, @keystone_config
    dependency = @keystone_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@keystone_config)
    expect(dependency[0].source).to eq(package)
  end

end
