class mirebalais_reporting::reporting_setup (
	$openmrs_db = hiera('openmrs_db'),
  	$openmrs_db_user = decrypt(hiera('openmrs_db_user')),
  	$openmrs_db_password = decrypt(hiera('openmrs_db_password')
) {
	
	# note that public/private key sharing still needs to be set up manually between production and reporting
	user { backups:
    		ensure => 'present',
    		home   => "/home/backups",
    		shell  => '/bin/sh',
  	}

	file { 'mysqlreportingdbsource.sh':
	    ensure  => present,
	    path    => '/usr/local/sbin/mysqlreportingsourcedbdump.sh',
	    mode    => '0700',
	    owner   => 'root',
	    group   => 'root',
	    content => template('mirebalais_reporting/mirebalaisreportingdbsource.sh.erb'),
	  }

	  cron { 'mysql-reporting-db-source':
	    ensure  => present,
	    command => '/usr/local/sbin/mysqlreportingdbsource.sh',
	    user    => 'root',
	    hour    => 5,
	    minute  => 00,
	    require => File['mysqlreportingdbsource.sh'],
	  }
}
