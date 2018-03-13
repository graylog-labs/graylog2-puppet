require 'json'

Puppet::Type.newtype(:graylog2_extractor) do
  @doc = 'Manage extractors for Graylog.'

  ensurable

  autorequire(:file) { '/var/lib/puppet/module_data/graylog2/types_conf.yaml' }
  autorequire(:service) { 'graylog-server' }
  autorequire(:graylog2_input) { self[:input] }

  validate do
    #TODO ASK PHILIPP validate_required(:input, :extractor_name, :source_field, :target_field, :converters) how to add more properties?
    validate_required(:input, :extractor_name)
  end

  newparam(:name, :namevar => true) do
    desc "Extractor name (composite namevar 'input:extractor_name')."
  end

  newproperty(:input, :namevar => true) do
    desc 'Input this extractor belongs to.'
    validate do |value|
      raise ArgumentError, 'Empty values are not allowed' if value == ''
    end
  end

  newproperty(:extractor_name, :namevar => true) do
    desc 'Extractor name'
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
          [ :name,           identity ],
          [ :input,          identity ],
          [ :extractor_name, identity ],
        ]
      ]
    ]
  end

  newproperty(:graylog_id) do
    desc 'Extractor ID in Graylog.'
    validate do |val|
      fail 'graylog_id is read-only'
    end
  end

  newproperty(:source_field) do
    desc 'Field to extract the value from.'
  end

  newproperty(:target_field) do
    desc 'Field to put the value to.'
  end

  newproperty(:extractor_type) do
    desc 'Extractor type (e.g., regex).'
    defaultto 'regex'
  end

  newproperty(:condition_type) do
    desc 'The type of condition.'
    defaultto 'none'
  end

  newproperty(:condition_value) do
    desc 'Condition value, default is empty.'
    defaultto ''
  end

  newproperty(:extractor_config) do
    desc 'The configuration of the extractor.'
    defaultto {}
  end

  newproperty(:cut_or_copy) do
    desc 'Cut out the value of the source field or not.'
    newvalues('cut', 'copy')
    defaultto 'copy'
  end

  newproperty(:converters) do
    desc 'The converters.'
    defaultto {}
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
