# needed to load the common file lib/puppet/provider/graylog2.rb
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'graylog2'))

Puppet::Type.type(:graylog2_role).provide(:graylog2, :parent => Puppet::Provider::Graylog2) do

  desc 'Support for graylog roles.'

  # creates a bunch of getters/setters for our properties/parameters
  # it is only for prefetch/flush providers
  # gets properties from @property_hash which contains the 'is' state of the resource
  mk_resource_methods

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

  def self.get_roles
    return self.generic_get('/roles')['roles']
  end

  def create_role(element_properties)
    self.generic_post('/roles', element_properties)
  end

  def modify_role(role_name, element_properties)
    Puppet.debug("modify_role: body of the put call=\n#{element_properties.pretty_inspect}")
    self.generic_put("/roles/#{role_name}", element_properties)
  end

  def delete_role(role_name)
    self.generic_del("/roles/#{role_name}")
  end


  # This method collects on the node all existing instances of the things that this provider can manage.
  # Regardless of wheter there's a corresponding resource declaration in a manifest.
  # This should represent the 'is' state on a node.
  # The method should return an array of provider-instances.
  # Create a new instance with: new(:name => name, :property1 => current_state)
  def self.instances
    Puppet.debug('self.instances: retrieving roles')
    resources = []
    gl_roles = self.get_roles()
    gl_roles.each do |gl_role|
      ignore_role = false
      # roles Admin and Reader are ignored. they are read-only roles, cannot be modified/deleted
      if gl_role['name'] == 'Admin' || gl_role['name'] == 'Reader'
        ignore_role = true
      end
      unless ignore_role
        element_properties = {
          :name         => gl_role['name'],
          :ensure       => :present,
          :description  => gl_role['description'],
          :permissions  => [],
          :read_streams => [],
        }
        gl_role['permissions'].each do |permission|
          if /^streams:read:/.match(permission)
            # queries the name of the stream and puts it in the read_streams list
            #for ruby 2.0.0!= element_properties[:read_streams] << self.generic_get("/streams/#{permission.byteslice(13..-1)}")['title']
            stream_name = self.generic_get("/streams/#{permission[13..-1]}")['title']
            if stream_name
              element_properties[:read_streams] << stream_name
            else
              element_properties[:read_streams] << "stream_id_#{permission[13..-1]}"
            end
          else
            element_properties[:permissions] << permission
          end
        end
        Puppet.debug("self.instances: resource found=\n#{element_properties.pretty_inspect}")
        resources << new(element_properties)
      end
    end
    Puppet.debug('self.instances: number of resources= ' + resources.length.to_s)
    return resources
  end

  # Function called at the end to apply all changes
  def flush
    Puppet.debug("flush: graylog2_role #{resource[:name]}")
    case @property_hash[:ensure]
    # if ensure is absent, we delete the role
    when :absent
      Puppet.debug("flush: graylog2_role #{resource[:name]} to be removed")
      delete_role(resource[:name])
    when :present
      Puppet.debug("flush: update params:\n#{@property_hash.pretty_inspect}")
      element_properties = {
        :name        => resource[:name],
        :description => @property_hash[:description],
        :permissions => @property_hash[:permissions],
      }
      @property_hash[:read_streams].each do |stream_name|
        stream_id = get_stream_id(stream_name)
        if stream_id.nil?
          fail('flush: stream name is invalid!')
        end
        element_properties[:permissions] << "streams:read:#{stream_id}"
      end
      # if the resource is new, we have to create the role
      if @property_hash[:new]
        #we add the name and password, which are not included for modifications, only for creation
        create_role(element_properties)
      # if the resource is not new, we have to modify the user... PUT changes
      else
        modify_role(@property_hash[:name], element_properties)
      end
    end
  end

end
