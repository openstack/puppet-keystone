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

  def self.conf_filename
    '/etc/keystone/puppet.conf'
  end

  def self.keystone_puppet_conf
    return @keystone_puppet_conf if @keystone_puppet_conf
    @keystone_puppet_conf = Puppet::Util::IniConfig::File.new
    @keystone_puppet_conf.read(conf_filename)
    @keystone_puppet_conf
  end

  def self.get_keystone_puppet_credentials
    auth_keys = ['auth_url', 'project_name', 'username', 'password']

    conf = keystone_puppet_conf ? keystone_puppet_conf['keystone_authtoken'] : {}

    if conf and auth_keys.all?{|k| !conf[k].nil?}
      creds = Hash[ auth_keys.map { |k| [k, conf[k].strip] } ]

      if conf['project_domain_name']
        creds['project_domain_name'] = conf['project_domain_name']
      else
        creds['project_domain_name'] = 'Default'
      end

      if conf['user_domain_name']
        creds['user_domain_name'] = conf['user_domain_name']
      else
        creds['user_domain_name'] = 'Default'
      end

      if conf['region_name']
        creds['region_name'] = conf['region_name']
      end

      return creds
    else
      raise(Puppet::Error, "File: #{conf_filename} does not contain all " +
            "required configuration keys. Cannot authenticate to Keystone.")
    end
  end

  def self.keystone_puppet_credentials
    @keystone_puppet_credentials ||= get_keystone_puppet_credentials
  end

  def keystone_puppet_credentials
    self.class.keystone_puppet_credentials
  end

  def self.get_auth_endpoint
    q = keystone_puppet_credentials
    "#{q['auth_url']}"
  end

  def self.auth_endpoint
    @auth_endpoint ||= get_auth_endpoint
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

  def self.get_auth_url
    auth_url = nil
    if ENV['OS_AUTH_URL']
      auth_url = ENV['OS_AUTH_URL'].dup
    elsif auth_url = get_os_vars_from_rcfile(rc_filename)['OS_AUTH_URL']
    else
      auth_url = auth_endpoint
    end
    return auth_url
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
    keystone_request(service, action, error, properties)
  end

  def self.keystone_request(service, action, error, properties=nil)
    properties ||= []
    @credentials.username = keystone_puppet_credentials['username']
    @credentials.password = keystone_puppet_credentials['password']
    @credentials.project_name = keystone_puppet_credentials['project_name']
    @credentials.auth_url = auth_endpoint
    if keystone_puppet_credentials['region_name']
      @credentials.region_name = keystone_puppet_credentials['region_name']
    end
    if @credentials.version == '3'
      @credentials.user_domain_name = keystone_puppet_credentials['user_domain_name']
      @credentials.project_domain_name = keystone_puppet_credentials['project_domain_name']
    end
    raise error unless @credentials.set?
    Puppet::Provider::Openstack.request(service, action, properties, @credentials)
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

  # Helper functions to use on the pre-validated enabled field
  def bool_to_sym(bool)
    bool == true ? :true : :false
  end

  def sym_to_bool(sym)
    sym == :true ? true : false
  end
end
