define garrbox::brick (
  $api_host    = 'http://localhost',
  $api_user    = undef,
  $api_passwd  = undef,
) {
  
  file { $name:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => 0755,
  } ->
  
  post_restapi { "Update DB brick $name":
    url               => "${api_host}/garrbox/api/bricks",
    body              => "{'status': 'ACT', 'host': '${ipaddress}', 'brick_dir': '${name}'}",
    user              => $api_user,
    password          => $api_passwd,
    check_field_name  => "['${ipaddress}:${name}']['status']",
    check_field_value => "'ACT'",
    check_different   => true,
  }
  
  #exec { "Update DB brick $name":
  #  command => "echo \"UPDATE ${tabnameb} SET ${colstatus} = 1 WHERE ${colhost} = '${ipaddress}' AND ${colbrickdir} = '${name}'\" | mysql -h ${dbhost} -u ${dbuser} --password=${dbpasswd} ${dbname}",
  #  path    => [ '/usr/sbin', '/usr/bin', '/sbin', '/bin' ],
  #  unless  => "echo \"SELECT * FROM ${tabnameb} WHERE ${colstatus} = 1 AND ${colhost} = '${ipaddress}' AND ${colbrickdir} = '${name}'\" | mysql -h ${dbhost} -u ${dbuser} --password=${dbpasswd} ${dbname} | grep ${name}",
  #}
  
}
