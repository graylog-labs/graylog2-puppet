# needed to load the common file lib/puppet/provider/graylog2.rb
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'graylog2'))

Puppet::Type.type(:graylog2_streamrule).provide(:graylog2, :parent => Puppet::Provider::Graylog2) do

  desc 'Support for graylog stream rules.'

  # creates a bunch of getters/setters for our properties/parameters
  # it is only for prefetch/flush providers
  # gets properties from @property_hash which contains the 'is' state of the resource
  mk_resource_methods

  def self.id_file
    @id_file ||= '/var/lib/puppet/module_data/graylog2/streamrule_ids.yaml'
  end

  # File operations

  def self.get_id_table
    id_table = File.open(self.id_file, 'r')  { |yf| YAML::load( yf ) } if File.exists?(self.id_file)
    unless id_table
      id_table = {}
    end
    return id_table
  end

  def add_rule_mapping(name, streamrule_id)
    id_table = self.class.get_id_table()
    id_table[name] = streamrule_id
    File.open(self.class.id_file, 'w') { |file| file.write(id_table.to_yaml + "\n") }
  end

  def del_rule_mapping(name)
    id_table = self.class.get_id_table()
    id_table.delete(name)
    File.open(self.class.id_file, 'w') { |file| file.write(id_table.to_yaml + "\n") }
  end

  def get_stream_id(stream_name)
    Puppet.debug("get_stream_id: stream name is= #{stream_name}")
    streams = self.class.generic_get('/streams')['streams']
    streams.each do |stream|
      if stream['title'] == stream_name
        return stream['id']
      end
    end
    return nil
  end

  def self.get_streamrules
    streamrules = []
    gl_streams = self.generic_get('/streams')['streams']
    id_table = self.get_id_table()
    gl_streams.each do |gl_stream|
      # There's a prefix for resources that are not taken into consideration
      ignore_stream = false
      @stream_bypass_prefixes.each do |prefix|
        if Regexp.new('^' + prefix).match(gl_stream['title'])
          ignore_stream = true
          break
        end
      end
      unless ignore_stream
        gl_stream['rules'].each do |rule|
          streamrule = {
            'stream'   => gl_stream['title'],
            'id'       => rule['id'],
            'field'    => rule['field'],
            'type'     => rule['type'],
            'inverted' => rule['inverted'],
            'value'    => rule['value'],
          }
          # Matching streamrule id with a streamname_rulename from the id_file
          id_table.each do |name, id|
            if id == rule['id']
              streamrule['title'] = name
              streamrule['rule_name'] = name.split(':')[1]
              break
            end
          end
          # if it does not find any name, it composes it as streamname_ruleid_#{ruleID}
          if streamrule['title'].nil?
            streamrule['title'] = "#{gl_stream['title']}:ruleid_#{rule['id']}"
            streamrule['rule_name'] = "ruleid_#{rule['id']}"
          end
          streamrules << streamrule
        end
      end
    end
    return streamrules
  end

  def create_streamrule(name, element_properties)
    stream_id = get_stream_id(name.split(':')[0])
    streamrule_id = self.generic_post("/streams/#{stream_id}/rules", element_properties)['streamrule_id']
    add_rule_mapping(name, streamrule_id)
    return streamrule_id
  end

  def modify_streamrule(name, rule_id, element_properties)
    stream_id = get_stream_id(name.split(':')[0])
    Puppet.debug("modify_streamrule: body of the put call=\n#{element_properties.pretty_inspect}")
    self.generic_put("/streams/#{stream_id}/rules/#{rule_id}", element_properties)
  end

  def delete_streamrule(name, rule_id)
    stream_id = get_stream_id(name.split(':')[0])
    self.generic_del("/streams/#{stream_id}/rules/#{rule_id}")
    del_rule_mapping(name)
  end

  # This method collects on the node all existing instances of the things that this provider can manage.
  # Regardless of wheter there's a corresponding resource declaration in a manifest.
  # This should represent the 'is' state on a node.
  # The method should return an array of provider-instances.
  # Create a new instance with: new(:name => name, :property1 => current_state)
  def self.instances
    Puppet.debug('self.instances: retrieving stream rules')
    resources = []
    gl_streamrules = self.get_streamrules()
    gl_streamrules.each do |gl_streamrule|
      element_properties = {
        :name       => gl_streamrule['title'],
        :ensure     => :present,
        :stream     => gl_streamrule['stream'],
        :rule_name  => gl_streamrule['rule_name'],
        :graylog_id => gl_streamrule['id'],
        :field      => gl_streamrule['field'],
        :comp_type  => gl_streamrule['type'].to_s,
        :value      => gl_streamrule['value'],
        :inverted   => self.convert_bool_to_symbol(gl_streamrule['inverted']),
      }
      Puppet.debug("self.instances: resource found=\n#{element_properties.pretty_inspect}")
      resources << new(element_properties)
    end
    Puppet.debug('self.instances: number of resources= ' + resources.length.to_s)
    return resources
  end

  # Function called at the end to apply all changes
  def flush
    Puppet.debug("flush: graylog2_streamrule #{resource[:name]}")
    case @property_hash[:ensure]
    # if ensure is absent, we delete the stream
    when :absent
      Puppet.debug("flush: graylog2_streamrule #{resource[:name]} to be removed")
      delete_streamrule(@property_hash[:name], @property_hash[:graylog_id])
    when :present
      Puppet.debug("flush: update params:\n#{@property_hash.pretty_inspect}")
      element_properties = {
        :field    => @property_hash[:field],
        :type     => @property_hash[:comp_type].to_i,
        :inverted => convert_symbol_to_bool(@property_hash[:inverted]),
        :value    => @property_hash[:value],
      }
      # if the resource is new, we have to create the stream
      if @property_hash[:new]
        @property_hash[:graylog_id] = create_streamrule(@property_hash[:name], element_properties)
      # if the resource is not new, we have to modify the stream... PUT changes
      else
        modify_streamrule(@property_hash[:name], @property_hash[:graylog_id], element_properties)
      end
    end
  end
end
