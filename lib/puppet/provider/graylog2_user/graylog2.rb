# needed to load the common file lib/puppet/provider/graylog2.rb
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'graylog2'))

Puppet::Type.type(:graylog2_user).provide(:graylog2, :parent => Puppet::Provider::Graylog2) do

  desc 'Support for graylog users.'

  # creates a bunch of getters/setters for our properties/parameters
  # it is only for prefetch/flush providers
  # gets properties from @property_hash which contains the 'is' state of the resource
  mk_resource_methods

  def self.get_users
    return self.generic_get('/users')['users']
  end

  def create_user(element_properties)
    self.generic_post('/users', element_properties)
  end

  def modify_user(username, element_properties)
    Puppet.debug("modify_user: body of the put call=\n#{element_properties.pretty_inspect}")
    self.generic_put("/users/#{username}", element_properties)
  end

  def modify_user_passwd(username, element_properties)
    Puppet.debug("modify_user_passwd: body of the put call=\n#{element_properties.pretty_inspect}")
    self.generic_put("/users/#{username}/password", element_properties)
  end

#Permissions are commented for the moment and will probably be obsolete for next versions of Graylog (see type/graylog2_user.rb)

#  def modify_user_permissions(username, element_properties)
#    Puppet.debug("modify_user_permissions: body of the put call=\n#{element_properties.pretty_inspect}")
#    self.generic_put("/users/#{username}/permissions", element_properties)
#  end

  def modify_user_roles(username, element_properties)
    Puppet.debug("modify_user_roles: body of the put call=\n#{element_properties.pretty_inspect}")
    self.generic_put("/users/#{username}/roles", element_properties)
  end

  def delete_user(username)
    self.generic_del("/users/#{username}")
  end


  # This method collects on the node all existing instances of the things that this provider can manage.
  # Regardless of wheter there's a corresponding resource declaration in a manifest.
  # This should represent the 'is' state on a node.
  # The method should return an array of provider-instances.
  # Create a new instance with: new(:name => name, :property1 => current_state)
  def self.instances
    Puppet.debug('self.instances: retrieving users')
    resources = []
    gl_users = self.get_users()
    gl_users.each do |gl_user|
      ignore_user = false
      # user admin is ignored. it is a read-only user, cannot be modified/deleted
      if gl_user['username'] == 'admin'
        ignore_user = true
      else
        # There's a prefix for resources that are not taken into consideration
        @user_bypass_prefixes.each do |prefix|
          if Regexp.new('^' + prefix).match(gl_user['username'])
            ignore_user = true
            break
          end
        end
      end
      unless ignore_user
        element_properties = {
          :name               => gl_user['username'],
          :ensure             => :present,
          :graylog_id         => gl_user['id'],
          :email              => gl_user['email'],
          :full_name          => gl_user['full_name'],
          :session_timeout_ms => gl_user['session_timeout_ms'],
          :timezone           => gl_user['timezone'],
          :can_self_edit      => :false,
          :can_change_passwd  => :false,
          :roles              => gl_user['roles'],
        }
        gl_user['permissions'].each do |permission|
          if permission == "users:edit:#{gl_user['username']}"
            element_properties[:can_self_edit] = :true
          elsif permission == "users:passwordchange:#{gl_user['username']}"
            element_properties[:can_change_password] = :true
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
    Puppet.debug("flush: graylog2_user #{resource[:name]}")
    case @property_hash[:ensure]
    # if ensure is absent, we delete the user
    when :absent
      Puppet.debug("flush: graylog2_user #{resource[:name]} to be removed")
      delete_user(resource[:name])
    when :present
      Puppet.debug("flush: update params:\n#{@property_hash.pretty_inspect}")
      element_properties = {
        :full_name   => @property_hash[:full_name],
        :permissions => [],
        :roles       => @property_hash[:roles], #possible TODO check if Role exists
      }
      if !@property_hash[:email].nil?
        if @property_hash[:email] != ""
          element_properties[:email] = @property_hash[:email]
        end
      end
      element_properties[:session_timeout_ms] = @property_hash[:session_timeout_ms] unless @property_hash[:session_timeout_ms].nil?
      element_properties[:timezone] = @property_hash[:timezone] unless @property_hash[:timezone].nil?
      #permissions to add if the user can manage her own account
      if @property_hash[:can_self_edit] == :true
        element_properties[:permissions] << "users:edit:#{resource[:name]}"
      end
      if @property_hash[:can_change_passwd] == :true
        element_properties[:permissions] << "users:passwordchange:#{resource[:name]}"
      end
      # if the resource is new, we have to create the user
      if @property_hash[:new]
        #we add the username and password, which are not included for modifications, only for creation
        element_properties[:username] = resource[:name]
        element_properties[:password] = resource[:password]
        create_user(element_properties)
      # if the resource is not new, we have to modify the user... PUT changes
      else
        modify_user(@property_hash[:name], element_properties)
      end
    end
  end

end
