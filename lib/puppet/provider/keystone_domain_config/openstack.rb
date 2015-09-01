Puppet::Type.type(:keystone_domain_config).provide(
  :openstack,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  class Puppet::Error::OpenstackMissingDomainName < Puppet::Error; end
  class Puppet::Error::OpenstackMissingDomainDir < Puppet::Error; end

  # return the first which is defined:
  #  1. the value defined in the catalog (@base_dir)
  #  2. the value defined in the keystone.conf file
  #  3. the default value '/etc/keystone/domains'
  def self.base_dir
    return @base_dir if @base_dir
    base_dir = Puppet::Resource.indirection
      .find('Keystone_config/identity/domain_config_dir')[:value]
    if base_dir == :absent
      '/etc/keystone/domains'
    else
      base_dir
    end
  end

  def self.find_domain_conf(catalog)
    catalog.resources.find do |r|
      # better than is_a? here because symbol
      # Puppet::Type::Keystone_config may not be defined.
      r.class.to_s == 'Puppet::Type::Keystone_config' &&
        r.name == 'identity/domain_config_dir'
    end
  end

  # Use the prefetch hook to check if the keystone_config
  # identity/domain_config_dir is changed in the same catalog.  This
  # avoid to have to run puppet twice to get the right domain config
  # file changed.  Note, prefetch is the only time we can have acces
  # to the catalog from the provider.
  def self.prefetch(resources)
    catalog = resources.values.first.catalog
    resource_dir = find_domain_conf(catalog)
    @base_dir = resource_dir.nil? ? nil : resource_dir[:value]
  end

  def self.base_dir_exists?
    base_dir_resource = Puppet::Resource.indirection
      .find("file/#{base_dir}")[:ensure]
    base_dir_resource == :directory ? true : false
  end

  def create
    unless self.class.base_dir_exists?
      raise(Puppet::Error::OpenstackMissingDomainDir,
            "You must create the #{self.class.base_dir} directory " \
              'for keystone domain configuration.')
    end
    super
  end

  # Do not provide self.file_path method.  We need to create instance
  # with different file paths, so we cannot have the same path for all
  # the instances.  This force us to redefine the instances class
  # method.
  def self.instances
    resources = []
    Dir.glob(File.join(base_dir,'keystone.*.conf')).each do |domain_conf_file|
      domain = domain_conf_file.gsub(/^.*\/keystone\.(.*)\.conf$/, '\1')
      ini_file = Puppet::Util::IniFile.new(domain_conf_file, '=')
      ini_file.section_names.each do |section_name|
        ini_file.get_settings(section_name).each do |setting, value|
          resources.push(
            new(
              :name   => "#{domain}::#{section_name}/#{setting}",
              :value  => value,
              :ensure => :present
            )
          )
        end
      end
    end
    resources
  end

  def path
    File.join(self.class.base_dir, 'keystone.' + domain + '.conf')
  end

  # This avoid to have only one file for all the instances.
  alias_method :file_path, :path

  def domain
    if !@domain.nil?
      @domain
    else
      result = name.partition('::')
      if (result[1] == '' && result[2] == '') || result[0] == ''
        raise(Puppet::Error::OpenstackMissingDomainName,
              'You must provide a domain name in the name of the resource ' \
                '<domain_name>::<section>/<key>.  It cannot be empty.')
      else
        @domain = result[0]
      end
    end
  end

  def section
    @section ||= super.sub(domain + '::', '')
  end
end
