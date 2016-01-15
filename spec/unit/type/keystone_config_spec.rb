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
