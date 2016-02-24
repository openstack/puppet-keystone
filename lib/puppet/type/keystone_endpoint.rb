# LP#1408531
File.expand_path('../..', File.dirname(__FILE__)).tap { |dir| $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir) }
File.expand_path('../../../../openstacklib/lib', File.dirname(__FILE__)).tap { |dir| $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir) }
require 'puppet_x/keystone/composite_namevar'
require 'puppet_x/keystone/type'

Puppet::Type.newtype(:keystone_endpoint) do

  desc 'Type for managing keystone endpoints.'

  include PuppetX::Keystone::CompositeNamevar::Helpers
  ensurable

  newparam(:name, :namevar => true)

  newproperty(:id) do
    include PuppetX::Keystone::Type::ReadOnly
  end

  newparam(:region) do
    isnamevar
    include PuppetX::Keystone::Type::Required
  end

  newparam(:type) do
    isnamevar
    defaultto do
      deprecation_msg = 'Support for a endpoint without the type ' \
      'set is deprecated in Liberty. ' \
      'It will be dropped in Mitaka.'
      warning(deprecation_msg)
      PuppetX::Keystone::CompositeNamevar::Unset
    end
  end

  newproperty(:public_url)

  newproperty(:internal_url)

  newproperty(:admin_url)

  # we should not do anything until the keystone service is started
  autorequire(:anchor) do
    ['keystone::service::end']
  end

  autorequire(:keystone_service) do
    if parameter_set?(:type)
      "#{name}::#{self[:type]}"
    else
      title = catalog.resources
        .find_all { |e| e.type == :keystone_service && e[:name] == name }
        .map { |e| e.title }.uniq
      if title.count == 1
        title
      else
        warning("Couldn't find the type of the domain to require using #{name}")
        name
      end
    end
  end

  def self.title_patterns
    name = PuppetX::Keystone::CompositeNamevar.not_two_colon_regex
    type = Regexp.new(/.+/)
    region = Regexp.new(/[^\/]+/)
    [
      [
        /^(#{region})\/(#{name})::(#{type})$/,
        [
          [:region],
          [:name],
          [:type]
        ]
      ],
      [
        /^(#{region})\/(#{name})$/,
        [
          [:region],
          [:name]
        ]
      ],
      [
        /^(#{name})::(#{type})$/,
        [
          [:name],
          [:type]
        ]
      ],
      [
        /^(#{name})$/,
        [
          [:name]
        ]
      ]
    ]
  end
end
