require 'puppet/util/inifile'
require 'puppet/provider/openstack'
require 'puppet/provider/openstack/auth'
require 'puppet/provider/openstack/credentials'
require File.join(File.dirname(__FILE__), '..','..', 'puppet/provider/keystone/util')

class Puppet::Provider::Keystone < Puppet::Provider::Openstack

  extend Puppet::Provider::Openstack::Auth

  DEFAULT_DOMAIN = 'Default'

  @@default_domain_id = nil

  def self.get_auth_endpoint
    configs = self.request('configuration', 'show')
    "#{configs['auth.auth_url']}"
  rescue Puppet::Error::OpenstackAuthInputError
    nil
  end

  def self.auth_endpoint
    @auth_endpoint ||= get_auth_endpoint
  end

  def self.default_domain_from_ini_file
    default_domain_from_conf = Puppet::Resource.indirection
      .find('Keystone_config/identity/default_domain_id')
    if default_domain_from_conf[:ensure] == :present
      # get from ini file
      default_domain_from_conf[:value][0]
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
      if user && user.key?(:id)
        @users_name[id_str] = user[:id]
      else
        err("Could not find user with name [#{name}] and domain [#{domain_name}]")
      end
    end
    @users_name[id_str]
  end

  def self.project_id_from_name_and_domain_name(name, domain_name)
    @projects_name ||= {}
    id_str = "#{name}_#{domain_name}"
    unless @projects_name.keys.include?(id_str)
      project = fetch_project(name, domain_name)
      if project && project.key?(:id)
        @projects_name[id_str] = project[:id]
      else
        err("Could not find project with name [#{name}] and domain [#{domain_name}]")
      end
    end
    @projects_name[id_str]
  end

  def self.domain_name_from_id(id)
    unless @domain_hash
      list = system_request('domain', 'list')
      if list.nil?
        err("Could not list domains")
      else
        @domain_hash = Hash[list.collect{|domain| [domain[:id], domain[:name]]}]
      end
    end
    unless @domain_hash.include?(id)
      domain = system_request('domain', 'show', id)
      if domain && domain.key?(:name)
        @domain_hash[id] = domain[:name]
      else
        err("Could not find domain with id [#{id}]")
      end
    end
    @domain_hash[id]
  end

  def self.domain_id_from_name(name)
    unless @domain_hash_name
      list = system_request('domain', 'list')
      @domain_hash_name = Hash[list.collect{|domain| [domain[:name], domain[:id]]}]
    end
    unless @domain_hash_name.include?(name)
      domain = system_request('domain', 'show', name)
      if domain && domain.key?(:id)
        @domain_hash_name[name] = domain[:id]
      else
        err("Could not find domain with name [#{name}]")
      end
    end
    @domain_hash_name[name]
  end

  def self.fetch_project(name, domain)
    domain ||= default_domain
    system_request('project', 'show',
                   [name, '--domain', domain],
                   {:no_retry_exception_msgs => /No project with a name or ID/})
  rescue Puppet::ExecutionFailure => e
    raise e unless e.message =~ /No project with a name or ID/
  end

  def self.fetch_user(name, domain)
    domain ||= default_domain
    system_request('user', 'show',
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

  def self.project_request(service, action, properties=nil, options={})
    self.request(service, action, properties, options, 'project')
  end

  def self.system_request(service, action, properties=nil, options={})
    self.request(service, action, properties, options, 'system')
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
