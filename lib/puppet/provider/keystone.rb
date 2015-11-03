require 'puppet/util/inifile'
require 'puppet/provider/openstack'
require 'puppet/provider/openstack/auth'
require 'puppet/provider/openstack/credentials'
require 'puppet/provider/keystone/util'

class Puppet::Provider::Keystone < Puppet::Provider::Openstack

  extend Puppet::Provider::Openstack::Auth

  INI_FILENAME = '/etc/keystone/keystone.conf'

  @@default_domain    = nil

  def self.admin_endpoint
    @admin_endpoint ||= get_admin_endpoint
  end

  def self.admin_token
    @admin_token ||= get_admin_token
  end

  def self.clean_host(host)
    host ||= '127.0.0.1'
    case host
    when '0.0.0.0'
      return '127.0.0.1'
    when '::0'
      return '[::1]'
    else
      return host
    end
  end

  def self.resource_to_name(domain, name, check_for_default=true)
    raise Puppet::Error, "Domain cannot be nil for project '#{name}'. " \
      'Please report a bug.' if domain.nil?
    join_str = '::'
    name_display = [name]
    unless check_for_default && domain == default_domain
      name_display << domain
    end
    name_display.join(join_str)
  end

  def self.name_to_resource(name)
    uniq = name.split('::')
    if uniq.count == 1
      uniq.insert(0, default_domain)
    else
      uniq.reverse!
    end
    uniq
  end

  # Prefix with default domain if missing from the name.
  def self.make_full_name(name)
    resource_to_name(*name_to_resource(name), false)
  end

  def self.default_domain
    # Default domain class variable is filled in by
    # user/tenant/user_role type or domain resource.
    @@default_domain
  end

  def self.default_domain=(value)
    @@default_domain = value
  end

  def self.domain_name_from_id(id)
    unless @domain_hash
      list = request('domain', 'list')
      @domain_hash = Hash[list.collect{|domain| [domain[:id], domain[:name]]}]
    end
    unless @domain_hash.include?(id)
      name = request('domain', 'show', id)[:name]
      @domain_hash[id] = name if name
    end
    unless @domain_hash.include?(id)
      err("Could not find domain with id [#{id}]")
    end
    @domain_hash[id]
  end

  def self.fetch_domain(domain)
    request('domain', 'show', domain)
  rescue Puppet::ExecutionFailure => e
    raise e unless e.message =~ /No domain with a name or ID/
  end

  def self.fetch_project(name, domain)
    domain ||= default_domain
    request('project', 'show', [name, '--domain', domain])
  rescue Puppet::ExecutionFailure => e
    raise e unless e.message =~ /No project with a name or ID/
  end

  def self.fetch_user(name, domain)
    domain ||= default_domain
    request('user', 'show', [name, '--domain', domain])
  rescue Puppet::ExecutionFailure => e
    raise e unless e.message =~ /No user with a name or ID/
  end

  def self.get_admin_endpoint
    endpoint = nil
    if keystone_file
      if url = get_section('DEFAULT', 'admin_endpoint')
        endpoint = url.chomp('/')
      else
        admin_port = get_section('DEFAULT', 'admin_port') || '35357'
        host = clean_host(get_section('DEFAULT', 'admin_bind_host'))
        protocol = ssl? ? 'https' : 'http'
        endpoint = "#{protocol}://#{host}:#{admin_port}"
      end
    end
    return endpoint
  end

  def self.get_admin_token
    get_section('DEFAULT', 'admin_token')
  end

  def self.get_auth_url
    auth_url = nil
    if ENV['OS_AUTH_URL']
      auth_url = ENV['OS_AUTH_URL'].dup
    elsif auth_url = get_os_vars_from_rcfile(rc_filename)['OS_AUTH_URL']
    else
      auth_url = admin_endpoint
    end
    return auth_url
  end

  def self.get_section(group, name)
    if keystone_file && keystone_file[group] && keystone_file[group][name]
      return keystone_file[group][name].strip
    end
    return nil
  end

  def self.get_service_url
    service_url = nil
    if ENV['OS_URL']
      service_url = ENV['OS_URL'].dup
    elsif admin_endpoint
      service_url = admin_endpoint
      service_url << "/v#{@credentials.version}"
    end
    return service_url
  end

  def self.ini_filename
    INI_FILENAME
  end

  def self.keystone_file
    return @keystone_file if @keystone_file
    if File.exists?(ini_filename)
      @keystone_file = Puppet::Util::IniConfig::File.new
      @keystone_file.read(ini_filename)
      @keystone_file
    end
  end

  def self.request(service, action, properties=nil)
    super
  rescue Puppet::Error::OpenstackAuthInputError => error
    request_by_service_token(service, action, error, properties)
  end

  def self.request_by_service_token(service, action, error, properties=nil)
    properties ||= []
    @credentials.token = admin_token
    @credentials.url   = service_url
    raise error unless @credentials.service_token_set?
    Puppet::Provider::Openstack.request(service, action, properties, @credentials)
  end

  def self.service_url
    @service_url ||= get_service_url
  end

  def self.set_domain_for_name(name, domain_name)
    if domain_name.nil? || domain_name.empty?
      raise(Puppet::Error, "Missing domain name for resource #{name}")
    end
    domain = fetch_domain(domain_name)
    domain_id = domain ? domain[:id] : nil
    case domain_id
    when default_domain_id
      name
    when nil
      name
    else
      name << "::#{domain_name}"
    end
  end

  def self.ssl?
    if keystone_file && keystone_file['ssl'] && keystone_file['ssl']['enable'] && keystone_file['ssl']['enable'].strip.downcase == 'true'
      return true
    end
    return false
  end

  # Helper functions to use on the pre-validated enabled field
  def bool_to_sym(bool)
    bool == true ? :true : :false
  end

  def sym_to_bool(sym)
    sym == :true ? true : false
  end
end
