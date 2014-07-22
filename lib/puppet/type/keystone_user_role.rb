Puppet::Type.newtype(:keystone_user_role) do

  desc <<-EOT
    This is currently used to model the creation of
    keystone users roles.

    User roles are an assignment of a role to a user on
    a certain tenant. The combination of all of these
    attributes is unique.
  EOT

  ensurable

  newparam(:name, :namevar => true) do
    newvalues(/^\S+@\S+$/)
    #munge do |value|
    #  matchdata = /(\S+)@(\S+)/.match(value)
    #  {
    #    :user   =>  matchdata[1],
    #    :tenant =>  matchdata[2]
    #  }
    #nd
  end

  newproperty(:roles,  :array_matching => :all) do
  end

  newproperty(:id) do
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  autorequire(:keystone_user) do
    self[:name].rpartition('@').first
  end

  autorequire(:keystone_tenant) do
    self[:name].rpartition('@').last
  end

  autorequire(:keystone_role) do
    self[:roles]
  end

  # we should not do anything until the keystone service is started
  autorequire(:service) do
    ['keystone']
  end

end
