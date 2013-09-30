module Puppet::Parser::Functions
  newfunction(:listbricks, :type => :rvalue, :doc => <<-EOS
This function generates a list of Gluster bricks by host or by volume interrogating a MySQL database.
Paremeters to this function are:

  - the field to be used as a filter
  - the value to be used as a filter
  - the url_base to be used for queries to the REST API (defaults to 'http://127.0.0.1')

*Examples:*

    listbricks("volume", "volprova1", "http://127.0.0.1")

Would result in: "10.0.0.1:/media/brick1 10.0.0.2:/media/brick2"

    listbricks("host", "10.0.0.1", "http://localhost")

Would result in: [ "/media/brick1", "/media/brick2" ]
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "listbricks(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size < 2

    filterf     = arguments[0]
    filterv     = arguments[1]
    
    api_host    = 'http://localhost'
    api_host    = arguments[2] if arguments[2]
    Puppet.debug("Called function with parameters: filterf = #{filterf}, filterv = #{filterv}, api_host = #{api_host}")
    
    require 'open-uri'
    require 'json'
    
    Puppet.debug("Opening URL: #{api_host}/garrbox/volumes")
    response = open("#{api_host}/garrbox/volumes")
    volumes = JSON.parse(response.read())
    Puppet.debug("URL opened")
    
    if filterf == 'host'
	  returnval = []
      volumes.each do |name, vol|
        vol['bricks'].each do |brick|
          if brick['status'] == 'NEW' and brick['host'] == filterv
            returnval.push(brick['brick_dir'])
          end
        end
      end
    elsif filterf == 'volume'
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
    end

	Puppet.debug("Returned value = #{returnval}")
	return returnval
  end
end
