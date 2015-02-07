require 'puppet/provider/keystone'

Puppet::Type.type(:keystone_service).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc "Provider to manage keystone services."

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def create
    properties = []
    if resource[:description]
      properties << '--description'
      properties << resource[:description]
    end
    if resource[:type]
      properties << '--type'
      properties << resource[:type]
    end
    @instance = request('service', 'create', resource[:name], resource[:auth], properties)
  end

  def exists?
    ! instance(resource[:name]).empty?
  end

  def destroy
    request('service', 'delete', resource[:name], resource[:auth])
  end


  def description=(value)
    raise(Puppet::Error, "Updating the service is not currently supported.")
  end

  def description
    instance(resource[:name])[:description]
  end


  def type=(value)
    raise(Puppet::Error, "Updating the service is not currently supported.")
  end

  def type
    instance(resource[:name])[:type]
  end


  def id
    instance(resource[:name])[:id]
  end

  def self.instances
    list = request('service', 'list', nil, nil, '--long')
    list.collect do |service|
      new(
        :name        => service[:name],
        :ensure      => :present,
        :type        => service[:type],
        :description => service[:description],
        :id          => service[:id]
      )
    end
  end

  def instances
    instances = request('service', 'list', nil, resource[:auth], '--long')
    instances.collect do |service|
      {
        :name        => service[:name],
        :type        => service[:type],
        :description => service[:description],
        :id          => service[:id]
      }
    end
  end

  def instance(name)
    @instance ||= instances.select { |instance| instance[:name] == name }.first || {}
  end

  def flush
    options = []
    if @property_flush
      # There is a --description flag for the set command, but it does not work if the value is empty
      (options << '--property' << "type=#{resource[:type]}") if @property_flush[:type]
      (options << '--property' << "description=#{resource[:description]}") if @property_flush[:description]
      request('project', 'set', resource[:name], resource[:auth], options) unless options.empty?
    end
  end

end
