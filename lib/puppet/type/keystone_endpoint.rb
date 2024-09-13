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
    include PuppetX::Keystone::Type::Required
  end

  newproperty(:public_url)

  newproperty(:internal_url)

  newproperty(:admin_url)

  # we should not do anything until the keystone service is started
  autorequire(:anchor) do
    ['keystone::service::end']
  end

  autorequire(:keystone_service) do
    "#{name}::#{self[:type]}"
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
