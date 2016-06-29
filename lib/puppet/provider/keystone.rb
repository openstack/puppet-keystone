require 'puppet/util/inifile'
require 'puppet/provider/openstack'
require 'puppet/provider/openstack/auth'
require 'puppet/provider/openstack/credentials'
require File.join(File.dirname(__FILE__), '..','..', 'puppet/provider/keystone/util')

class Puppet::Provider::Keystone < Puppet::Provider::Openstack

  extend Puppet::Provider::Openstack::Auth

  INI_FILENAME = '/etc/keystone/keystone.conf'
  DEFAULT_DOMAIN = 'Default'

  @@default_domain_id = nil

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
      # if ipv6, make sure ip address has brackets - LP#1541512
      if host.include?(':') and !host.include?(']')
        return "[" + host + "]"
      else
        return host
      end
    end
  end

  def self.default_domain_from_ini_file
    default_domain_from_conf = Puppet::Resource.indirection
      .find('Keystone_config/identity/default_domain_id')
    if default_domain_from_conf[:ensure] == :present
      # get from ini file
      default_domain_from_conf[:value]
    else
      nil
    end
  rescue
    nil
  end

  def self.default_domain_id
    if @@default_domain_id
      # cached
      @@default_domain_id
    else
      @@default_domain_id = default_domain_from_ini_file
    end
    @@default_domain_id = @@default_domain_id.nil? ? 'default' : @@default_domain_id
  end

  def self.default_domain_changed
    default_domain_id != 'default'
  end

  def self.default_domain_deprecation_message
    'Support for a resource without the domain ' \
      'set is deprecated in Liberty cycle. ' \
      'It will be dropped in the M-cycle. ' \
      "Currently using '#{default_domain}' as default domain name " \
      "while the default domain id is '#{default_domain_id}'."
  end

  def self.default_domain
    DEFAULT_DOMAIN
  end

  def self.resource_to_name(domain, name, check_for_default = true)
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

  def self.user_id_from_name_and_domain_name(name, domain_name)
    @users_name ||= {}
    id_str = "#{name}_#{domain_name}"
    unless @users_name.keys.include?(id_str)
      user = fetch_user(name, domain_name)
      err("Could not find user with name [#{name}] and domain [#{domain_name}]") unless user
      @users_name[id_str] = user[:id]
    end
    @users_name[id_str]
  end

  def self.project_id_from_name_and_domain_name(name, domain_name)
    @projects_name ||= {}
    id_str = "#{name}_#{domain_name}"
    unless @projects_name.keys.include?(id_str)
      project = fetch_project(name, domain_name)
      err("Could not find project with name [#{name}] and domain [#{domain_name}]") unless project
      @projects_name[id_str] = project[:id]
    end
    @projects_name[id_str]
  end

  def self.domain_name_from_id(id)
    unless @domain_hash
      list = request('domain', 'list')
      @domain_hash = Hash[list.collect{|domain| [domain[:id], domain[:name]]}]
    end
    unless @domain_hash.include?(id)
      name = request('domain', 'show', id)[:name]
      err("Could not find domain with id [#{id}]") unless name
      @domain_hash[id] = name
    end
    @domain_hash[id]
  end

  def self.domain_id_from_name(name)
    unless @domain_hash_name
      list = request('domain', 'list')
      @domain_hash_name = Hash[list.collect{|domain| [domain[:name], domain[:id]]}]
    end
    unless @domain_hash_name.include?(name)
      id = request('domain', 'show', name)[:id]
      err("Could not find domain with name [#{name}]") unless id
      @domain_hash_name[name] = id
    end
    @domain_hash_name[name]
  end

  def self.fetch_project(name, domain)
    domain ||= default_domain
    request('project', 'show',
            [name, '--domain', domain],
            {:no_retry_exception_msgs => /No project with a name or ID/})
  rescue Puppet::ExecutionFailure => e
    raise e unless e.message =~ /No project with a name or ID/
  end

  def self.fetch_user(name, domain)
    domain ||= default_domain
    request('user', 'show',
            [name, '--domain', domain],
            {:no_retry_exception_msgs => /No user with a name or ID/})
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

  def self.request(service, action, properties=nil, options={})
    super
  rescue Puppet::Error::OpenstackAuthInputError, Puppet::Error::OpenstackUnauthorizedError => error
    request_by_service_token(service, action, error, properties, options=options)
  end

  def self.request_by_service_token(service, action, error, properties=nil, options={})
    properties ||= []
    @credentials.token = admin_token
    @credentials.url   = service_url
    raise error unless @credentials.service_token_set?
    Puppet::Provider::Openstack.request(service, action, properties, @credentials, options)
  end

  def self.service_url
    @service_url ||= get_service_url
  end

  def self.set_domain_for_name(name, domain_name)
    if domain_name.nil? || domain_name.empty?
      raise(Puppet::Error, "Missing domain name for resource #{name}")
    end
    domain_id = self.domain_id_from_name(domain_name)
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
