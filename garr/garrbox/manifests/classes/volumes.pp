class garrbox::volumes (
  $api_host    = 'http://localhost',
) {
  
  $volumes_hash = listvolumes(false, $api_host)
  $volume_list = keys($volumes_hash)
  
  class { 'glusterfs::server':
	  peers => $::hostname ? {
	    'cloud-mi-03'             => undef,
	    'owncloud-01.example.com' => '10.0.0.141',
	    'owncloud-02.example.com' => '10.0.0.140',
	    default => undef,
	  },
	}
	
	$create_bricks = listbricks('host', $::ipaddress, $api_host)
  garrbox::brick { $create_bricks:
    api_host    => $api_host,
  }
	
  garrbox::volume { $volume_list:
    all_volumes => $::volume_hash,
    api_host    => $api_host,
    require     => Class['glusterfs::server'],
  }
  
}
