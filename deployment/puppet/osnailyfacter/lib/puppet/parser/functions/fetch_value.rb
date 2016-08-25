module Puppet::Parser::Functions
  newfunction(
      :fetch_value,
      :type => :rvalue,
      :arity => -2,
      :doc => <<-eos
Looks up into a complex structure of arrays and hashes and returns a value
or the default value if nothing was found.

Key can contain slashes to describe path components. The function will go down
the structure and try to extract the required value.

$data = {
  'a' => {
    'b' => [
      'b1',
      'b2',
      'b3',
    ]
  }
}

$value = dig44($data, ['a', 'b', '2'], 'not_found')
=> $value = 'b3'

a -> first hash key
b -> second hash key
2 -> array index starting with 0

not_found -> (optional) will be returned if there is no value or the path
did not match. Defaults to nil.

In addition to the required "key" argument, the function accepts a default
argument. It will be returned if no value was found or a path component is
missing. And the fourth argument can set a variable path separator.
  eos
  ) do |arguments|
    # Two arguments are required
    raise(Puppet::ParseError, "fetch_value(): Wrong number of arguments " +
                              "given (#{arguments.size} for at least 2)") if arguments.size < 2

    data, path, default = *arguments

    unless data.is_a?(Hash) or data.is_a?(Array)
      raise(Puppet::ParseError, "fetch_value(): first argument must be a hash or an array, " <<
                                "given #{data.class.name}")
    end

    unless path.is_a? Array
      raise(Puppet::ParseError, "fetch_value(): second argument must be an array, " <<
                                "given #{path.class.name}")
    end

    value = path.reduce(data) do |structure, key|
      if structure.is_a? Hash or structure.is_a? Array
        if structure.is_a? Array
          key = Integer key rescue break
        end
        break if structure[key].nil? or structure[key] == :undef
        structure[key]
      else
        break
      end
    end
    value.nil? ? default : value
  end
end