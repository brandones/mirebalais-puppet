class mirebalais_reporting::reporting_setup () {
	
	# note that public/private key sharing still needs to be set up manually between production and reporting
	user { backups:
    		ensure => 'present',
    		home   => "/home/backups",
    		shell  => '/bin/sh',
  	}
}
