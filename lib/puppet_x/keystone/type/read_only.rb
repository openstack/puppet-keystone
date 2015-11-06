module PuppetX
  module Keystone
    module Type
      module ReadOnly
        def self.included(klass)
          klass.class_eval do
            validate do |_|
              fail(ArgumentError, 'Read-only property.')
            end
          end
        end
      end
    end
  end
end
