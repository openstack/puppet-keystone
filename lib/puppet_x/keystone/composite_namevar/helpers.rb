require 'puppet_x/keystone/composite_namevar/helpers/utilities'

module PuppetX
  module Keystone
    module CompositeNamevar
      module Helpers
        def set?(param, argument = nil)
          value = nil
          if argument.nil?
            value = send(param.to_sym)
          else
            value = send(param.to_sym, argument)
          end
          value != PuppetX::Keystone::CompositeNamevar::Unset
        end

        def parameter_set?(key)
          set?(:'[]', key.to_sym)
        end

        def self.included(klass)
          klass.extend Utilities if klass.to_s.match(/Provider/)
        end
      end
    end
  end
end
