# needed to load the common file lib/puppet/provider/graylog2.rb
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'graylog2'))

Puppet::Type.type(:graylog2_input).provide(:graylog2, :parent => Puppet::Provider::Graylog2) do

  desc 'Support for graylog inputs.'

  # creates a bunch of getters/setters for our properties/parameters
  # it is only for prefetch/flush providers
  # gets properties from @property_hash which contains the 'is' state of the resource
  mk_resource_methods

  def self.get_inputs
    return self.generic_get('/system/inputs')['inputs']
  end

  def create_input(element_properties)
    input_id = self.generic_post('/system/inputs', element_properties)['id']
    if @property_hash[:state] == 'STOPPED'
      generic_post("/system/inputs/#{input_id}/stop", nil)
    end
    return input_id
  end

  def launch_input(input_id)
    return generic_post("/system/inputs/#{input_id}/launch", nil)
  end

  def stop_input(input_id)
    return generic_post("/system/inputs/#{input_id}/stop", nil)
  end

  def restart_input(input_id)
    return self.generic_post("/system/inputs/#{input_id}/restart", nil)
  end

  def modify_input(input_id, element_properties)
    #first we put the modif
    Puppet.debug("modify_input: body of the put call=\n#{element_properties.pretty_inspect}")
    self.generic_put("/system/inputs/#{input_id}", element_properties)
    #then, we restart the input. The web interface does not differentiate if the input was running or not, so we don't do it either
    Puppet.debug("Restarting the input.")
    restart_input(input_id)
  end

  def delete_input(input_id)
    self.generic_del("/system/inputs/#{input_id}")
  end


  # This method collects on the node all existing instances of the things that this provider can manage.
  # Regardless of wheter there's a corresponding resource declaration in a manifest.
  # This should represent the 'is' state on a node.
  # The method should return an array of provider-instances.
  # Create a new instance with: new(:name => name, :property1 => current_state)
  def self.instances
    Puppet.debug('self.instances: retrieving inputs')
    resources = []
    resource_names = {}
    gl_inputs = self.get_inputs()
    gl_inputs.each do |gl_input|
      # There's a prefix for resources that are not taken into consideration
      unless ignore_resource?(gl_input['message_input']['title'], @input_bypass_prefixes)
        # if the name already exists (graylog accepts duplicated names) mark it with a tail ".DUPLICATED.X"
        input_name = self.mark_duplicated_name(gl_input['message_input']['title'], resource_names)
        element_properties = {
          :name       => input_name,
          :ensure     => :present,
          :input_type => gl_input['message_input']['type'],
          :graylog_id => gl_input['id'],
          :global     => self.convert_bool_to_symbol(gl_input['message_input']['global']),
          :state      => gl_input['state'],
          :config     => convert_property_map_to_str(gl_input['message_input']['attributes']),
        }
        # add the input_name to the list of input names, to avoid duplicates
        resource_names[input_name] = true
        Puppet.debug("self.instances: resource found=\n#{element_properties.pretty_inspect}")
        resources << new(element_properties)
      end
    end
    Puppet.debug('self.instances: number of resources= ' + resources.length.to_s)
    return resources
  end

  # changes in the state trigger a call to either launch or stop an input
  def state=(value)
    Puppet.debug("state=(value): new property 'state' for #{resource[:name]}, graylogID #{@property_hash[:graylog_id]} is= #{value}")
    case value
    when 'RUNNING'
      launch_input(@property_hash[:graylog_id])
    when 'STOPPED'
      stop_input(@property_hash[:graylog_id])
    end
    @property_hash[:state] = value
    # TODO not trigger flush
  end

  # Function called at the end to apply all changes
  def flush
    Puppet.debug("flush: graylog2_input #{resource[:name]}")
    case @property_hash[:ensure]
    # if ensure is absent, we delete the input
    when :absent
      Puppet.debug("flush: graylog2_input #{resource[:name]} to be removed")
      delete_input(@property_hash[:graylog_id])
    when :present
      Puppet.debug("flush: update params:\n#{@property_hash.pretty_inspect}")
      element_properties = {
        :title         => @property_hash[:name],
        :type          => @property_hash[:input_type],
        :global        => convert_symbol_to_bool(@property_hash[:global]),
        :configuration => unquote(@property_hash[:config]),
      }
      # if the resource is new, we have to create the input
      if @property_hash[:new]
        @property_hash[:graylog_id] = create_input(element_properties)
      # if the resource is not new, we have to modify the input... PUT changes -> restart (POST)
      else
        modify_input(@property_hash[:graylog_id], element_properties)
      end
    end
  end

end
