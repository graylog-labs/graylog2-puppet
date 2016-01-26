Puppet::Type.newtype(:graylog2_stream) do
  @doc = 'Manage streams for Graylog.'

  ensurable

  autorequire(:file) { '/var/lib/puppet/module_data/graylog2/types_conf.yaml' }
  autorequire(:service) { 'graylog-server' }

  newparam(:name) do
    desc 'Stream title.'
  end

  newproperty(:graylog_id) do
    desc 'Stream ID in Graylog.'
    validate do |val|
      fail 'graylog_id is read-only'
    end
  end

  newproperty(:disabled) do
    desc 'Stream disabled/enabled switch.'
    defaultto :true
    newvalues(:true, :false)
  end

  newproperty(:description) do
    desc 'Stream description.'
  end

  # the argument :array_matching => :all insures that it takes all elements
  # of the array. default is 'first', which takes only the first one.
  newproperty(:outputs, :array_matching => :all) do
    desc 'Outputs bound to this stream.'
    defaultto []
  end

end
