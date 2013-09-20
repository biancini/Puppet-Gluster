node 'cloud-mi-03.mib.infn.it' {
	class { "garrbox::volumes":
		dbuser   => 'root',
		dbpasswd => 'ciaopuppet',
		dbhost   => '10.0.0.165',
	}

	class { "garrbox::mounts":
		dbuser   => 'root',
		dbpasswd => 'ciaopuppet',
		dbhost   => '10.0.0.165',
	}
}

