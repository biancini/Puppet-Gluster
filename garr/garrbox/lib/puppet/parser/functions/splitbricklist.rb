module Puppet::Parser::Functions
  newfunction(:splitbricklist, :type => :rvalue, :doc => <<-EOS
This function extract a brickdir array from a bricklist considering only bricks for the specified IP address.

*Examples:*

    splitbricklist("10.0.0.146:/media/volprova1 10.0.0.145:/media/volprova1", "10.0.0.145")

Would result in: ["/media/volprova1"]
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "splitbricklist(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size < 2

    bricklist = arguments[0]
    filterip = ''
    
    filterip  = arguments[1] if argument[1]
    
    returnval = []
    brickv = bricklist.split(' ')
    brickv.each do |curbrick|
      values = curbrick.split(':')
      if fitlerip != '' and values[0] == filterip
        returnval.push(values[1])
      end
    end
    
    return returnval
  end
end
