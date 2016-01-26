# needed to load the common file lib/puppet/provider/graylog2.rb
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'graylog2'))

Puppet::Type.type(:graylog2_staticfield).provide(:graylog2, :parent => Puppet::Provider::Graylog2) do

  desc 'Support for graylog static fields.'

  # creates a bunch of getters/setters for our properties/parameters
  # it is only for prefetch/flush providers
  # gets properties from @property_hash which contains the 'is' state of the resource
  mk_resource_methods

  def get_input_id(input_name)
    Puppet.debug("get_input_id: input name is= #{input_name}")
    inputs = self.class.generic_get('/system/inputs')['inputs']
    inputs.each do |input|
      if input['message_input']['title'] == input_name
        return input['id']
      end
    end
    return nil
  end

  def self.transform_converters(converters)
    converters_new = {}
    converters.each do |converter|
      converters_new[converter['type']] = converter['config']
    end
    return converters_new
  end

  def self.get_staticfields
    staticfields = []
    gl_inputs = self.generic_get('/system/inputs')['inputs']
    gl_inputs.each do |gl_input|
      # There's a prefix for resources that are not taken into consideration
      ignore_input = false
      @input_bypass_prefixes.each do |prefix|
        if Regexp.new('^' + prefix).match(gl_input['message_input']['title'])
          ignore_input = true
          break
        end
      end
      unless ignore_input
        staticfield_list = gl_input['message_input']['static_fields']
        if staticfield_list.nil?
          staticfield_list = {}
        end
        staticfield_list.each do |staticfield_key, value|
          staticfield = {
            'input'           => gl_input['message_input']['title'],
            'staticfield_key' => staticfield_key,
            'title'           => "#{gl_input['message_input']['title']}:#{staticfield_key}",
            'value'           => value,
          }
          staticfields << staticfield
        end
      end
    end
    return staticfields
  end

  def create_or_modify_staticfield(name, element_properties)
    input_id = get_input_id(name.split(':')[0])
    Puppet.debug("modify_staticfield: body of the post call=\n#{element_properties.pretty_inspect}")
    # NOTE: it's weird, but a POST call can modify the staticfield
    self.generic_post("/system/inputs/#{input_id}/staticfields", element_properties)
  end

  def delete_staticfield(name, staticfield_id)
    input_id = get_input_id(name.split(':')[0])
    self.generic_del("/system/inputs/#{input_id}/staticfields/#{staticfield_id}")
  end

  # This method collects on the node all existing instances of the things that this provider can manage.
  # Regardless of wheter there's a corresponding resource declaration in a manifest.
  # This should represent the 'is' state on a node.
  # The method should return an array of provider-instances.
  # Create a new instance with: new(:name => name, :property1 => current_state)
  def self.instances
    Puppet.debug('self.instances: retrieving staticfields')
    resources = []
    gl_staticfields = self.get_staticfields()
    gl_staticfields.each do |gl_staticfield|
      element_properties = {
        :name             => gl_staticfield['title'],
        :ensure           => :present,
        :input            => gl_staticfield['input'],
        :staticfield_key  => gl_staticfield['staticfield_key'],
        :value            => gl_staticfield['value'],
      }
      Puppet.debug("self.instances: resource found=\n#{element_properties.pretty_inspect}")
      resources << new(element_properties)
    end
    Puppet.debug('self.instances: number of resources= ' + resources.length.to_s)
    return resources
  end

  # Function called at the end to apply all changes
  def flush
    Puppet.debug("flush: graylog2_staticfield #{resource[:name]}")
    case @property_hash[:ensure]
    # if ensure is absent, we delete the input
    when :absent
      Puppet.debug("flush: graylog2_staticfield #{resource[:name]} to be removed")
      delete_staticfield(@property_hash[:name], @property_hash[:graylog_id])
    when :present
      Puppet.debug("flush: update params:\n#{@property_hash.pretty_inspect}")
      element_properties = {
        :key   => @property_hash[:staticfield_key],
        :value => @property_hash[:value],
      }
      create_or_modify_staticfield(@property_hash[:name], element_properties)
    end
  end
end
