# Cherry pick PUP-1073 from puppetlabs: support of composite namevar for alias.
if Gem::Version.new(Puppet.version.sub(/\(Puppet Enterprise .*/i, '').strip) < Gem::Version.new('4.0.0')
  Puppet::Resource::Catalog.class_eval do
    def create_resource_aliases(resource)
      # Skip creating aliases and checking collisions for non-isomorphic resources.
      return unless resource.respond_to?(:isomorphic?) and resource.isomorphic?
      # Add an alias if the uniqueness key is valid and not the
      # title, which has already been checked.
      ukey = resource.uniqueness_key
      if ukey.any? and ukey != [resource.title]
        self.alias(resource, ukey)
      end
    end
  end
  Puppet::Resource.class_eval do
    def uniqueness_key
      # Temporary kludge to deal with inconsistent use patterns; ensure we don't return nil for namevar/:name
      h = self.to_hash
      name = h[namevar] || h[:name] || self.name
      h[namevar] ||= name
      h[:name]   ||= name
      h.values_at(*key_attributes.sort_by { |k| k.to_s })
    end
  end
end

require 'puppet_x/keystone/composite_namevar/helpers'

module PuppetX
  module Keystone
    module CompositeNamevar

      class Unset; end

      def self.not_two_colon_regex
        # Anything but 2 consecutive colons.
        Regexp.new(/(?:[^:]|:[^:])+/)
      end

      def self.basic_split_title_patterns(prefix, suffix, separator = '::', *regexps)
        associated_regexps = []
        if regexps.empty? and separator == '::'
          associated_regexps += [not_two_colon_regex, not_two_colon_regex]
        else
          if regexps.count != 2
            raise(Puppet::DevError, 'You must provide two regexps')
          else
            associated_regexps += regexps
          end
        end
        prefix_re = associated_regexps[0]
        suffix_re = associated_regexps[1]
        [
          [
            /^(#{prefix_re})#{separator}(#{suffix_re})$/,
            [
              [prefix],
              [suffix]
            ]
          ],
          [
            /^(#{prefix_re})$/,
            [
              [prefix]
            ]
          ]
        ]
      end
    end
  end
end
