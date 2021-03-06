require 'openssl'
require 'open-uri'
require 'json'

module Puppet::Parser::Functions
  newfunction(:listbricks, :type => :rvalue, :doc => <<-EOS
This function generates a list of Gluster bricks by host or by volume interrogating a MySQL database.
Paremeters to this function are:

  - the url_base to be used for queries to the REST API
  - the field to be used as a filter
  - the value to be used as a filter

*Examples:*

    listbricks("http://localhost", "newvolume", "volprova1")

Would result in: "10.0.0.1:/media/brick1 10.0.0.2:/media/brick2"

    listbricks("http://localhost", "host", "10.0.0.1")

Would result in: [ "/media/brick1", "/media/brick2" ]
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "listbricks(): Wrong number of arguments " +
      "given (#{arguments.size} for 3)") if arguments.size < 3

    api_host    = arguments[0]
    filterf     = arguments[1]
    filterv     = arguments[2]
    
    debug "Called function with parameters: filterf = #{filterf}, filterv = #{filterv}, api_host = #{api_host}"
    
    begin
      ::OpenSSL::SSL.const_set :VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE
    
      volumes = {}
      uri = URI.parse("#{api_host}/garrbox/api/volumes")
      debug "Opening URL: #{uri}"
      uri.open { |response|
        volumes = JSON.parse(response.read())
      }
    
      if filterf == 'host'
	    returnval = []
        volumes.each do |name, vol|
          vol['bricks'].each do |brick|
            if brick['status'] == 'NEW' and brick['host'] == filterv
              returnval.push(brick['brick_dir'])
            end
          end
        end
      elsif filterf == 'newvolume'
        returnval = ""
        volumes.each do |name, vol|
          if name == filterv and vol['status'] == 'NEW'
            allbricks = true
            vol['bricks'].each do |brick|
              if brick['status'] == 'EXS' or brick['status'] == 'ACT'
                returnval = returnval + ' ' + brick['host'] + ":" + brick['brick_dir']
              else
                allbricks = false
              end
            end
            returnval = '' unless allbricks
          end
        end
      	
        returnval = returnval.strip
      elsif filterf == 'oldvolume'
        returnval = ""
        volumes.each do |name, vol|
          if name == filterv and vol['status'] == 'ACT'
            allbricks = true
            vol['bricks'].each do |brick|
              if brick['status'] == 'EXS'
                returnval = returnval + ' ' + brick['host'] + ":" + brick['brick_dir']
              end
            end
          end
        end
      	
        returnval = returnval.strip
      end
      
      debug "Returned value = #{returnval}"
	  return returnval
    rescue
      raise(Puppet::ParseError, "Missing required ruby packages.")
    end
  end
end
