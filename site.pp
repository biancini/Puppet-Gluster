node 'cloud-mi-03.mib.infn.it' {
	package { ['ruby-json', 'libjson-ruby']:
		ensure => present,
	}


	class { "garrbox::volumes":
		api_host   => 'http://cloud-mi-03.mib.infn.it/primologin',
		api_user   => undef,
                api_passwd => undef,
	}

	class { "garrbox::mounts":
		api_host   => 'http://cloud-mi-03.mib.infn.it/primologin',
		api_user   => undef,
                api_passwd => undef,
	}
}

