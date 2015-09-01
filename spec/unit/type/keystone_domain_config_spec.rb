require 'puppet'
require 'puppet/type/keystone_domain_config'

describe 'Puppet::Type.type(:keystone_domain_config)' do
  let(:keystone_domain_config) do
    Puppet::Type.type(:keystone_domain_config)
      .new(:name => 'service::DEFAULT/foo', :value => 'bar')
  end

  let(:catalog) { Puppet::Resource::Catalog.new }

  it 'should autorequire the directory holding the configurations' do
    directory = Puppet::Type.type(:file).new(
      :name   => '/etc/keystone/domains',
      :ensure => 'directory'
    )
    catalog.add_resource directory, keystone_domain_config
    dependency = keystone_domain_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(keystone_domain_config)
    expect(dependency[0].source).to eq(directory)
  end

  it 'should autorequire the keystone_config identity/domain_config_dir' do
    keystone_config = Puppet::Type.type(:keystone_config).new(
      :name   => 'identity/domain_config_dir',
      :value  => '/tmp'
    )
    catalog.add_resource keystone_config, keystone_domain_config
    dependency = keystone_domain_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(keystone_domain_config)
    expect(dependency[0].source).to eq(keystone_config)
  end
end
