require 'puppet/util/inifile'
require 'puppet/provider/openstack'
class Puppet::Provider::Keystone < Puppet::Provider::Openstack

  def request(service, action, object, credentials, *properties)
    begin
      super
    rescue Puppet::Error::OpenstackAuthInputError => error
      keystone_request(service, action, object, credentials, error, *properties)
    end
  end

  def self.request(service, action, object, credentials, *properties)
    begin
      super
    rescue Puppet::Error::OpenstackAuthInputError => error
      keystone_request(service, action, object, credentials, error, *properties)
    end
  end

  def keystone_request(service, action, object, credentials, error, *properties)
    self.class.keystone_request(service, action, object, credentials, error, *properties)
  end

  def self.keystone_request(service, action, object, credentials, error, *properties)
    credentials = {
      'token'    => get_admin_token,
      'auth_url' => get_admin_endpoint,
    }
    raise error unless (credentials['token'] && credentials['auth_url'])
    auth_args = token_auth_args(credentials)
    args = [object, properties, auth_args].flatten.compact
    authenticate_request(service, action, args)
  end

  def self.admin_token
    @admin_token ||= get_admin_token
  end

  def self.get_admin_token
    if keystone_file and keystone_file['DEFAULT'] and keystone_file['DEFAULT']['admin_token']
      return "#{keystone_file['DEFAULT']['admin_token'].strip}"
    else
      return nil
    end
  end

  def self.admin_endpoint
    @admin_endpoint ||= get_admin_endpoint
  end

  def get_admin_token
    self.class.get_admin_token
  end


  def self.get_admin_endpoint
    if keystone_file
      if keystone_file['DEFAULT']
        if keystone_file['DEFAULT']['admin_endpoint']
          auth_url = keystone_file['DEFAULT']['admin_endpoint'].strip.chomp('/')
          return "#{auth_url}/v2.0/"
        end

        if keystone_file['DEFAULT']['admin_port']
          admin_port = keystone_file['DEFAULT']['admin_port'].strip
        else
          admin_port = '35357'
        end

        if keystone_file['DEFAULT']['admin_bind_host']
          host = keystone_file['DEFAULT']['admin_bind_host'].strip
          if host == "0.0.0.0"
            host = "127.0.0.1"
          elsif host == '::0'
            host = '[::1]'
          end
        else
          host = "127.0.0.1"
        end
      end

      if keystone_file['ssl'] && keystone_file['ssl']['enable'] && keystone_file['ssl']['enable'].strip.downcase == 'true'
        protocol = 'https'
      else
        protocol = 'http'
      end
    end

    "#{protocol}://#{host}:#{admin_port}/v2.0/"
  end

  def get_admin_endpoint
    self.class.get_admin_endpoint
  end

  def self.keystone_file
    return @keystone_file if @keystone_file
    @keystone_file = Puppet::Util::IniConfig::File.new
    @keystone_file.read('/etc/keystone/keystone.conf')
    @keystone_file
  end

  def keystone_file
    self.class.keystone_file
  end

  # Helper functions to use on the pre-validated enabled field
  def bool_to_sym(bool)
    bool == true ? :true : :false
  end

  def sym_to_bool(sym)
    sym == :true ? true : false
  end

end
