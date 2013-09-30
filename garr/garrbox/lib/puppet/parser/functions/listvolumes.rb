module Puppet::Parser::Functions
  newfunction(:listvolumes, :type => :rvalue, :doc => <<-EOS
This function generates a list of Gluster volumes to be created by interrogating a MySQL database.
Paremeters to this function are:

  - a flag indicating if the query is for mount purpose (defaults to false)
  - the url_base to be used for queries to the REST API (defaults to 'http://localhost')

*Examples:*

    listvolumes()

Would result in: { 'testvolume1' => {'quota' => 10}, 'testvolume2' => {'quota' => 5} }
    EOS
  ) do |arguments|

    mountlist = false
    api_host  = 'http://localhost'
    
    mountlist = arguments[0] if arguments[0]
    api_host  = arguments[1] if arguments[1]
    Puppet.debug("Called function with parameters: mountlist = #{mountlist}, api_host = #{api_host}")

    require 'open-uri'
    require 'json'
    
    Puppet.debug("Opening URL: #{api_host}/garrbox/volumes")
    response = open("#{api_host}/garrbox/volumes")
    volumes = JSON.parse(response.read())
    Puppet.debug("URL opened")
      
    if mountlist
      returnval = {}
      volumes.each do |name, vol|
        if volumes['status'] == 'NEW'
          returnval[name] = {}
          returnval[row[colname]]['name'] = name
          returnval[row[colname]]['mountpoint'] = vol['mountpoint']
        end
      end
    else
      returnval = {}
      volumes.each do |name, vol|
        if volumes['status'] == 'ACT'
          returnval[name] = {}
          returnval[row[colname]]['name'] = name
          returnval[row[colname]]['quota'] = none
          vol['properties'].each do |prop|
            if prop['key_name'] == 'quota_dir'
              returnval[row[colname]]['quota'] = prov['base_value']
            end
          end
        end
      end
	end

	Puppet.debug("Returned value = #{returnval}")
	return returnval
  end
end
