module PuppetX
  module Keystone
    module Type
      module Required
        def self.included(klass)
          klass.class_eval do
            defaultto do
              fail(Puppet::ResourceError,
                   "Parameter #{name} failed on " \
                     "#{resource.class.to_s.split('::')[-1]}[#{resource.name}]: " \
                     'Required parameter.')
            end
          end
        end
      end
    end
  end
end
