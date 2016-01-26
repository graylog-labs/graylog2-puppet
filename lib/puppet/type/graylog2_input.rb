Puppet::Type.newtype(:graylog2_input) do
  @doc = 'Manage inputs for Graylog.'

  ensurable

  autorequire(:file) { '/var/lib/puppet/module_data/graylog2/types_conf.yaml' }
  autorequire(:service) { 'graylog-server' }

  validate do
    validate_required(:input_type, :config)
  end

  newparam(:name) do
    desc 'Input title.'
  end

  newproperty(:graylog_id) do
    desc 'Input ID in Graylog (read-only).'
    validate do |val|
      fail 'graylog_id is read-only'
    end
  end

  newproperty(:input_type) do
    desc 'Input type.'
  end

  newproperty(:global) do
    desc 'Global to the cluster or local to the node.'
    defaultto :false
    newvalues(:true, :false)
  end

  newproperty(:state) do
    desc 'Input state (running, stopped, etc.).'
    defaultto 'RUNNING'
    newvalues('RUNNING', 'STOPPED')
  end

  newproperty(:config) do
    desc 'Input configuration.'
    munge do |prop_hash|
      # convert values to strings
      prop_hash.each { |k, v| prop_hash[k] = v.to_s }
    end
    def insync?(is)
      is.sort == should.sort
    end
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
