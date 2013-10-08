module Puppet::Parser::Functions
  newfunction(:listvolumes, :type => :rvalue, :doc => <<-EOS
This function generates a list of Gluster volumes to be created by interrogating a MySQL database.
Paremeters to this function are:

  - the url_base to be used for queries to the REST API
  - a flag indicating if the query is for mount purpose (defaults to false)

*Examples:*

    listvolumes('http://localhost')

Would result in: { 'testvolume1' => {'quota' => 10}, 'testvolume2' => {'quota' => 5} }
    EOS
  ) do |arguments|
  
    raise(Puppet::ParseError, "listvolumes(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    api_host  = arguments[0] if arguments[0]
    mountlist = false
    
    mountlist = arguments[1] if arguments[1]
    
    debug "Called function with parameters: mountlist = #{mountlist}, api_host = #{api_host}"

    begin
      require 'open-uri'
      require 'json'
    
      volumes = {}
      uri = URI.parse("#{api_host}/garrbox/api/volumes")
      debug "Opening URL: #{uri}"
      uri.open { |response|
        volumes = JSON.parse(response.read())
      }
      
      if mountlist
        returnval = {}
        volumes.each do |name, vol|
          if vol['status'] == 'ACT'
            returnval[name] = {}
            returnval[name]['name'] = name
            returnval[name]['mountpoint'] = vol['mountpoint']
          end
        end
      else
        returnval = {}
        volumes.each do |name, vol|
          if vol['status'] == 'NEW'
            returnval[name] = {}
            returnval[name]['name'] = name
            vol['properties'].each do |prop|
              if prop['key_name'] == 'quota_dir'
                returnval[name]['quota'] = prop['base_value']
              end
            end
          end
        end
	  end

	  debug "Returned value = #{returnval}"
	  return returnval
	rescue
      debug "Missing required ruby packages."
      return ""
    end
  end
end
