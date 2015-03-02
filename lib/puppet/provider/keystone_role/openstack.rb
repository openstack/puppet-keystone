require 'puppet/provider/keystone'

Puppet::Type.type(:keystone_role).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc 'Provider for keystone roles.'

  def create
    properties = []
    @instance = request('role', 'create', resource[:name], resource[:auth], properties)
  end

  def exists?
    ! instance(resource[:name]).empty?
  end

  def destroy
    request('role', 'delete', resource[:name], resource[:auth])
  end

  def id
    instance(resource[:name])[:id]
  end

  def self.instances
    list = request('role', 'list', nil, nil)
    list.collect do |role|
      new(
        :name        => role[:name],
        :ensure      => :present,
        :id          => role[:id]
      )
    end
  end

  def instances
    instances = request('role', 'list', nil, resource[:auth])
    instances.collect do |role|
      {
        :name        => role[:name],
        :id          => role[:id]
      }
    end
  end

  def instance(name)
    @instance ||= instances.select { |instance| instance[:name] == name }.first || {}
  end

end
