class garrbox::mounts (
  $api_host    = 'http://localhost',
) {
  
  $volumes_hash = listvolumes($api_host, true)
  $volume_list = keys($volumes_hash)
  
  garrbox::mount { $volume_list:
    all_volumes => $volumes_hash,
    require     => Package['ruby-json', 'libjson-ruby'],
  }
  
}
