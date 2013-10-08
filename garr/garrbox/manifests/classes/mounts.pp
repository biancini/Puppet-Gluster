class garrbox::mounts (
  $api_host    = 'http://localhost',
  $api_user    = undef,
  $api_passwd  = undef,
) {
  
  # Mount volumes
  $volumes_hash = listvolumes($api_host, true, false)
  $volume_list = keys($volumes_hash)
  
  garrbox::mount { $volume_list:
    all_volumes => $volumes_hash,
    require     => Package['ruby-json', 'libjson-ruby'],
  }
  
}
