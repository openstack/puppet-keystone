Puppet::Type.newtype(:keystone_implied_role) do

  desc <<-EOT
    This is currently used to model the creation of
    keystone implied roles.
  EOT

  ensurable

  newparam(:role) do
    isnamevar
    newvalues(/\S+/)
  end

  newparam(:implied_role) do
    isnamevar
    newvalues(/\S+/)
  end

  # we should not do anything until the keystone service is started
  autorequire(:anchor) do
    ['keystone::service::end']
  end

  autorequire(:keystone_role) do
    [self[:role], self[:implied_role]]
  end

  def self.title_patterns
    [
      [
        /^(\S+)@(\S+)$/,
        [
          [:role],
          [:implied_role],
        ]
      ],
    ]
  end
end
