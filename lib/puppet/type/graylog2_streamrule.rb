Puppet::Type.newtype(:graylog2_streamrule) do
  @doc = 'Manage stream rules for Graylog.'

  ensurable

  autorequire(:file) { '/var/lib/puppet/module_data/graylog2/types_conf.yaml' }
  autorequire(:service) { 'graylog-server' }
  autorequire(:graylog2_stream) { self[:stream] }
  autorequire(:file) { '/var/lib/puppet/module_data/graylog2/streamrule_ids.yaml' }

  validate do
    validate_required(:stream, :rule_name)
  end

  newparam(:name, :namevar => true) do
    desc "Stream rule name (composite namevar 'stream:rule_name')."
  end

  newproperty(:stream, :namevar => true) do
    desc 'Stream this rule belongs to.'
    validate do |value|
      raise ArgumentError, 'Empty values are not allowed' if value == ''
    end
  end

  newproperty(:rule_name, :namevar => true) do
    desc 'Rule name'
    validate do |value|
      raise ArgumentError, 'Empty values are not allowed' if value == ''
    end
  end

  # Our title_patterns method for mapping titles to namevars for supporting
  # composite namevars.
  def self.title_patterns
    identity = lambda {|x| x}
    [
      [
        /^((.*):(.*))$/, # (()()) = three matches
        [
          [ :name,      identity ],
          [ :stream,    identity ],
          [ :rule_name, identity ],
        ]
      ]
    ]
  end

  newproperty(:graylog_id) do
    desc 'Stream Rule ID in Graylog.'
    validate do |val|
      fail 'graylog_id is read-only'
    end
  end

  newproperty(:field) do
    desc 'Field to be evaluated.'
  end

  newproperty(:comp_type) do
    desc 'Comparator type.'
  end

  newproperty(:inverted) do
    desc 'A NOT flag.'
    defaultto :false
    newvalues(:true, :false)
  end

  newproperty(:value) do
    desc 'Value to compare to.'
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
