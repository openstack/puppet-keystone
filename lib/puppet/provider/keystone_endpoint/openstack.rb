require 'puppet/provider/keystone'

Puppet::Type.type(:keystone_endpoint).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc "Provider to manage keystone endpoints."

  include PuppetX::Keystone::CompositeNamevar::Helpers

  @endpoints     = nil
  @services      = nil
  @credentials   = Puppet::Provider::Openstack::CredentialsV3.new
  @do_not_manage = false

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.do_not_manage
    @do_not_manage
  end

  def self.do_not_manage=(value)
    @do_not_manage = value
  end

  def create
    if self.class.do_not_manage
      fail("Not managing Keystone_endpoint[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    # Reset the cache.
    self.class.services = nil
    name   = resource[:name]
    region = resource[:region]
    type   = resource[:type]
    type   = self.class.type_from_service(name) unless set?(:type)
    @property_hash[:type] = type
    services = self.class.services.find_all { |s| s[:name] == name }
    service = services.find { |s| s[:type] == type }

    if service.nil? && services.count == 1
      # For backward comptatibility, match the service by name only.
      name = services[0][:id]
    else
      # Math the service by id.
      name = service[:id] if service
    end
    ids = []

    created = false
    [:admin_url, :internal_url, :public_url].each do |scope|
      if resource[scope]
        created = true
        ids << endpoint_create(name, region,  scope.to_s.sub(/_url$/, ''),
                               resource[scope])[:id]
      end
    end
    if created
      @property_hash[:id] = ids.join(',')
      @property_hash[:ensure] = :present
    else
      warning('Specifying a keystone_endpoint without an ' \
              'admin_url/public_url/internal_url ' \
              "won't create the endpoint at all, despite what Puppet is saying.")
      @property_hash[:ensure] = :absent
    end
  end

  def destroy
    if self.class.do_not_manage
      fail("Not managing Keystone_endpoint[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
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
    if self.class.do_not_manage
      fail("Not managing Keystone_endpoint[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    @property_flush[:public_url] = value
  end

  def internal_url=(value)
    if self.class.do_not_manage
      fail("Not managing Keystone_endpoint[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    @property_flush[:internal_url] = value
  end

  def admin_url=(value)
    if self.class.do_not_manage
      fail("Not managing Keystone_endpoint[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    @property_flush[:admin_url] = value
  end

  def region=(_)
    fail(Puppet::Error, "Updating the endpoint's region is not currently supported.")
  end

  def self.instances
    names = []
    list = []
    endpoints.each do |current|
      name = transform_name(current[:region], current[:service_name], current[:service_type])
      unless names.include?(name)
        names << name
        endpoint = { :name => name, current[:interface].to_sym => current }
        endpoints.each do |ep_osc|
          if (ep_osc[:id] != current[:id]) &&
            (ep_osc[:service_name] == current[:service_name]) &&
            (ep_osc[:service_type] == current[:service_type]) &&
            (ep_osc[:region] == current[:region])
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
    prefetch_composite(resources) do |sorted_namevars|
      name   = sorted_namevars[0]
      region = sorted_namevars[1]
      type   = sorted_namevars[2]
      transform_name(region, name, type)
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

  private

  def self.endpoints
    return @endpoints unless @endpoints.nil?
    prev_do_not_manage = self.do_not_manage
    self.do_not_manage = true
    @endpoints = request('endpoint', 'list')
    self.do_not_manage = prev_do_not_manage
    @endpoints
  end

  def self.endpoints=(value)
    @endpoints = value
  end

  def self.services
    return @services unless @services.nil?
    prev_do_not_manage = self.do_not_manage
    self.do_not_manage = true
    @services = request('service', 'list')
    self.do_not_manage = prev_do_not_manage
    @services
  end

  def self.services=(value)
    @services = value
  end

  def self.endpoint_from_region_name(region, name)
    endpoints.find_all { |e| e[:region] == region && e[:service_name] == name }
      .map { |e| e[:service_type] }.uniq
  end

  def self.type_from_service(name)
    types = services.find_all { |s| s[:name] == name }.map { |e| e[:type] }.uniq
    if types.count == 1
      types[0]
    else
      # We don't fail here as it can happen during a ensure => absent.
      PuppetX::Keystone::CompositeNamevar::Unset
    end
  end

  def self.service_type(services, region, name)
    nbr_of_services = services.count
    err_msg         = ["endpoint matching #{region}/#{name}:"]
    type            = nil

    case
    when nbr_of_services == 1
      type = services[0]
    when nbr_of_services > 1
      err_msg += [endpoint_from_region_name(region, name).join(' ')]
    when nbr_of_services < 1
      # Then we try to get the type by service name.
      type = type_from_service(name)
    end

    if !type.nil?
      type
    else
      fail(Puppet::Error, 'Cannot get the correct endpoint type: ' \
           "#{err_msg.join(' ')}")
    end
  end

  def self.transform_name(region, name, type)
    if type == PuppetX::Keystone::CompositeNamevar::Unset
      type = service_type(endpoint_from_region_name(region, name), region, name)
    end
    if type == PuppetX::Keystone::CompositeNamevar::Unset
      Puppet.debug("Could not find the type for endpoint #{region}/#{name}")
      "#{region}/#{name}"
    else
      "#{region}/#{name}::#{type}"
    end
  end
end
