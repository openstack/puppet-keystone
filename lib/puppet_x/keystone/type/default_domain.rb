module PuppetX
  module Keystone
    module Type
      module DefaultDomain
        def self.included(klass)
          klass.class_eval do
            defaultto do
              default = PuppetX::Keystone::Type::DefaultDomain
                .calculate_using(resource)
              deprecation_msg = 'Support for a resource without the domain ' \
                'set is deprecated in Liberty cycle. ' \
                'It will be dropped in the M-cycle. ' \
                "Currently using '#{default}' as default domain."
              warning(deprecation_msg)
              default
            end

            # This make sure that @@default_domain is filled no matter
            # what.
            validate do |_|
              PuppetX::Keystone::Type::DefaultDomain
                .calculate_using(resource)
              true
            end
          end
        end
        def self.calculate_using(resource)
          current_default = from_keystone_env
          return current_default unless current_default.nil?
          catalog = resource.catalog
          if catalog.nil?
            # Running "puppet resource" (resource.catalog is nil)).
            # We try to get the default from the keystone.conf file
            # and then, the name from the api.
            current_default = from_keystone_conf_and_api(resource)
          else
            current_default = from_catalog(catalog)
          end

          resource.provider.class.default_domain = current_default
          current_default
        end

        private

        def self.from_keystone_env
          Puppet::Provider::Keystone.default_domain
        rescue Puppet::DevError => e
          raise e unless e.message.match(/The default domain should already be filled in/)
        end

        def self.from_catalog(catalog)
          default_res_in_cat = catalog.resources.find do |r|
            r.class.to_s == 'Puppet::Type::Keystone_domain' &&
              r[:is_default] == :true &&
              r[:ensure] == :present
          end
          default_res_in_cat[:name] rescue 'Default'
        end

        def self.from_keystone_conf_and_api(resource)
          current_default = nil
          default_domain_from_conf = Puppet::Resource.indirection
            .find('Keystone_config/identity/default_domain_id')

          if default_domain_from_conf[:ensure] == :absent
            current_default = 'Default'
          else
            current_default = resource.provider.class
              .domain_name_from_id(default_domain_from_conf[:value])
          end
          current_default
        rescue
          raise(Puppet::DevError,
            'The default domain cannot be guessed from your ' \
              'current installation. Please check that keystone ' \
              'is working properly')
        end
      end
    end
  end
end
