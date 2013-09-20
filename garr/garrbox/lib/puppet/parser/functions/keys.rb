module Puppet::Parser::Functions
  newfunction(:keys, :type => :rvalue, :doc => <<-EOS
This function extract an array of keys from an hash.

*Examples:*

    keys({"apple" => "fruit", "carrot" => "vegetable"})

Would result in: ["apple", "carrot"]
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "keys(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    hash = arguments[0]
    
    unless hash.is_a?(Hash)
      raise(Puppet::ParseError, 'keys(): Requires hash to work with')
    end

    return hash.keys
  end
end
