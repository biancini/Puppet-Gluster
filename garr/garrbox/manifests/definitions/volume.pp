define garrbox::volume (
  $all_volumes = undef,
  $api_host   = 'http://localhost',
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
  
  $volume_bricks = listbricks($api_host, 'volume', $current_volname)
  notice("Volume bricks = ${volume_bricks}")
  if ($volume_bricks != '') {
	  glusterfs::volume { $current_volname:
	    #create_options => "replica 2 ${volume_bricks}",
	    create_options => $volume_bricks,
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
      url               => "${api_host}/garrbox/volumes",
      body              => "{ '${name}': { 'status': 'ACT' } }",
      user              => 'basicuser',
      password          => 'password',
      check_field_name  => "['${name}']['status']",
      check_field_value => "'ACT'",
      check_different   => true,
	  }
  }
  
}
