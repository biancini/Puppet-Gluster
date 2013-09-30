module Puppet::Parser::Functions
  newfunction(:listvolumes, :type => :rvalue, :doc => <<-EOS
This function generates a list of Gluster volumes to be created by interrogating a MySQL database.
Paremeters to this function are:

  - a flag indicating if the query is for mount purpose (defaults to false)
  - the url_base to be used for queries to the REST API (defaults to 'http://127.0.0.1')

*Examples:*

    listvolumes()

Would result in: { 'testvolume1' => {'quota' => 10}, 'testvolume2' => {'quota' => 5} }
    EOS
  ) do |arguments|

    mountlist = false
    api_host  = 'http://127.0.0.1'
    
    mountlist = arguments[0] if arguments[0]
    api_host  = arguments[1] if arguments[1]

    require 'open-uri'
    require 'json'
    
    response = open("#{api_host}/garrbox/volumes")
    volumes = JSON.parse(response)
      
    if mountlist
      factval = {}
      volumes.each do |name, vol|
        if volumes['status'] == 'NEW'
          factval[name] = {}
          factval[row[colname]]['name'] = name
          factval[row[colname]]['mountpoint'] = vol['mountpoint']
        end
      end
    else
      factval = {}
      volumes.each do |name, vol|
        if volumes['status'] == 'ACT'
          factval[name] = {}
          factval[row[colname]]['name'] = name
          factval[row[colname]]['quota'] = none
          vol['properties'].each do |prop|
            if prop['key_name'] == 'quota_dir'
              factval[row[colname]]['quota'] = prov['base_value']
            end
          end
        end
      end
	end

	return factval
  end
end
