define garrbox::brick (
  $api_host    = 'http://localhost',
) {
  
  file { $name:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => 0755,
  } #->
  
  #exec { "Update DB brick $name":
  #  command => "echo \"UPDATE ${tabnameb} SET ${colstatus} = 1 WHERE ${colhost} = '${ipaddress}' AND ${colbrickdir} = '${name}'\" | mysql -h ${dbhost} -u ${dbuser} --password=${dbpasswd} ${dbname}",
  #  path    => [ '/usr/sbin', '/usr/bin', '/sbin', '/bin' ],
  #  unless  => "echo \"SELECT * FROM ${tabnameb} WHERE ${colstatus} = 1 AND ${colhost} = '${ipaddress}' AND ${colbrickdir} = '${name}'\" | mysql -h ${dbhost} -u ${dbuser} --password=${dbpasswd} ${dbname} | grep ${name}",
  #}
  
}
