class garrbox::mounts (
  $dbuser      = undef,
  $dbpasswd    = undef,
  $dbhost      = '127.0.0.1',
  $dbname      = 'garrbox',
  $tabnamev    = 'volumes',
  $tabnameb    = 'bricks',
  $colstatus   = 'status',
  $colname     = 'name',
) {
  
  $volume_list = listvolumes($dbuser, $dbpasswd, true, $dbhost, $dbname, $tabnamev, $colstatus, $colname)
  
  garrbox::mount { $volume_list:
    
  }
  
}
