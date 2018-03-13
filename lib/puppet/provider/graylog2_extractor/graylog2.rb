# needed to load the common file lib/puppet/provider/graylog2.rb
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'graylog2'))

Puppet::Type.type(:graylog2_extractor).provide(:graylog2, :parent => Puppet::Provider::Graylog2) do

  desc 'Support for graylog extractors.'

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

  def self.get_extractors
    extractors = []
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
        extractor_list = self.generic_get("/system/inputs/#{gl_input['id']}/extractors")['extractors']
        extractor_list.each do |extractor|
          extractor = {
            'input'            => gl_input['message_input']['title'],
            'extractor_name'   => extractor['title'],
            'title'            => "#{gl_input['message_input']['title']}:#{extractor['title']}",
            'id'               => extractor['id'],
            'source_field'     => extractor['source_field'],
            'target_field'     => extractor['target_field'],
            'type'             => extractor['type'],
            'extractor_config' => extractor['extractor_config'],
            'condition_type'   => extractor['condition_type'],
            'condition_value'  => extractor['condition_value'],
            'cursor_strategy'  => extractor['cursor_strategy'],
            'converters'       => self.transform_converters(extractor['converters']),
          }
          extractors << extractor
        end
      end
    end
    return extractors
  end

  def create_extractor(name, element_properties)
    input_id = get_input_id(name.split(':')[0])
    extractor_id = self.generic_post("/system/inputs/#{input_id}/extractors", element_properties)['extractor_id']
    return extractor_id
  end

  def modify_extractor(name, extractor_id, element_properties)
    input_id = get_input_id(name.split(':')[0])
    Puppet.debug("modify_extractor: body of the put call=\n#{element_properties.pretty_inspect}")
    self.generic_put("/system/inputs/#{input_id}/extractors/#{extractor_id}", element_properties)
  end

  def delete_extractor(name, extractor_id)
    input_id = get_input_id(name.split(':')[0])
    self.generic_del("/system/inputs/#{input_id}/extractors/#{extractor_id}")
  end

  # This method collects on the node all existing instances of the things that this provider can manage.
  # Regardless of wheter there's a corresponding resource declaration in a manifest.
  # This should represent the 'is' state on a node.
  # The method should return an array of provider-instances.
  # Create a new instance with: new(:name => name, :property1 => current_state)
  def self.instances
    Puppet.debug('self.instances: retrieving extractors')
    resources = []
    gl_extractors = self.get_extractors()
    gl_extractors.each do |gl_extractor|
      element_properties = {
        :name             => gl_extractor['title'],
        :ensure           => :present,
        :input            => gl_extractor['input'],
        :extractor_name   => gl_extractor['extractor_name'],
        :graylog_id       => gl_extractor['id'],
        :source_field     => gl_extractor['source_field'],
        :target_field     => gl_extractor['target_field'],
        :extractor_type   => gl_extractor['type'],
        :extractor_config => gl_extractor['extractor_config'],
        :condition_type   => gl_extractor['condition_type'],
        :condition_value  => gl_extractor['condition_value'],
        :cut_or_copy      => gl_extractor['cursor_strategy'],
        :converters       => gl_extractor['converters'],
      }
      Puppet.debug("self.instances: resource found=\n#{element_properties.pretty_inspect}")
      resources << new(element_properties)
    end
    Puppet.debug('self.instances: number of resources= ' + resources.length.to_s)
    return resources
  end

  # Function called at the end to apply all changes
  def flush
    Puppet.debug("flush: graylog2_extractor #{resource[:name]}")
    case @property_hash[:ensure]
    # if ensure is absent, we delete the input
    when :absent
      Puppet.debug("flush: graylog2_extractor #{resource[:name]} to be removed")
      delete_extractor(@property_hash[:name], @property_hash[:graylog_id])
    when :present
      Puppet.debug("flush: update params:\n#{@property_hash.pretty_inspect}")
      element_properties = {
        :title            => @property_hash[:extractor_name],
        :source_field     => @property_hash[:source_field],
        :target_field     => @property_hash[:target_field],
        :extractor_type   => @property_hash[:extractor_type],
        :extractor_config => @property_hash[:extractor_config],
        :condition_type   => @property_hash[:condition_type],
        :condition_value  => @property_hash[:condition_value],
        :cut_or_copy      => @property_hash[:cut_or_copy],
        :converters       => @property_hash[:converters],
      }
      # if the resource is new, we have to create the input
      if @property_hash[:new]
        @property_hash[:graylog_id] = create_extractor(@property_hash[:name], element_properties)
      # if the resource is not new, we have to modify the input... PUT changes
      else
        modify_extractor(@property_hash[:name], @property_hash[:graylog_id], element_properties)
      end
    end
  end
end
