require 'net/http'
require 'json'
require 'pp'
require 'yaml'

class Puppet::Provider::Graylog2 < Puppet::Provider

  # Load in the YAML configuration file, check for errors, and return as hash 'cfg'
  def self.load_config
    @try_timeout = 20
    #file that contains some special configuration for the native types
    configfile = '/var/lib/puppet/module_data/graylog2/types_conf.yaml'
    cfg = File.open(configfile)  { |yf| YAML::load( yf ) } if File.exists?(configfile)
    # => Ensure loaded data is a hash. ie: YAML load was OK
    if cfg.class != Hash
       fail('ERROR: configuration - invalid format or parsing error.')
    end
    fail('config not loaded correctly! graylog_api_port is missing...') if cfg['graylog_api_port'].nil?
    @http = Net::HTTP.new('localhost', cfg['graylog_api_port'])
    fail('config not loaded correctly! graylog_admin_user is missing...') unless @user = cfg['graylog_admin_user']
    fail('config not loaded correctly! graylog_admin_pass is missing...') unless @pass = cfg['graylog_admin_pass']
    fail('config not loaded correctly! input_bypass_prefixes is missing...') unless @input_bypass_prefixes = cfg['input_bypass_prefixes']
    fail('config not loaded correctly! output_bypass_prefixes is missing...') unless @output_bypass_prefixes = cfg['output_bypass_prefixes']
    fail('config not loaded correctly! stream_bypass_prefixes is missing...') unless @stream_bypass_prefixes = cfg['stream_bypass_prefixes']
    fail('config not loaded correctly! user_bypass_prefixes is missing...') unless @user_bypass_prefixes = cfg['user_bypass_prefixes']
    @http.read_timeout = @try_timeout
    @http.open_timeout = @try_timeout
  end

  # Generic HTTP call
  def self.generic_http_call(request)
    if @user.nil?
      self.load_config
    end
    if @user.nil?
      return nil
    end
    request.basic_auth(@user, @pass)
    for i in 1..15
      http_error = false
      begin
        response = @http.request(request)
      rescue
        http_error = true
        Puppet.debug('generic_http_call: HTTP connection error!')
      end
      if !http_error
        if /^20[0-9]$/.match(response.code)
          if (!response.body.nil?) && (!response.body.empty?)
            return JSON.parse(response.body)
          else
            return {}
          end
        else
          if /^40[0-9]$/.match(response.code)
            Puppet.debug("generic_http_call: response code= #{response.code} response message= #{response.message}")
            return {}
          end
          Puppet.debug("generic_http_call: bad response code= #{response.code} response message= #{response.message}!")
        end
      end
      Puppet.debug("generic_http_call: #{i} attempt failed... retrying in #{@try_timeout}s...")
      sleep @try_timeout
    end
    raise 'Call to graylog failed!' # I wanted to stop Puppet if this happens but apparently it's not possible
  end

  # Generic GET/POST/PUT/DELETE calls
  def self.generic_get(path)
    Puppet.debug('generic_get: path= ' + path)
    request = Net::HTTP::Get.new(path)
    return self.generic_http_call(request)
  end

  def generic_post(path, body_map)
    Puppet.debug('generic_post: path= ' + path)
    request = Net::HTTP::Post.new(path)
    request['Content-Type'] = 'application/json'
    if body_map
      request.body = body_map.to_json
      Puppet.debug("generic_post: theres a bodymap= #{request.body}")
    end
    return self.class.generic_http_call(request) # self.class. is needed to go from the instance scope to the class scope
  end

  def generic_put(path, body_map)
    Puppet.debug('generic_put: path= ' + path)
    request = Net::HTTP::Put.new(path)
    request.body = body_map.to_json
    Puppet.debug("generic_put: bodymap= #{request.body}")
    Puppet.debug(request.body)
    request['Content-Type'] = 'application/json'
    return self.class.generic_http_call(request)
  end

  def generic_del(path)
    Puppet.debug('generic_del: path= ' + path)
    request = Net::HTTP::Delete.new(path)
    return self.class.generic_http_call(request)
  end

  # CONVERSION FUNCTIONS
  def self.convert_property_map_to_str(hash_map)
    new_hash_map = {}
    hash_map.each do |k,v|
      new_hash_map[k] = v.to_s
    end
    return new_hash_map
  end

  def self.convert_bool_to_symbol(value)
    if value
      return :true
    end
    return :false
  end

  def self.ignore_resource?(resource_name, prefix_list)
    prefix_list.each do |prefix|
      if Regexp.new('^' + prefix).match(resource_name)
        return true
      end
    end
    return false
  end

  # resources with names that are already in the list, we start labeling them with the tail ".DUPLICATED.X"
  def self.mark_duplicated_name(name_base, name_list)
    unless name_list[name_base]
      return name_base
    end
    duplicated_number = 1
    while true
      name = "#{name_base}.DUPLICATED.#{duplicated_number}"
      unless name_list[name]
        return name
      end
      duplicated_number = duplicated_number + 1
    end
  end

  def convert_symbol_to_bool(value)
    return value == :true
  end

  # avoids badly formed json strings like {"port":"1221"} (there shouldnt be any quote around 1221)
  # TODO do this inside the type-munge and not inside the provider
  def unquote(hash_map)
    new_hash_map = {}
    hash_map.each do |k,v|
      case k
      # properties that shouldnt be around quotes
      # TODO place up in EMOC/EMEC puppet module
      when 'port', 'recv_buffer_size', 'connect_timeout', 'reconnect_delay', 'type', 'max_chunk_size', 'max_message_size', 'parallel_queues', 'prefetch', 'broker_port', 'amqp_connection_timeout', 'amqp_port'
        new_hash_map[k] = v.to_i
      when 'use_null_delimiter', 'allow_override_date', 'enable_cors', 'store_full_message'
        if v == 'true'
          new_hash_map[k] = true
        else
          new_hash_map[k] = false
        end
      else
        new_hash_map[k] = v
      end
    end
    return new_hash_map
  end

  # The prefetch method takes the provider instances that self.instances found and connects them
  # to the existing resources in the puppet catalogue. Generic, works for all providers with self.instances
  def self.prefetch(resources)
    instances.each do |instance|
      if resource = resources[instance.name]
        resource.provider = instance
      end
    end
  end

  def create
    Puppet.debug("Creating resource #{resource[:name]}")
    @property_hash[:ensure] = :present
    @property_hash[:new] = true
    @property_hash[:name] = @resource[:name]
    self.class.resource_type.validproperties.each do |property|
      if val = resource.should(property)
        @property_hash[property] = val
      end
    end
  end

  def destroy
    Puppet.debug("Destroying resource #{resource[:name]}")
    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash.fetch(:ensure, :absent) != :absent
  end

end
