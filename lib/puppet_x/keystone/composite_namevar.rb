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
