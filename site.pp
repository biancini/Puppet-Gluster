node 'cloud-mi-03.mib.infn.it' {
	class { "garrbox::volumes":
		api_host => 'http://localhost',
	}

	class { "garrbox::mounts":
		api_host => 'http://localhost',
	}
}

