require 'puppet/provider/keystone'

Puppet::Type.type(:keystone_endpoint).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc "Provider to manage keystone endpoints."

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def create
    properties = []
    # The region property is just ignored. We should fix this in kilo.
    region, name = resource[:name].split('/')
    properties << '--region'
    properties << region
    if resource[:public_url]
      properties << '--publicurl'
      properties << resource[:public_url]
    end
    if resource[:internal_url]
      properties << '--internalurl'
      properties << resource[:internal_url]
    end
    if resource[:admin_url]
      properties << '--adminurl'
      properties << resource[:admin_url]
    end
    @instance = request('endpoint', 'create', name, resource[:auth], properties)
  end

  def exists?
    ! instance(resource[:name]).empty?
  end

  def destroy
    id = instance(resource[:name])[:id]
    request('endpoint', 'delete', id, resource[:auth])
  end


  def region
    instance(resource[:name])[:region]
  end


  def public_url=(value)
    @property_flush[:public_url] = value
  end

  def public_url
    instance(resource[:name])[:public_url]
  end


  def internal_url=(value)
    @property_flush[:internal_url] = value
  end

  def internal_url
    instance(resource[:name])[:internal_url]
  end


  def admin_url=(value)
    @property_flush[:admin_url] = value
  end

  def admin_url
    instance(resource[:name])[:admin_url]
  end

  def id
    instance(resource[:name])[:id]
  end

  def self.instances
    list = request('endpoint', 'list', nil, nil, '--long')
    list.collect do |endpoint|
      new(
        :name         => "#{endpoint[:region]}/#{endpoint[:service_name]}",
        :ensure       => :present,
        :id           => endpoint[:id],
        :region       => endpoint[:region],
        :public_url   => endpoint[:publicurl],
        :internal_url => endpoint[:internalurl],
        :admin_url    => endpoint[:adminurl]
      )
    end
  end

  def instances
    instances = request('endpoint', 'list', nil, resource[:auth], '--long')
    instances.collect do |endpoint|
      {
        :name         => "#{endpoint[:region]}/#{endpoint[:service_name]}",
        :id           => endpoint[:id],
        :region       => endpoint[:region],
        :public_url   => endpoint[:publicurl],
        :internal_url => endpoint[:internalurl],
        :admin_url    => endpoint[:adminurl]
      }
    end
  end

  def instance(name)
    @instance ||= instances.select { |instance| instance[:name] == name }.first || {}
  end

  def flush
    if  ! @property_flush.empty?
      destroy
      create
      @property_flush.clear
    end
  end

end
