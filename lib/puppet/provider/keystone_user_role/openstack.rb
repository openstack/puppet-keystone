require 'puppet/provider/keystone'

Puppet::Type.type(:keystone_user_role).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc "Provider to manage keystone role assignments to users."

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

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
    ! instance(resource[:name]).empty?
  end

  def destroy
    properties = []
    properties << '--project' << get_project
    properties << '--user' << get_user
    if resource[:roles]
      resource[:roles].each do |role|
        request('role', 'remove', role, resource[:auth], properties)
      end
    end
  end


  def roles
    instance(resource[:name])[:roles]
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

  def instances
    instances = build_user_role_hash
    instances.collect do |title, roles|
      {
        :name  => title,
        :roles => roles
      }
    end
  end

  def instance(name)
    @instances ||= instances.select { |instance| instance[:name] == name }.first || {}
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

  def build_user_role_hash
    hash = {}
    projects = get_projects
    projects.each do |project|
      users = get_users(project)
      users.each do |user|
        user_roles = request('user role', 'list', nil, resource[:auth], ['--project', project, user])
        user_roles.each do |role|
          hash["#{user}@#{project}"] ||= []
          hash["#{user}@#{project}"] << role[:name]
        end
      end
    end
    hash
  end

  def self.build_user_role_hash
    hash = {}
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
    hash
  end

end
