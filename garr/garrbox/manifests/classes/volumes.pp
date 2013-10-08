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
  $newvolumes_hash = listvolumes($api_host, false, false)
  notice("Volume list ${newvolumes_hash}")
  $newvolume_list = keys(newvolumes_hash)
  notice("Volume list ${newvolume_list}")
	
  garrbox::volume { $newvolume_list:
    all_volumes => $newvolumes_hash,
    api_host    => $api_host,
    api_user    => $api_user,
    api_passwd  => $api_passwd,
    operation   => 'create',
    require     => [Package['ruby-json', 'libjson-ruby'], Class['glusterfs::server']],
  }
  
  # Add bricks to existing volumes
  $addvolumes_hash = listvolumes($api_host, false, true)
  notice("Volume list ${addvolumes_hash}")
  $addvolume_list = keys($addvolumes_hash)
  notice("Volume list ${addvolume_list}")
  
  garrbox::volume { $addvolume_list:
    all_volumes => $addvolumes_hash,
    api_host    => $api_host,
    api_user    => $api_user,
    api_passwd  => $api_passwd,
    operation   => 'addbrick',
    require     => [Package['ruby-json', 'libjson-ruby'], Class['glusterfs::server']],
  }
  
}
