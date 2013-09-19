class garrbox::volumes () {
  
  $volume_list = listvolumes('root', 'ciaopuppet')
  
  class { 'glusterfs::server':
	  peers => $::hostname ? {
	    'cloud-mi-03'             => undef,
	    'owncloud-01.example.com' => '10.0.0.141',
	    'owncloud-02.example.com' => '10.0.0.140',
	    default => undef,
	  },
	}
	
  garrbox::volume { $volume_list:
    quota => 10,
    require => Class['glusterfs::server'],
  }
  
}
