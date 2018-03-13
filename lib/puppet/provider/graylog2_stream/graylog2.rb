# needed to load the common file lib/puppet/provider/graylog2.rb
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'graylog2'))

Puppet::Type.type(:graylog2_stream).provide(:graylog2, :parent => Puppet::Provider::Graylog2) do

  desc 'Support for graylog streams.'

  # creates a bunch of getters/setters for our properties/parameters
  # it is only for prefetch/flush providers
  # gets properties from @property_hash which contains the 'is' state of the resource
  mk_resource_methods

  def self.get_streams
    return self.generic_get('/streams')['streams']
  end

  def create_stream(element_properties)
    stream_id = self.generic_post('/streams', element_properties)['stream_id']
    return stream_id
  end

  def modify_stream(stream_id, element_properties)
    Puppet.debug("modify_stream: body of the put call=\n#{element_properties.pretty_inspect}")
    self.generic_put("/streams/#{stream_id}", element_properties)
  end

  def get_output_id(output_name)
    outputs = self.class.generic_get('/system/outputs')['outputs']
    outputs.each do |output|
      if output['title'] == output_name
        return output['id']
      end
    end
    return nil
  end

  def self.convert_output_ids_to_names(output_ids)
    unless output_ids
      return []
    end
    output_names = []
    output_ids.each do |output|
      output_names << self.generic_get("/system/outputs/#{output['_id']}")['title']
    end
    return output_names
  end

  def get_output_list_with_ids(outputs)
    output_list = []
    outputs.each do |output_name|
      output_id = get_output_id(output_name)
      if output_id.nil?
        fail('outputs=(value): output ID not found!')
      else
        output_list << output_id
      end
    end
    Puppet.debug("get_output_list_with_ids: Output List='#{output_list.pretty_inspect}'")
    return output_list
  end


  def create_or_modify_streamoutputs(stream_id, element_properties)
    generic_post("/streams/#{stream_id}/outputs", element_properties)
  end

  def delete_streamoutput(stream_id, output_id)
    generic_del("/streams/#{stream_id}/outputs/#{output_id}")
  end

  def delete_stream(stream_id)
    self.generic_del("/streams/#{stream_id}")
  end

  def resume_stream(stream_id)
    generic_post("/streams/#{stream_id}/resume", nil)
  end

  def pause_stream(stream_id)
    generic_post("/streams/#{stream_id}/pause", nil)
  end

  # This method collects on the node all existing instances of the things that this provider can manage.
  # Regardless of wheter there's a corresponding resource declaration in a manifest.
  # This should represent the 'is' state on a node.
  # The method should return an array of provider-instances.
  # Create a new instance with: new(:name => name, :property1 => current_state)
  def self.instances
    Puppet.debug('self.instances: retrieving streams')
    resources = []
    resource_names = {}
    gl_streams = self.get_streams()
    gl_streams.each do |gl_stream|
      # There's a prefix for resources that are not taken into consideration
      unless ignore_resource?(gl_stream['title'], @stream_bypass_prefixes)
        # if the name already exists (graylog accepts duplicated names) mark it with a tail ".DUPLICATED.X"
        stream_name = self.mark_duplicated_name(gl_stream['title'], resource_names)
        element_properties = {
          :name        => stream_name,
          :ensure      => :present,
          :graylog_id  => gl_stream['id'],
          :description => gl_stream['description'],
          :disabled    => self.convert_bool_to_symbol(gl_stream['disabled']),
          :outputs     => self.convert_output_ids_to_names(gl_stream['outputs']),
        }
        # add the output_name to the list of output names, to avoid duplicates
        resource_names[stream_name] = true
        Puppet.debug("self.instances: resource found=\n#{element_properties.pretty_inspect}")
        resources << new(element_properties)
      end
    end
    Puppet.debug('self.instances: number of resources= ' + resources.length.to_s)
    return resources
  end

  # changes in the disabled trigger a call to either resume or pause an stream
  def disabled=(value)
    Puppet.debug("disabled=(value): new property 'disabled' for #{resource[:name]}, graylogID #{@property_hash[:graylog_id]} is= #{value}")
    # if disabled changed to true, pause the stream
    if value == :true
      pause_stream(@property_hash[:graylog_id])
    # if disabled changed to false, resume the stream
    else
      resume_stream(@property_hash[:graylog_id])
    end
    @property_hash[:disabled] = value
    # wanted to not trigger flush if there is such a change, but it is not possible to do it directly
  end

  # changes in the output property trigger a call to modify stream outputs
  def outputs=(value)
    Puppet.debug("outputs=(value): new property 'outputs' for #{resource[:name]}, graylogID #{@property_hash[:graylog_id]} is= #{value.pretty_inspect}")
    # construct the output list with the IDs that correspond to the names that are in the new value
    output_list = get_output_list_with_ids(value)
    create_or_modify_streamoutputs(@property_hash[:graylog_id], {:outputs => output_list})
    @property_hash[:outputs] = output_list
    # wanted to not trigger flush if there is such a change, but it is not possible to do it directly
  end

  # Function called at the end to apply all changes
  def flush
    Puppet.debug("flush: graylog2_stream #{resource[:name]}")
    case @property_hash[:ensure]
    # if ensure is absent, we delete the stream
    when :absent
      Puppet.debug("flush: graylog2_stream #{resource[:name]} to be removed")
      delete_stream(@property_hash[:graylog_id])
    when :present
      Puppet.debug("flush: update params:\n#{@property_hash.pretty_inspect}")
      element_properties = {
        :title         => @property_hash[:name],
        :description   => @property_hash[:description],
      }
      # if the resource is new, we have to create the stream
      if @property_hash[:new]
        @property_hash[:graylog_id] = create_stream(element_properties)
        # 'disabled' and 'outputs' properties are not accepted in the creation
        # is disabled is false, resume the stream (turn it on)
        unless @property_hash[:disable]
          resume_stream(@property_hash[:graylog_id])
        end
        # create the stream outputs
        create_or_modify_streamoutputs(@property_hash[:graylog_id], {:outputs => get_output_list_with_ids(@property_hash[:outputs])})
      # if the resource is not new, we have to modify the stream... PUT changes
      else
        modify_stream(@property_hash[:graylog_id], element_properties)
      end
    end
  end
end
