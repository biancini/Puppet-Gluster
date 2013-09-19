Facter.add(:listvolumes) do
  setcode do
    require 'mysql'

    # parameters to be personalized depending on installation
    dbhost    = 'puppet.mib.garr.it'
    dbuser    = 'root'
    dbpasswd  = 'ciaopuppet'
    dbname    = 'garrbox'
    tabname   = 'volumes'
    colstatus = 'status'
    colname   = 'name'
    colquota  = 'quota'
    # end of parameters

    begin
      db = Mysql.new(dbhost, dbuser, dbpasswd, dbname)
      results = db.query "SELECT * FROM #{tabname} WHERE #{colstatus} = 0"
      debug("Number of mounts #{results.num_rows}")

      results.each_hash do |row|
        print "#{row[colname]ndare (}=#{row[quota]}"
      end

      results.free
    rescue Mysql::Error
      debug("Error while connecting to MySQL database."
    ensure
      db.close
    end

  end
end
