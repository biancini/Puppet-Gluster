define garrbox::mount () {
  
  $mount_server = $::hostname ? {
    'cloud-mi-03'             => '10.0.0.145',
    'owncloud-01.example.com' => '10.0.0.141',
    'owncloud-02.example.com' => '10.0.0.140',
    default => undef,
  }
  
  $mount_dir = "/mnt/${name}"
  
  file { $mount_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => 0755,
  } ->
  
  glusterfs::mount { $mount_dir:
    device  => "${mount_server}:${name}",
    options => 'defaults,_netdev,log-level=WARNING,log-file=/var/log/gluster.log',
    ensure  => 'mounted',
  }
  
}
