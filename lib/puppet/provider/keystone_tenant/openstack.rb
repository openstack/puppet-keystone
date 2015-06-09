require 'puppet/provider/keystone'

Puppet::Type.type(:keystone_tenant).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc "Provider to manage keystone tenants/projects."

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def create
    properties = []
    if resource[:enabled] == :true
      properties << '--enable'
    elsif resource[:enabled] == :false
      properties << '--disable'
    end
    if resource[:description]
      properties << '--description'
      properties << resource[:description]
    end
    @instance = request('project', 'create', resource[:name], resource[:auth], properties)
  end

  def exists?
    ! instance(resource[:name]).empty?
  end

  def destroy
    request('project', 'delete', resource[:name], resource[:auth])
  end


  def enabled=(value)
    @property_flush[:enabled] = value
  end

  def enabled
    bool_to_sym(instance(resource[:name])[:enabled])
  end


  def description=(value)
    @property_flush[:description] = value
  end

  def description
    instance(resource[:name])[:description]
  end


  def id
    instance(resource[:name])[:id]
  end

  def self.instances
    list = request('project', 'list', nil, nil, '--long')
    list.collect do |project|
      new(
        :name        => project[:name],
        :ensure      => :present,
        :enabled     => project[:enabled].downcase.chomp == 'true' ? true : false,
        :description => project[:description],
        :id          => project[:id]
      )
    end
  end

  def instances
    instances = request('project', 'list', nil, resource[:auth], '--long')
    instances.collect do |project|
      {
        :name        => project[:name],
        :enabled     => project[:enabled].downcase.chomp == 'true' ? true : false,
        :description => project[:description],
        :id          => project[:id]
      }
    end
  end

  def instance(name)
    @instance ||= instances.select { |instance| instance[:name] == name }.first || {}
  end

  def flush
    options = []
    if @property_flush
      (options << '--enable') if @property_flush[:enabled] == :true
      (options << '--disable') if @property_flush[:enabled] == :false
      # There is a --description flag for the set command, but it does not work if the value is empty
      (options << '--property' << "description=#{resource[:description]}") if @property_flush[:description]
      request('project', 'set', resource[:name], resource[:auth], options) unless options.empty?
    end
  end

end
