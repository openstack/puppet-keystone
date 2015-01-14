# TODO: This needs to be extracted out into openstacklib in the Kilo cycle
require 'csv'
require 'puppet'

class Puppet::Error::OpenstackAuthInputError < Puppet::Error
end

class Puppet::Error::OpenstackUnauthorizedError < Puppet::Error
end

class Puppet::Provider::Openstack < Puppet::Provider

  initvars # so commands will work
  commands :openstack => 'openstack'

  def request(service, action, object, credentials, *properties)
    if password_credentials_set?(credentials)
      auth_args = password_auth_args(credentials)
    elsif openrc_set?(credentials)
      credentials = get_credentials_from_openrc(credentials['openrc'])
      auth_args = password_auth_args(credentials)
    elsif service_credentials_set?(credentials)
      auth_args = token_auth_args(credentials)
    elsif env_vars_set?
      # noop; auth needs no extra arguments
      auth_args = nil
    else  # All authentication efforts failed
      raise(Puppet::Error::OpenstackAuthInputError, 'No credentials provided.')
    end
    args = [object, properties, auth_args].flatten.compact
    authenticate_request(service, action, args)
  end

  def self.request(service, action, object, *properties)
    if env_vars_set?
      # noop; auth needs no extra arguments
      auth_args = nil
    else  # All authentication efforts failed
      raise(Puppet::Error::OpenstackAuthInputError, 'No credentials provided.')
    end
    args = [object, properties, auth_args].flatten.compact
    authenticate_request(service, action, args)
  end

  # Returns an array of hashes, where the keys are the downcased CSV headers
  # with underscores instead of spaces
  def self.authenticate_request(service, action, *args)
    rv = nil
    timeout = 10
    end_time = Time.now.to_i + timeout
    loop do
      begin
        if(action == 'list')
          response = openstack(service, action, '--quiet', '--format', 'csv', args)
          response = parse_csv(response)
          keys = response.delete_at(0) # ID,Name,Description,Enabled
          rv = response.collect do |line|
            hash = {}
            keys.each_index do |index|
              key = keys[index].downcase.gsub(/ /, '_').to_sym
              hash[key] = line[index]
            end
            hash
          end
        elsif(action == 'show' || action == 'create')
          rv = {}
          # shell output is name="value"\nid="value2"\ndescription="value3" etc.
          openstack(service, action, '--format', 'shell', args).split("\n").each do |line|
            # key is everything before the first "="
            key, val = line.split("=", 2)
            next unless val # Ignore warnings
            # value is everything after the first "=", with leading and trailing double quotes stripped
            val = val.gsub(/\A"|"\Z/, '')
            rv[key.downcase.to_sym] = val
          end
        else
          rv = openstack(service, action, args)
        end
        break
      rescue Puppet::ExecutionFailure => e
        if e.message =~ /HTTP 401/
          raise(Puppet::Error::OpenstackUnauthorizedError, 'Could not authenticate.')
        elsif e.message =~ /Unable to establish connection/
          current_time = Time.now.to_i
          if current_time > end_time
            break
          else
            wait = end_time - current_time
            Puppet::debug("Non-fatal error: \"#{e.message}\"; retrying for #{wait} more seconds.")
            if wait > timeout - 2 # Only notice the first time
              notice("#{service} service is unavailable. Will retry for up to #{wait} seconds.")
            end
          end
          sleep(2)
        else
          raise e
        end
      end
    end
    return rv
  end

  def authenticate_request(service, action, *args)
    self.class.authenticate_request(service, action, *args)
  end

  private

  def password_credentials_set?(auth_params)
    auth_params && auth_params['username'] && auth_params['password'] && auth_params['tenant_name'] && auth_params['auth_url']
  end


  def openrc_set?(auth_params)
    auth_params && auth_params['openrc']
  end


  def service_credentials_set?(auth_params)
    auth_params && auth_params['token'] && auth_params['auth_url']
  end


  def self.env_vars_set?
    ENV['OS_USERNAME'] && ENV['OS_PASSWORD'] && ENV['OS_TENANT_NAME'] && ENV['OS_AUTH_URL']
  end


  def env_vars_set?
    self.class.env_vars_set?
  end



  def self.password_auth_args(credentials)
    ['--os-username',    credentials['username'],
     '--os-password',    credentials['password'],
     '--os-tenant-name', credentials['tenant_name'],
     '--os-auth-url',    credentials['auth_url']]
  end

  def password_auth_args(credentials)
    self.class.password_auth_args(credentials)
  end


  def self.token_auth_args(credentials)
    ['--os-token',    credentials['token'],
     '--os-url', credentials['auth_url']]
  end

  def token_auth_args(credentials)
    self.class.token_auth_args(credentials)
  end

  def get_credentials_from_openrc(file)
    creds = {}
    File.open(file).readlines.delete_if{|l| l=~ /^#/}.each do |line|
      key, value = line.split('=')
      key = key.split(' ').last.downcase.sub(/^os_/, '')
      value = value.chomp.gsub(/'/, '')
      creds[key] = value
    end
    return creds
  end


  def self.get_credentials_from_env
    env = ENV.to_hash.dup.delete_if { |key, _| ! (key =~ /^OS_/) }
    credentials = {}
    env.each do |name, value|
      credentials[name.downcase.sub(/^os_/, '')] = value
    end
    credentials
  end

  def get_credentials_from_env
    self.class.get_credentials_from_env
  end

  def self.parse_csv(text)
    # Ignore warnings - assume legitimate output starts with a double quoted
    # string.  Errors will be caught and raised prior to this
    text = text.split("\n").drop_while { |line| line !~ /^\".*\"/ }.join("\n")
    return CSV.parse(text + "\n")
  end

end
