require 'puppet/provider/keystone'

Puppet::Type.type(:keystone_endpoint).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc "Provider to manage keystone endpoints."

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def create
    region, name = resource[:name].split('/')
    ids = []
    [:admin_url, :internal_url, :public_url].each do |scope|
      if resource[scope]
        ids << endpoint_create(name, region,  scope.to_s.sub(/_url$/,''),
          resource[scope])[:id]
      end
    end
    @property_hash[:id] = ids.join(',')
    @property_hash[:ensure] = :present
  end

  def destroy
    ids = @property_hash[:id].split(',')
    ids.each do |id|
      self.class.request('endpoint', 'delete', id)
    end
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  mk_resource_methods

  def public_url=(value)
    @property_flush[:public_url] = value
  end

  def internal_url=(value)
    @property_flush[:internal_url] = value
  end

  def admin_url=(value)
    @property_flush[:admin_url] = value
  end

  def region=(value)
    raise(Puppet::Error, "Updating the endpoint's region is not currently supported.")
  end

  def self.instances
    names=[]
    list=[]
    endpoints = request('endpoint', 'list')
    endpoints.each do |current|
      name = "#{current[:region]}/#{current[:service_name]}"
      unless names.include?(name)
        names << name
        endpoint = { :name => name, current[:interface].to_sym => current }
        endpoints.each do |ep_osc|
          if (ep_osc[:id] != current[:id]) && (ep_osc[:service_name] == current[:service_name])
            endpoint.merge!(ep_osc[:interface].to_sym => ep_osc)
          end
        end
        list << endpoint
      end
    end
    list.collect do |endpoint|
      new(
        :name         => endpoint[:name],
        :ensure       => :present,
        :id           => "#{endpoint[:admin][:id]},#{endpoint[:internal][:id]},#{endpoint[:public][:id]}",
        :region       => endpoint[:admin][:region],
        :admin_url    => endpoint[:admin][:url],
        :internal_url => endpoint[:internal][:url],
        :public_url   => endpoint[:public][:url]
      )
    end
  end

  def self.prefetch(resources)
    endpoints = instances
    resources.keys.each do |name|
       if provider = endpoints.find{ |endpoint| endpoint.name == name }
        resources[name].provider = provider
      end
    end
  end

  def flush
    if @property_flush && @property_hash[:id]
      ids = @property_hash[:id].split(',')
      if @property_flush[:admin_url]
        self.class.request('endpoint', 'set', [ids[0], "--url=#{resource[:admin_url]}"])
      end
      if @property_flush[:internal_url]
        self.class.request('endpoint', 'set', [ids[1], "--url=#{resource[:internal_url]}"])
      end
      if @property_flush[:public_url]
        self.class.request('endpoint', 'set', [ids[2], "--url=#{resource[:public_url]}"])
      end
    end
    @property_hash = resource.to_hash
  end

  private

  def endpoint_create(name, region, interface, url)
    properties = [name, interface, url, '--region', region]
    self.class.request('endpoint', 'create', properties)
  end
end
