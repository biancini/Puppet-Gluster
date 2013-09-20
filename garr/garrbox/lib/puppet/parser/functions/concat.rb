module Puppet::Parser::Functions
  newfunction(:concat, :type => :rvalue, :doc => <<-EOS
This function concatenates two strings.

*Examples:*

    concat("Hello", "World")

Would result in: "HelloWorld"
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "concat(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size < 2

    prefix = arguments[0]
    suffix = arguments[1]

    return prefix + "" + suffix
  end
end