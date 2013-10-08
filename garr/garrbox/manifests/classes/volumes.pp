class garrbox::volumes (
  $api_host    = 'http://localhost',
  $api_user    = undef,
  $api_passwd  = undef,
) {
  
  # Install required packages and create GlusterFS ring
  class { 'glusterfs::server':
	  peers => $::hostname ? {
	    'cloud-mi-03'             => undef,
	    'owncloud-01.example.com' => '10.0.0.141',
	    'owncloud-02.example.com' => '10.0.0.140',
	    default => undef,
	  },
	}
	
	# Create bricks on the current server
	$create_bricks = listbricks($api_host, 'host', $::ipaddress)
	notice("Brick list ${create_bricks}")
  garrbox::brick { $create_bricks:
    api_host    => $api_host,
    api_user    => $api_user,
    api_passwd  => $api_passwd,
    operation   => 'create',
    require     => Package['ruby-json', 'libjson-ruby'],
  }
  
  # Create volumes
  $volumes_hash = listvolumes($api_host, false, false)
  notice("Volume list ${volumes_hash}")
  $volume_list = keys($volumes_hash)
  notice("Volume list ${volume_list}")
	
  garrbox::volume { $volume_list:
    all_volumes => $volumes_hash,
    api_host    => $api_host,
    api_user    => $api_user,
    api_passwd  => $api_passwd,
    operation   => 'create',
    require     => [Package['ruby-json', 'libjson-ruby'], Class['glusterfs::server']],
  }
  
  # Addd bricks to existing volumes
  $volumes_hash = listvolumes($api_host, false, true)
  notice("Volume list ${volumes_hash}")
  $volume_list = keys($volumes_hash)
  notice("Volume list ${volume_list}")
  
  garrbox::volume { $volume_list:
    all_volumes => $volumes_hash,
    api_host    => $api_host,
    api_user    => $api_user,
    api_passwd  => $api_passwd,
    operation   => 'addbrick',
    require     => [Package['ruby-json', 'libjson-ruby'], Class['glusterfs::server']],
  }
  
}
