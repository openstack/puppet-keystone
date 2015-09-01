module PuppetX
  module KeystoneConfig
    # Mixin for shared code between keystone_config and
    # keystone_domain_config.  This can be reincluded directly to
    # keystone_config when openstackcli supports domain configuration and
    # keystone_domain_config is refactored.
    module IniSetting
      def create_parameters
        ensurable

        newparam(:name, :namevar => true) do
          desc 'Section/setting name to manage from keystone.conf'
          newvalues(/\S+\/\S+/)
        end

        newproperty(:value) do
          desc 'The value of the setting to be defined.'
          munge do |value|
            value = value.to_s.strip
            value.capitalize! if value =~ /^(true|false)$/i
            value
          end
          newvalues(/^[\S ]*$/)

          def is_to_s( currentvalue )
            if resource.secret?
              return '[old secret redacted]'
            else
              return currentvalue
            end
          end

          def should_to_s( newvalue )
            if resource.secret?
              return '[new secret redacted]'
            else
              return newvalue
            end
          end
        end

        newparam(:secret, :boolean => true) do
          desc 'Whether to hide the value from Puppet logs. Defaults to `false`.'

          newvalues(:true, :false)

          defaultto false
        end

        newparam(:ensure_absent_val) do
          desc 'A value that is specified as the value property will behave as if ensure => absent was specified'
          defaultto('<SERVICE DEFAULT>')
        end

        autorequire(:package) do
          'keystone'
        end
      end
    end
  end
end
