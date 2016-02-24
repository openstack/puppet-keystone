# LP#1408531
File.expand_path('../..', File.dirname(__FILE__)).tap { |dir| $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir) }
File.expand_path('../../../../openstacklib/lib', File.dirname(__FILE__)).tap { |dir| $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir) }

require 'puppet/provider/keystone/util'

Puppet::Type.newtype(:keystone_identity_provider) do

  desc 'Type for managing identity provider.'

  ensurable

  newparam(:name, :namevar => true) do
    newvalues(/\S+/)
  end

  newproperty(:enabled) do
    newvalues(/^(t|T)rue$/, /^(f|F)alse$/, true, false)
    def insync?(is)
      is.to_s.downcase.to_sym == should.to_s.downcase.to_sym
    end
    defaultto(true)
    munge do |value|
      value.to_s.downcase.to_sym
    end
  end

  newproperty(:description) do
    desc 'Description of the identity server.'
    newvalues(nil, /\S+/)
    def insync?(is)
      if should != is
        raise(Puppet::Error,
              'The description cannot be changed ' \
                "from #{should} to #{is}")
      end
      true
    end
  end

  newproperty(:remote_ids, :array_matching => :all) do
    def insync?(is)
      # remote_ids and remote_id_file are mutually exclusive.
      return true unless resource.parameters[:remote_id_file].nil?

      is.map(&:to_s).sort == should.map(&:to_s).sort
    end
    defaultto([])
    validate do |v|
      if idx = v.to_s.index('"')
        raise(Puppet::ResourceError,
              'rfc3986#section-2: remote id cannot have a double quote' \
                ": #{v} at position #{idx}"
             )
      end
      if v.to_s.match(/\s/)
        raise(Puppet::ResourceError,
              "Remote id cannot have space in it: '#{v}'"
             )
      end
    end
    munge(&:to_s)
  end

  newproperty(:remote_id_file) do
    validate do |v|
      unless resource.parameters[:remote_ids].nil?
        raise(Puppet::ResourceError,
              'Cannot have both remote_ids and remote_id_file')
      end
      unless Pathname.new(v).absolute?
        raise(Puppet::ResourceError,
              "You must specify an absolute path name not '#{v}'.")
      end
    end

    def insync?(is)
      ids_in_file = File.readlines(should).map(&:strip).delete_if(&:empty?)
      ids_in_file.sort == is.sort
    end
  end

  newproperty(:id) do
    validate do
      raise(Puppet::Error, 'This is a read only property')
    end
  end

  autorequire(:file) do
    if self[:remote_id_file] && Pathname.new(self[:remote_id_file]).absolute?
      self[:remote_id_file]
    end
  end

  autorequire(:anchor) do
    ['keystone::service::end']
  end
end
