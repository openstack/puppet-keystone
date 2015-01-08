# LP#1408531
File.expand_path('../..', File.dirname(__FILE__)).tap { |dir| $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir) }
require 'puppet/util/openstack'
Puppet::Type.newtype(:keystone_role) do

  desc <<-EOT
    This is currently used to model the creation of
    keystone roles.
  EOT

  ensurable

  newparam(:name, :namevar => true) do
    newvalues(/\S+/)
  end

  newproperty(:id) do
    validate do |v|
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  # we should not do anything until the keystone service is started
  autorequire(:service) do
    ['keystone']
  end

  auth_param_doc=<<EOT
If no other credentials are present, the provider will search in
/etc/keystone/keystone.conf for an admin token and auth url.
EOT
  Puppet::Util::Openstack.add_openstack_type_methods(self, auth_param_doc)
end
