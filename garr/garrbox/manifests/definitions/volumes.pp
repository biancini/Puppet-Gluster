define garrbox::volumes () {
 
  # Install prerequisites
  #class { 'garrbox::prerequisites':
  #  stage      => 'prerequisites',
  #}

  # Install and configure Shibboleth SP from Internet2
  #class { 'garrbox::sp':
  #  default_idp         => $default_idp,
  #  additional_metadata => $additional_metadata,
  #  require             => Class['shib2sp::prerequisites'],
  #  stage               => 'install',
  #  notify              => Exec['shib2-shibd-restart', 'shib2-apache-restart'],
  #}
  
}
