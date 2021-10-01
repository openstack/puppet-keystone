Puppet::Type.type(:keystone_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def self.file_path
    '/etc/keystone/keystone.conf'
  end

end
