define garrbox::brick (
  $api_host    = 'http://localhost',
  $operation   = 'create',
  $api_user    = undef,
  $api_passwd  = undef,
) {
  
  if ($operation == 'create') {
	  file { $name:
	    ensure => directory,
	    owner  => 'root',
	    group  => 'root',
	    mode   => 0755,
	  } ->
	  
	  post_restapi { "Update DB brick $name":
	    url               => "${api_host}/garrbox/api/bricks",
	    body              => "{'status' => 'EXS', 'host' => '${ipaddress}', 'brick_dir' => '${name}'}",
	    user              => $api_user,
	    password          => $api_passwd,
	    check_field_name  => "['${ipaddress}:${name}']['status']",
	    check_field_value => "'EXS'",
	    check_different   => true,
	  }
  } elsif ($operation == 'activate') {
	  post_restapi { "Activate DB brick $name":
	    url               => "${api_host}/garrbox/api/bricks",
	    body              => "{'status' => 'ACT', 'host' => '${ipaddress}', 'brick_dir' => '${name}'}",
	    user              => $api_user,
	    password          => $api_passwd,
	    check_field_name  => "['${ipaddress}:${name}']['status']",
	    check_field_value => "'ACT'",
	    check_different   => true,
	  }
  }
  
}
