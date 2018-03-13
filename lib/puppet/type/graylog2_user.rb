Puppet::Type.newtype(:graylog2_user) do
  @doc = 'Manage users for Graylog.'

  ensurable

  autorequire(:file) { '/home/puppet/graylog2_types_conf.yaml' }
  autorequire(:service) { 'graylog-server' }

  validate do
    validate_required(:email)
  end

  newparam(:name) do
    desc 'User name.'
  end

  newproperty(:graylog_id) do
    desc 'Input ID in Graylog (read-only).'
    validate do |val|
      fail 'graylog_id is read-only'
    end
  end

  newparam(:password) do
    desc 'User password.'
  end

  newproperty(:full_name) do
    desc 'User full name.'
  end

  newproperty(:email) do
    desc 'Email address of the user.'
    validate do |val|
      fail 'invalid email address' unless /^.*@.*$/.match(val)
    end
  end

  newproperty(:can_self_edit) do
    desc 'This flag determines if the user can edit her own profile.'
    defaultto :false
    newvalues(:true, :false)
  end

  newproperty(:can_change_passwd) do
    desc 'This flag determines if the user can change her own password.'
    defaultto :false
    newvalues(:true, :false)
  end

  newproperty(:session_timeout_ms) do
    desc 'The session timeout for this user (in milliseconds).'
    munge do |val|
      return val.to_i
    end
  end

  newproperty(:timezone) do
    desc 'User time zone.'
  end

# Permissions are commented because of an inconsistency in GL-API; when one creates a user with
# a given Role, the permissions attached to this role appear in further GET Calls to that user.
# this would confuse Puppet because the user was not declared with those permissions.
# The Graylog team says that direct permissions management through the user will be
# obsolete in the next versions, it should be done through roles

#  # the argument :array_matching => :all insures that it takes all elements
#  # of the array. default is 'first', which takes only the first one.
#  newproperty(:permissions, :array_matching => :all) do
#    desc 'User permissions.'
#    defaultto []
#  end

  newproperty(:roles, :array_matching => :all) do
    desc 'Role(s) attached to the user.'
    defaultto ['Reader']
  end


  newproperty(:read_streams, :array_matching => :all) do
    desc 'Streams which the user can read.'
    defaultto []
  end

  # helper method, pass required parameters
  def validate_required(*required_parameters)
    if self[:ensure] == :present
      required_parameters.each do |req_param|
        raise ArgumentError, "parameter '#{req_param}' is required" if self[req_param].nil?
      end
    end
  end

end
