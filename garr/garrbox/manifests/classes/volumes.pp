class garrbox::volumes (
  $dbuser      = undef,
  $dbpasswd    = undef,
  $dbhost      = '127.0.0.1',
  $dbname      = 'garrbox',
  $tabnamev    = 'volumes',
  $tabnameb    = 'bricks',
  $colstatus   = 'status',
  $colname     = 'name',
  $colquota    = 'quota',
  $colvolname  = 'volname',
  $colhost     = 'host',
  $colbrickdir = 'brickdir',
) {
  
  $volumes_hash = listvolumes($dbuser, $dbpasswd, false, $dbhost, $dbname, $tabnamev, $colstatus, $colname, $colquota)
  $volume_list = keys($volumes_hash)
  
  class { 'glusterfs::server':
	  peers => $::hostname ? {
	    'cloud-mi-03'             => undef,
	    'owncloud-01.example.com' => '10.0.0.141',
	    'owncloud-02.example.com' => '10.0.0.140',
	    default => undef,
	  },
	}
	
	$create_bricks = listbricks($dbuser, $dbpasswd, 'host', $::ipaddress, $dbhost, $dbname, $tabnameb, $colstatus, $colvolname, $colhost, $colbrickdir)
  garrbox::brick { $create_bricks:
    dbuser      => $dbuser,
    dbpasswd    => $dbpasswd,
    dbhost      => $dbhost,
    dbname      => $dbname,
    tabnameb    => $tabnameb,
    colstatus   => $colstatus,
    colhost     => $colhost,
    colbrickdir => $colbrickdir,
  }
	
  garrbox::volume { $volume_list:
    dbuser      => $dbuser,
    dbpasswd    => $dbpasswd,
    all_volumes => $::volume_hash,
    dbhost      => $dbhost,
    dbname      => $dbname,
    tabnameb    => $tabnameb,
    tabnamev    => $tabnamev,
    colname     => $colname,
    colstatus   => $colstatus,
    colvolname  => $colvolname,
    colhost     => $colhost,
    colbrickdir => $colbrickdir,
    require     => Class['glusterfs::server'],
  }
  
}
