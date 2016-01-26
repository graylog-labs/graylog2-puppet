Puppet::Type.newtype(:graylog2_role) do
  @doc = 'Manage roles for Graylog.'

  ensurable

  autorequire(:service) { 'graylog-server' }

  newparam(:name) do
    desc 'Role name.'
  end

  newproperty(:description) do
    desc 'Role description.'
  end

  # the argument :array_matching => :all insures that it takes all elements
  # of the array. default is 'first', which takes only the first one.
  newproperty(:permissions, :array_matching => :all) do
    desc 'Role permissions.'
    defaultto []
  end
# WARNING: with this setup, empty arrays are ignored... so, changes like ['somethig'] -> []
# are ignored.. documented here: https://projects.puppetlabs.com/issues/10237
  newproperty(:read_streams, :array_matching => :all) do
    desc 'Streams which the role can read.'
    defaultto []
  end

end
