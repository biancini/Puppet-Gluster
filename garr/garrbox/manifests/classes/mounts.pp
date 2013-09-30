class garrbox::mounts (
  $dbuser      = undef,
  $dbpasswd    = undef,
  $api_host    = 'http://localhost',
) {
  
  $volumes_hash = listvolumes(true, $api_host)
  $volume_list = keys($volumes_hash)
  
  garrbox::mount { $volume_list:
    all_volumes => $::volume_hash,
  }
  
}
