# TODO: This should be extracted into openstacklib during the kilo cycle
# Add the auth parameter to whatever type is given
module Puppet::Util::Openstack
  def self.add_openstack_type_methods(type, comment)

    type.newparam(:auth) do

      desc <<EOT
Hash of authentication credentials. Credentials can be specified as
password credentials, e.g.:

auth => {
  'username'    => 'test',
  'password'    => 'passw0rd',
  'tenant_name' => 'test',
  'auth_url'    => 'http://localhost:35357/v2.0',
}

or a path to an openrc file containing these credentials, e.g.:

auth => {
  'openrc' => '/root/openrc',
}

or a service token and host, e.g.:

auth => {
  'service_token' => 'ADMIN',
  'auth_url'    => 'http://localhost:35357/v2.0',
}

If not present, the provider will look for environment variables for
password credentials.

#{comment}
EOT

      validate do |value|
        raise(Puppet::Error, 'This property must be a hash') unless value.is_a?(Hash)
      end
    end

    type.autorequire(:package) do
      'python-openstackclient'
    end

  end
end
