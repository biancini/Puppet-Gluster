module Puppet::Parser::Functions
  newfunction(:listvolumes, :type => :rvalue, :doc => <<-EOS
This function generates a list of Gluster volumes to be created by interrogating a MySQL database.
Paremeters to this function are:

  - the user to be used for connection
  - the password to be used for connection
  - the database host (defaults to '127.0.0.1')
  - the database name  (defaults to 'garrbox')
  - the table name  (defaults to 'volumes')
  - the column name for the status column  (defaults to 'status')
  - the column name for the name column (defaults to 'name')
  - the column name for the quota column (defaults to 'quota')

*Examples:*

    listvolumes("userdb", "password")

Would result in: [ 'testvolume1', 'testvolume2' ]
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "concat(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size < 2

    dbuser    = arguments[0]
    dbpasswd  = arguments[1]
    
    dbhost    = '127.0.0.1'
    dbname    = 'garrbox'
    tabname   = 'volumes'
    colstatus = 'status'
    colname   = 'name'
    colquota  = 'quota'
    
    dbhost    = arguments[2] if arguments[2]
    dbname    = arguments[3] if arguments[3]
    tabname   = arguments[4] if arguments[4]
    colstatus = arguments[5] if arguments[5]
    colname   = arguments[6] if arguments[6]
    colquota  = arguments[7] if arguments[7]

	require 'mysql'
	
	factval = {}
    begin
      db = Mysql.new(dbhost, dbuser, dbpasswd, dbname)
      results = db.query "SELECT * FROM #{tabname} WHERE #{colstatus} = 0"

      results.each_hash do |row|
        factval[row[colname]] = row[colquota]
      end

      results.free
    ensure
      db.close
    end

	return factval.keys
  end
end
