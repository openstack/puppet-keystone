module PuppetX
  module Keystone
    module Type
      module Required
        def self.included(klass)
          klass.class_eval do
            defaultto do
              custom = ''
              if respond_to?(:required_custom_message)
                custom = send(:required_custom_message)
              end
              fail(Puppet::ResourceError,
                   "#{custom}" \
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
