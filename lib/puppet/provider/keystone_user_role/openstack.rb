require 'puppet/provider/keystone'
require 'puppet/provider/keystone/util'
require 'puppet_x/keystone/composite_namevar'

Puppet::Type.type(:keystone_user_role).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do
  desc "Provider to manage keystone role assignments to users."

  include PuppetX::Keystone::CompositeNamevar::Helpers

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
    if resource[:roles]
      options = properties
      resource[:roles].each do |role|
        self.class.request('role', 'add', [role] + options)
      end
    end
  end

  def destroy
    if @property_hash[:roles]
      options = properties
      @property_hash[:roles].each do |role|
        self.class.request('role', 'remove', [role] + options)
      end
    end
    @property_hash[:ensure] = :absent
  end

  def exists?
    if self.class.user_role_hash.nil? || self.class.user_role_hash.empty?
      roles_db = self.class.request('role', 'list', properties)
      # Since requesting every combination of users, roles, and
      # projects is so expensive, construct the property hash here
      # instead of in self.instances so it can be used in the role
      # and destroy methods
      @property_hash[:name] = resource[:name]
      if roles_db.empty?
        @property_hash[:ensure] = :absent
      else
        @property_hash[:ensure] = :present
        @property_hash[:roles]  = roles_db.collect do |role|
          role[:name]
        end
      end
    end
    return @property_hash[:ensure] == :present
  end

  mk_resource_methods

  # Don't want :absent
  [:user, :user_domain, :project, :project_domain, :domain].each do |attr|
    define_method(attr) do
      @property_hash[attr] ||= resource[attr]
    end
  end

  def roles=(value)
    current_roles = roles
    # determine the roles to be added and removed
    remove = current_roles - Array(value)
    add    = Array(value) - current_roles
    add.each do |role_name|
      self.class.request('role', 'add', [role_name] + properties)
    end
    remove.each do |role_name|
      self.class.request('role', 'remove', [role_name] + properties)
    end
  end

  def self.instances
    if default_domain_changed
      warning(default_domain_deprecation_message)
    end
    instances = build_user_role_hash
    instances.collect do |title, roles|
      new({
        :name   => title,
        :ensure => :present,
        :roles  => roles
      }.merge(@user_role_parameters[title]))
    end
  end

  private

  def properties
    return @properties if @properties
    properties = []
    if set?(:project)
      properties << '--project' << get_project_id
    elsif set?(:domain)
      properties << '--domain' << domain
    else
      raise(Puppet::Error, 'No project or domain specified for role')
    end
    properties << '--user' << get_user_id
    @properties = properties
  end

  def get_user_id
    user_db = self.class.fetch_user(user, user_domain)
    raise(Puppet::Error, "No user #{user} with domain #{user_domain} found") if user_db.nil?
    user_db[:id]
  end

  def get_project_id
    project_db = self.class.fetch_project(project, project_domain)
    if project_db.nil?
      raise(Puppet::Error, "No project #{project} with domain #{project_domain} found")
    end
    project_db[:id]
  end

  def self.user_role_hash
    @user_role_hash
  end

  def self.set_user_role_hash(user_role_hash)
    @user_role_hash = user_role_hash
  end

  def self.build_user_role_hash
    self.do_not_manage = true
    # The new hash will have the property that if the
    # given key does not exist, create it with an empty
    # array as the value for the hash key
    hash = @user_role_hash || Hash.new{|h,k| h[k] = []}
    @user_role_parameters = {}
    return hash unless hash.empty?
    # Need a mapping of project id to names.
    project_hash = {}
    Puppet::Type.type(:keystone_tenant).provider(:openstack).instances.each do |project|
      project_hash[project.id] = project.name
    end
    # Need a mapping of user id to names.
    user_hash = {}
    Puppet::Type.type(:keystone_user).provider(:openstack).instances.each do |user|
      user_hash[user.id] = user.name
    end
    # need a mapping of role id to name
    role_hash = {}
    request('role', 'list').each {|role| role_hash[role[:id]] = role[:name]}
    # now, get all role assignments
    request('role assignment', 'list').each do |assignment|
      if assignment[:user]
        user_str = user_hash[assignment[:user]]
        if assignment[:project] && !assignment[:project].empty?
          project_str = project_hash[assignment[:project]]
          name = "#{user_str}@#{project_str}"
          @user_role_parameters[name] = Hash[
            [:user_domain, :user, :project_domain, :project]
              .zip(name_to_resource(user_str) + name_to_resource(project_str))]
        else
          domainname = domain_name_from_id(assignment[:domain])
          name = "#{user_hash[assignment[:user]]}@::#{domainname}"
          @user_role_parameters[name] = Hash[
            [:user_domain, :user, :domain]
              .zip(name_to_resource(user_str) + [domainname])]
        end
        hash[name] << role_hash[assignment[:role]]
      end
    end
    set_user_role_hash(hash)
    self.do_not_manage = false
    hash
  end
end
