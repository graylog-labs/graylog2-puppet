Puppet::Type.newtype(:graylog2_staticfield) do
  @doc = 'Manage inputs for Graylog.'

  ensurable

  autorequire(:file) { '/var/lib/puppet/module_data/graylog2/types_conf.yaml' }
  autorequire(:service) { 'graylog-server' }
  autorequire(:graylog2_input) { self[:input] }

  validate do
    #TODO how to add value as variable here?
    validate_required(:input, :staticfield_key)
  end

  newparam(:name, :namevar => true) do
    desc "Static field name (composite namevar 'input:staticfield_key')."
  end

  newproperty(:input, :namevar => true) do
    desc 'Input this staticfield belongs to.'
    validate do |value|
      raise ArgumentError, 'Empty values are not allowed' if value == ''
    end
  end

  newproperty(:staticfield_key, :namevar => true) do
    desc 'Static field key.'
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
          [ :name,             identity ],
          [ :input,            identity ],
          [ :staticfield_key,  identity ],
        ]
      ]
    ]
  end

  newproperty(:value) do
    desc 'Value to put on the static field.'
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
