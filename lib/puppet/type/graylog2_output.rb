Puppet::Type.newtype(:graylog2_output) do
  @doc = 'Manage outputs for Graylog.'

  ensurable

  autorequire(:file) { '/var/lib/puppet/module_data/graylog2/types_conf.yaml' }
  autorequire(:service) { 'graylog-server' }

  validate do
    validate_required(:output_type, :config)
  end

  newparam(:name) do
    desc 'Output title.'
  end

  newproperty(:graylog_id) do
    desc 'Output ID in Graylog.'
    validate do |val|
      fail 'graylog_id is read-only'
    end
  end

  newproperty(:output_type) do
    desc 'Output type.'
  end

  newproperty(:config) do
    desc 'Output configuration.'
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
