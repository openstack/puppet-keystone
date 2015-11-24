module PuppetX
  module Keystone
    module Type
      module DefaultDomain
        def self.included(klass)
          klass.class_eval do
            defaultto do
              Puppet::Provider::Keystone.default_domain
            end
          end
        end
      end
    end
  end
end
