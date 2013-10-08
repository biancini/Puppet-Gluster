define garrbox::volume (
  $all_volumes = undef,
  $api_host    = 'http://localhost',
  $api_user    = undef,
  $api_passwd  = undef,
  $operation   = 'create',
) {
  
  if $all_volumes == undef {
    $current_volname = $name
    $current_quota = 10
  } else {
    $curvolume = $all_volumes[$name]
    
    if ($curvolume) {
      if $curvolume['name'] { $current_volname = $curvolume['name'] }
      else { $current_volname = $name }
      
      if $curvolume['quota'] { $current_quota = $curvolume['quota'] }
      else { $current_quota = 10 }
    } else {
      $current_volname = $name
      $current_quota = 10
    }
  }
  
  if $operation == "create" {
	  $newvolume_bricks = listbricks($api_host, 'newvolume', $current_volname)
	  notice("Volume bricks = ${newvolume_bricks}")
	  
	  if ($newvolume_bricks != '') {
	    $newbricks_array = splitbricklist($newvolume_bricks, $ipaddress) 
	    
		  glusterfs::volume { $current_volname:
		    #create_options => "replica 2 ${volume_bricks}",
		    create_options => $newbricks_array,
		  } ->
		
		  exec { "${current_volname}-quota-on":
		    command => "gluster volume quota ${current_volname} enable",
		    unless  => "gluster volume info ${current_volname} | grep 'features.quota: on'",
		    path    => [ '/usr/sbin', '/usr/bin', '/sbin', '/bin' ],
		  } ->
		  
		  exec { "${current_volname}-quota":
		    command => "gluster volume quota ${current_volname} limit-usage / ${current_quota}GB",
		    unless  => "gluster volume info ${current_volname} | grep 'features.limit-usage: /:${current_quota}GB'",
		    path    => [ '/usr/sbin', '/usr/bin', '/sbin', '/bin' ],
		  } ->
		  
		  post_restapi { "Update volume $name":
	      url               => "${api_host}/garrbox/api/volumes",
	      body              => "{ '${name}' => { 'status' => 'ACT' } }",
	      user              => $api_user,
	      password          => $api_passwd,
	      check_field_name  => "['${name}']['status']",
	      check_field_value => "'ACT'",
	      check_different   => true,
		  } ->
		  
		  garrbox::brick { $newbricks_array:
		    api_host    => $api_host,
		    api_user    => $api_user,
		    api_passwd  => $api_passwd,
		    operation   => 'activate',
		    require     => Package['ruby-json', 'libjson-ruby'],
		  }
	  }
  }
  elsif $operation == "addbrick" {
    $addvolume_bricks = listbricks($api_host, 'oldvolume', $current_volname)
    notice("Volume bricks = ${addvolume_bricks}")
    
    if ($addvolume_bricks != '') {
      $addbricks_array = splitbricklist($addvolume_bricks) 
      
      exec { "Add required bricks":
        command => "gluster volume add-brick ${current_volname} ${addbricks_array}",
        path    => [ '/usr/sbin', '/usr/bin', '/sbin', '/bin' ],
      } ->
      
      garrbox::brick { $addbricks_array:
        api_host    => $api_host,
        api_user    => $api_user,
        api_passwd  => $api_passwd,
        operation   => 'activate',
        require     => Package['ruby-json', 'libjson-ruby'],
      }
    }
  }
  
}
