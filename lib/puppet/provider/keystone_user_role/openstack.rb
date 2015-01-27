require 'puppet/provider/keystone'

Puppet::Type.type(:keystone_user_role).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc "Provider to manage keystone role assignments to users."

  def create
    properties = []
    properties << '--project' << get_project
    properties << '--user' << get_user
    if resource[:roles]
      resource[:roles].each do |role|
        request('role', 'add', role, resource[:auth], properties)
      end
    end
  end

  def exists?
    # If we just ran self.instances, no need to make the request again
    # instance() will find it cached in @user_role_hash
    if self.class.user_role_hash
      return ! instance(resource[:name]).empty?
    # If we don't have the hash ready, we don't need to rebuild the
    # whole thing just to check on one particular user/role
    else
      roles = request('user role', 'list', nil, resource[:auth], ['--project', get_project, get_user])
      # Since requesting every combination of users, roles, and
      # projects is so expensive, construct the property hash here
      # instead of in self.instances so it can be used in the role
      # and destroy methods
      @property_hash[:name] = resource[:name]
      if roles.empty?
        @property_hash[:ensure] = :absent
      else
        @property_hash[:ensure] = :present
        @property_hash[:roles]  = roles.collect do |role|
          role[:name]
        end
      end
      return @property_hash[:ensure] == :present
    end
  end

  def destroy
    properties = []
    properties << '--project' << get_project
    properties << '--user' << get_user
    if @property_hash[:roles]
      @property_hash[:roles].each do |role|
        request('role', 'remove', role, resource[:auth], properties)
      end
    end
    @property_hash[:ensure] = :absent
  end


  def roles
    @property_hash[:roles]
  end

  def roles=(value)
    current_roles = roles
    # determine the roles to be added and removed
    remove = current_roles - Array(value)
    add    = Array(value) - current_roles
    user = get_user
    project = get_project
    add.each do |role_name|
      request('role', 'add', role_name, resource[:auth], ['--project', project, '--user', user])
    end
    remove.each do |role_name|
      request('role', 'remove', role_name, resource[:auth], ['--project', project, '--user', user])
    end
  end


  def self.instances
    instances = build_user_role_hash
    instances.collect do |title, roles|
      new(
        :name   => title,
        :ensure => :present,
        :roles  => roles
      )
    end
  end

  def instance(name)
    self.class.user_role_hash.select { |role_name, roles| role_name == name } || {}
  end

  private

  def get_user
    resource[:name].rpartition('@').first
  end

  def get_project
    resource[:name].rpartition('@').last
  end

  # We split get_projects into class and instance methods
  # so that the appropriate request method gets called
  def get_projects
    request('project', 'list', nil, resource[:auth]).collect do |project|
      project[:name]
    end
  end

  def self.get_projects
    request('project', 'list', nil, nil).collect do |project|
      project[:name]
    end
  end

  def get_users(project)
    request('user', 'list', nil, resource[:auth], ['--project', project]).collect do |user|
      user[:name]
    end
  end

  def self.get_users(project)
    request('user', 'list', nil, nil, ['--project', project]).collect do |user|
      user[:name]
    end
  end

  # Class methods for caching user_role_hash so both class and instance
  # methods can access the value
  def self.set_user_role_hash(user_role_hash)
    @user_role_hash = user_role_hash
  end

  def self.user_role_hash
    @user_role_hash
  end

  def self.build_user_role_hash
    hash = user_role_hash || {}
    return hash unless hash.empty?
    projects = get_projects
    projects.each do |project|
      users = get_users(project)
      users.each do |user|
        user_roles = request('user role', 'list', nil, nil, ['--project', project, user])
        hash["#{user}@#{project}"] = []
        user_roles.each do |role|
          hash["#{user}@#{project}"] << role[:name]
        end
      end
    end
    set_user_role_hash(hash)
    hash
  end

end
