require 'json'
require File.join(File.dirname(__FILE__), '..','..','..', 'puppet/provider/keystone')

class Puppet::Error::OpenstackDuplicateRemoteId < Puppet::Error; end

Puppet::Type.type(:keystone_identity_provider).provide(
  :openstack,
  :parent => Puppet::Provider::Keystone
) do

  desc 'Provider to manage keystone identity provider.'

  @credentials = Puppet::Provider::Openstack::CredentialsV3.new

  mk_resource_methods

  def create
    properties     = []
    remote_ids     = []
    remote_id_file = []
    option_enable  = '--enable'

    remote_ids += resource[:remote_ids] if resource[:remote_ids]

    remote_id_file += ['--remote-id-file', resource[:remote_id_file]] if
      resource[:remote_id_file]

    properties += self.class.remote_ids_cli(remote_ids)
    properties += remote_id_file

    option_enable = '--disable' if resource[:enabled] == :false
    properties << option_enable

    properties += ['--description', resource[:description]] if
      resource[:description]
    properties << resource[:name]

    @property_hash = self.class.request('identity provider',
                                        'create',
                                        properties)

  rescue Puppet::ExecutionFailure => e
    if e.message =~
        /openstack Conflict occurred attempting to store identity_provider/
      raise(Puppet::Error::OpenstackDuplicateRemoteId,
            'One of the remote-id of this resource is already ' \
              'registered by another identity provider: ' \
              "#{e.message}")
    else
      raise e
    end
  else
    @property_hash[:ensure] = :present
  end

  def destroy
    self.class.request('identity provider', 'delete', id)
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def self.instances
    list = request('identity provider', 'list')
    list.collect do |identity_provider|

      current_resource =
        request('identity provider', 'show', identity_provider[:id])
      new(
        :name        => identity_provider[:id],
        :id          => identity_provider[:id],
        :description => identity_provider[:description],
        :enabled     => identity_provider[:enabled].downcase.chomp == 'true' ? true : false,
        :remote_ids  => clean_remote_ids(current_resource[:remote_ids]),
        :ensure      => :present
      )
    end
  end

  def self.prefetch(resources)
    identity_providers = instances
    resources.keys.each do |name|
      if provider = identity_providers.find { |existing| existing.name == name }
        resources[name].provider = provider
      end
    end
  end

  # puppetlabs/PUP-1470: to be removed when puppet 3.5 is no longer supported.
  def enabled
    if @property_hash[:enabled].nil?
      :absent
    else
      @property_hash[:enabled]
    end
  end

  def enabled=(value)
    options = value == :false ? ['--disable'] : ['--enable']
    options << id
    self.class.request('identity provider', 'set', options)
  end

  def remote_ids=(value)
    options = []
    options += self.class.remote_ids_cli(value)
    self.class.request('identity provider', 'set', options + [id]) unless
      options.empty?
  end

  def remote_id_file=(value)
    options = ['--remote-id-file', value]
    self.class.request('identity provider', 'set', options + [id])
  end

  def remote_id_file
    remote_ids
  end

  # bug/python-openstackclient/1478995: when fixed, parsing will be done by OSC.
  def self.clean_remote_ids(remote_ids)
    version = request('--version', '').sub(/openstack\s+/i, '').strip
    if Gem::Version.new(version) < Gem::Version.new('1.9.0')
      clean_remote_ids_old(remote_ids)
    else
      remote_ids.split(',').map(&:strip)
    end
  end

  def self.clean_remote_ids_old(remote_ids)
    remote_ids_clean = []
    if remote_ids != '[]'
      python_array_of_unicode_string = %r/
      u                                      # the u character
      (?<delimiter>["'])                     # followed by a delimiter
      (?<value>                              # which holds the value
        .+?                                  # composed of non-delimiter
      )
      (\k<delimiter>)                        # ended by the delimiter
      /x
      remote_ids_clean = JSON.parse(remote_ids.gsub(
        python_array_of_unicode_string,
        '"\k<value>"'))
    end
  rescue JSON::ParserError
    raise(Puppet::Error,
      "Could not parse #{remote_ids} into a valid structure. " \
        'Please submit a bug report.')
  else
    remote_ids_clean
  end
  def self.remote_ids_cli(remote_ids)
    remote_ids.map { |e| ['--remote-id', e.to_s] }.flatten
  end
end
