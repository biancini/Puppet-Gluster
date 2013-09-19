define garrbox::volume (
  $volume_name = undef,
  $brick_dir   = undef, 
  $quota       = undef,
) {
  
  $name_split = split($name, "=")
  
  if $volume_name == undef {
    $current_volname = $name_split[0]
  } else {
    $current_volname = $volume_name
  }
  
  if $brick_dir == undef {
    $current_brickdir = concat("/media/", $name_split[0])
  } else {
    $current_brickdir = $brick_dir
  }
  
  if $quota == undef {
    $current_quota = $name_split[1]
  } else {
    $current_quota = 10
  }

  file { $current_brickdir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => 0755,
  }
  
  glusterfs::volume { $current_volname:
    #create_options => "replica 2 10.0.0.140:${current_brickdir} 10.0.0.141:${current_brickdir}",
    create_options => "10.0.0.145:${current_brickdir}",
  } ->
  
  exec { "${current_volname}-quota-on":
    command => "gluster volume quota ${current_volname} enable",
    onlyif  => "gluster volume quota ${current_volname} list | egrep 'disabled'",
    path    => [ '/usr/sbin', '/usr/bin', '/sbin', '/bin' ],
  } ->
  
  exec { "${current_volname}-quota":
    command => "gluster volume quota ${current_volname} limit-usage / ${current_quota}GB",
    unless  => "gluster volume quota ${current_volname} list | egrep '^/.*${current_quota}GB'",
    path    => [ '/usr/sbin', '/usr/bin', '/sbin', '/bin' ],
  }
  
}
