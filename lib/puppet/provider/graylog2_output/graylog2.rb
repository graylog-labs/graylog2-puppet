# needed to load the common file lib/puppet/provider/graylog2.rb
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'graylog2'))

Puppet::Type.type(:graylog2_output).provide(:graylog2, :parent => Puppet::Provider::Graylog2) do

  desc 'Support for graylog outputs.'

  # creates a bunch of getters/setters for our properties/parameters
  # it is only for prefetch/flush providers
  # gets properties from @property_hash which contains the 'is' state of the resource
  mk_resource_methods

  def self.get_outputs
    return self.generic_get('/system/outputs')['outputs']
  end

  def create_output(element_properties)
    return self.generic_post('/system/outputs', element_properties)['id']
  end

  def modify_output(output_id, element_properties)
    Puppet.debug("modify_output: body of the put call=\n#{element_properties.pretty_inspect}")
    self.generic_put("/system/outputs/#{output_id}", element_properties)
  end

  def delete_output(output_id)
    self.generic_del("/system/outputs/#{output_id}")
  end

  # This method collects on the node all existing instances of the things that this provider can manage.
  # Regardless of wheter there's a corresponding resource declaration in a manifest.
  # This should represent the 'is' state on a node.
  # The method should return an array of provider-instances.
  # Create a new instance with: new(:name => name, :property1 => current_state)
  def self.instances
    Puppet.debug('self.instances: retrieving outputs')
    resources = []
    resource_names = {}
    gl_outputs = self.get_outputs()
    gl_outputs.each do |gl_output|
      # There's a prefix for resources that are not taken into consideration
      unless ignore_resource?(gl_output['title'], @output_bypass_prefixes)
        # if the name already exists (graylog accepts duplicated names) mark it with a tail ".DUPLICATED.X"
        output_name = self.mark_duplicated_name(gl_output['title'], resource_names)
        element_properties = {
          :name        => output_name,
          :ensure      => :present,
          :output_type => gl_output['type'],
          :graylog_id  => gl_output['id'],
          :config      => convert_property_map_to_str(gl_output['configuration']),
        }
        # add the output_name to the list of output names, to avoid duplicates
        resource_names[output_name] = true
        Puppet.debug("self.instances: resource found=\n#{element_properties.pretty_inspect}")
        resources << new(element_properties)
      end
    end
    Puppet.debug('self.instances: number of resources= ' + resources.length.to_s)
    return resources
  end

  def output_type=(value)
    delete_output(@property_hash[:graylog_id])
    @property_hash[:output_type] = value
    @property_hash[:new] = true
  end

  # Function called at the end to apply all changes
  def flush
    Puppet.debug("flush: graylog2_output #{resource[:name]}")
    case @property_hash[:ensure]
    # if ensure is absent, we delete the output
    when :absent
      Puppet.debug("flush: graylog2_output #{resource[:name]} to be removed")
      delete_output(@property_hash[:graylog_id])
    when :present
      Puppet.debug("flush: update params:\n#{@property_hash.pretty_inspect}")
      element_properties = {
        :title         => @property_hash[:name],
        :type          => @property_hash[:output_type],
        :configuration => unquote(@property_hash[:config]),
      }
      # if the resource is new, we have to create the output
      if @property_hash[:new]
        @property_hash[:graylog_id] = create_output(element_properties)
      # if the resource is not new, we have to modify the output... PUT changes
      else
        modify_output(@property_hash[:graylog_id], element_properties)
      end
    end
  end
end
