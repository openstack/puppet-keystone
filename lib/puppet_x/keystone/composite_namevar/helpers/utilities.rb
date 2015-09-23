module PuppetX
  module Keystone
    module CompositeNamevar
      module Helpers
        module Utilities
          def prefetch_composite(resources)
            # cannot trust puppet for correct resources with semantic title
            res = resources.values.first
            catalog = res.catalog
            klass   = res.class
            required_resources = catalog.resources.find_all do |e|
              e.class.to_s == klass.to_s
            end

            # hash catalog resource by uniq key
            required_res = Hash[required_resources.map(&:uniqueness_key)
              .zip(required_resources)]
            # This is the sort order returned by uniqueness_key.
            namevars_ordered = resource_type.key_attributes.map(&:to_s).sort
            existings = instances
            # uniqueness_key sort by lexical order of the key attributes
            required_res.each do |res_key, resource|
              provider = existings.find do |existing|
                if block_given?
                  # transformation is done on the name using namevar,
                  # so we let the user transform it the correct way.
                  res_transformed_namevar = yield(res_key)
                  # name in self.instance is assumed to have the same
                  # transformation than the one given by the user.
                  exist_transformed_namevar = existing.name
                  res_transformed_namevar == exist_transformed_namevar
                else
                  res_key == namevars_ordered
                    .map { |namevar| existing.send(namevar) }
                end
              end
              resource.provider = provider if provider
            end
          end
        end
      end
    end
  end
end
