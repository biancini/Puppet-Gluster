module Puppet::Parser::Functions
  newfunction(:listbricks, :type => :rvalue, :doc => <<-EOS
This function generates a list of Gluster bricks by host or by volume interrogating a MySQL database.
Paremeters to this function are:

  - the user to be used for connection
  - the password to be used for connection
  - the field to be used as a filter (can either be 'volume' or 'host')
  - the value to be used as a filter
  - the database host (defaults to '127.0.0.1')
  - the database name  (defaults to 'garrbox')
  - the table name  (defaults to 'bricks')
  - the column name for the status column  (defaults to 'status')
  - the column name for the volname column  (defaults to 'volname')
  - the column name for the host column (defaults to 'host')
  - the column name for the brickdir column (defaults to 'brickdir')

*Examples:*

    listbricks("userdb", "password", "volume", "volprova1")

Would result in: "10.0.0.1:/media/brick1 10.0.0.2:/media/brick2"

    listbricks("userdb", "password", "host", "10.0.0.1")

Would result in: [ "/media/brick1", "/media/brick2" ]
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "listbricks(): Wrong number of arguments " +
      "given (#{arguments.size} for 4)") if arguments.size < 4

    dbuser      = arguments[0]
    dbpasswd    = arguments[1]
    filterf     = arguments[2]
    filterv     = arguments[3]
    
    dbhost      = '127.0.0.1'
    dbname      = 'garrbox'
    tabname     = 'bricks'
    colstatus   = 'status'
    colvolname  = 'volname'
    colhost     = 'host'
    colbrickdir = 'brickdir' 
    
    dbhost      = arguments[4] if arguments[4]
    dbname      = arguments[5] if arguments[5]
    tabname     = arguments[6] if arguments[6]
    colstatus   = arguments[7] if arguments[7]
    colvolname  = arguments[8] if arguments[8]
    colhost     = arguments[9] if arguments[9]
    colbrickdir = arguments[10] if arguments[10]

	require 'mysql'
	
    begin
      db = Mysql.new(dbhost, dbuser, dbpasswd, dbname)
    
      if filterf == 'host'
      	results = db.query "SELECT distinct #{colbrickdir} FROM #{tabname} WHERE #{colhost} = '#{filterv}'"

		returnval = []
      	results.each_hash do |row|
      		returnval.push(row[colbrickdir])
      	end
      	results.free
      elsif filterf == 'volume'
      	results = db.query "SELECT * FROM #{tabname} WHERE #{colstatus} = 1 AND #{colvolname} = '#{filterv}'"
      	
      	returnval = ""
      	results.each_hash do |row|
      		returnval = returnval + row[colhost] + ":" + row[colbrickdir]
      	end
      	results.free
      	
      	returnval = returnval.strip
      end
    ensure
      db.close
    end

	return returnval
  end
end
