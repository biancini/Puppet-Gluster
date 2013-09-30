define garrbox::mount (
  $all_volumes = undef,
) {
  
  if $all_volumes == undef {
    $current_volname = $name
    $current_mount = "/mnt/${name}"
  } else {
    $curvolume = $all_volumes[$name]
    
    if ($curvolume) {
      if $curvolume['name'] { $current_volname = $curvolume['name'] }
      else { $current_volname = $name }
      
      if $curvolume['mountpoint'] { $current_mount = $curvolume['mountpoint'] }
      else { $current_mount = "/mnt/${current_volname}" }
    } else {
      $current_volname = $name
      $current_mount = "/mnt/${name}"
    }
  }
  
  $mount_server = $::hostname ? {
    'cloud-mi-03'             => '10.0.0.145',
    'owncloud-01.example.com' => '10.0.0.141',
    'owncloud-02.example.com' => '10.0.0.140',
    default => undef,
  }
  
  file { $current_mount:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => 0755,
  } ->
  
  glusterfs::mount { $current_mount:
    device  => "${mount_server}:${name}",
    options => 'defaults,_netdev,log-level=WARNING,log-file=/var/log/gluster.log',
    ensure  => 'mounted',
  }
  
}
