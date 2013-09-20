module Puppet::Parser::Functions
  newfunction(:listvolumes, :type => :rvalue, :doc => <<-EOS
This function generates a list of Gluster volumes to be created by interrogating a MySQL database.
Paremeters to this function are:

  - the user to be used for connection
  - the password to be used for connection
  - a flag indicating if the query is for mount purpose
  - the database host (defaults to '127.0.0.1')
  - the database name  (defaults to 'garrbox')
  - the table name  (defaults to 'volumes')
  - the column name for the status column  (defaults to 'status')
  - the column name for the name column (defaults to 'name')
  - the column name for the quota column (defaults to 'quota')

*Examples:*

    listvolumes("userdb", "password")

Would result in: { 'testvolume1' => {'quota' => 10}, 'testvolume2' => {'quota' => 5} }
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "listvolumes(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size < 2

    dbuser    = arguments[0]
    dbpasswd  = arguments[1]
    
    mountlist = false
    dbhost    = '127.0.0.1'
    dbname    = 'garrbox'
    tabname   = 'volumes'
    colstatus = 'status'
    colname   = 'name'
    colquota  = 'quota'
    
    mountlist = arguments[2] if arguments[2]
    dbhost    = arguments[3] if arguments[3]
    dbname    = arguments[4] if arguments[4]
    tabname   = arguments[5] if arguments[5]
    colstatus = arguments[6] if arguments[6]
    colname   = arguments[7] if arguments[7]
    colquota  = arguments[8] if arguments[8]

	require 'mysql'
	
    begin
      db = Mysql.new(dbhost, dbuser, dbpasswd, dbname)
      
      if mountlist
        results = db.query "SELECT #{colname} FROM #{tabname} WHERE #{colstatus} = 1"
        factval = []

      	results.each_hash do |row|
	        factval.push(row[colname])
      	end
      else
      	results = db.query "SELECT * FROM #{tabname} WHERE #{colstatus} = 0"
      	factval = {}

      	results.each_hash do |row|
	        factval[row[colname]] = {}
    	    factval[row[colname]]['name'] = row[colname]
        	factval[row[colname]]['quota'] = row[colquota]
      	end
	  end
	  
      results.free
    ensure
      db.close
    end

	return factval
  end
end
