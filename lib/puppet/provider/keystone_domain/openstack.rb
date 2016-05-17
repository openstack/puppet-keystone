require File.join(File.dirname(__FILE__), '..','..','..', 'puppet/provider/keystone')
require 'puppet/util/inifile'

Puppet::Type.type(:keystone_domain).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc 'Provider that manages keystone domains'

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

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
      fail("Not managing Keystone_domain[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    properties = [resource[:name]]
    if resource[:enabled] == :true
      properties << '--enable'
    elsif resource[:enabled] == :false
      properties << '--disable'
    end
    if resource[:description]
      properties << '--description'
      properties << resource[:description]
    end
    @property_hash = self.class.request('domain', 'create', properties)
    @property_hash[:is_default] = sym_to_bool(resource[:is_default])
    @property_hash[:ensure] = :present
    ensure_default_domain(true)
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    if self.class.do_not_manage
      fail("Not managing Keystone_domain[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    # have to disable first - Keystone does not allow you to delete an
    # enabled domain
    self.class.request('domain', 'set', [resource[:name], '--disable'])
    self.class.request('domain', 'delete', resource[:name])
    @property_hash[:ensure] = :absent
    ensure_default_domain(false, true)
    @property_hash.clear
  end

  mk_resource_methods

  def enabled=(value)
    @property_flush[:enabled] = value
  end

  def enabled
    bool_to_sym(@property_hash[:enabled])
  end

  def description=(value)
    if self.class.do_not_manage
      fail("Not managing Keystone_domain[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    @property_flush[:description] = value
  end

  def is_default
    bool_to_sym(@property_hash[:is_default])
  end

  def is_default=(value)
    if self.class.do_not_manage
      fail("Not managing Keystone_domain[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    @property_flush[:is_default] = value
  end

  def ensure_default_domain(create, destroy=false, value=nil)
    if self.class.do_not_manage
      fail("Not managing Keystone_domain[#{@resource[:name]}] due to earlier Keystone API failures.")
    end
    curid = self.class.default_domain_id
    default = (is_default == :true)
    entry = keystone_conf_default_domain_id_entry(id)
    if (default && create) || (!default && (value == :true))
      # new default domain, or making existing domain the default domain
      if curid != id
        entry.create
      end
    elsif (default && destroy) || (default && (value == :false))
      # removing default domain, or making this domain not the default
      if curid == id
        entry.destroy
      end
    end
    self.class.default_domain_id = id
  end

  def self.instances
    self.do_not_manage = true
    list = request('domain', 'list').collect do |domain|
      new(
        :name        => domain[:name],
        :ensure      => :present,
        :enabled     => domain[:enabled].downcase.chomp == 'true' ? true : false,
        :description => domain[:description],
        :id          => domain[:id],
        :is_default  => domain[:id] == default_domain_id
      )
    end
    self.do_not_manage = false
    list
  end

  def self.prefetch(resources)
    domains = instances
    resources.keys.each do |name|
      if provider = domains.find { |domain| domain.name == name }
        resources[name].provider = provider
      end
    end
  end

  def flush
    options = []
    if @property_flush && !@property_flush.empty?
      options << '--enable' if @property_flush[:enabled] == :true
      options << '--disable' if @property_flush[:enabled] == :false
      if @property_flush[:description]
        options << '--description' << resource[:description]
      end
      self.class.request('domain', 'set', [resource[:name]] + options) unless options.empty?
      if @property_flush[:is_default]
        ensure_default_domain(false, false, @property_flush[:is_default])
      end
      @property_flush.clear
    end
  end

  private

  def keystone_conf_default_domain_id_entry(newid)
    conf = Puppet::Type::Keystone_config
      .new(:title => 'identity/default_domain_id', :value => newid)
    entry = Puppet::Type.type(:keystone_config).provider(:ini_setting)
      .new(conf)
    entry
  end

  def self.default_domain_id=(value)
    class_variable_set(:@@default_domain_id, value)
  end
end
