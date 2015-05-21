class mirebalais_reporting::reporting_setup (
	$openmrs_db = hiera('openmrs_db'),
  	$openmrs_db_user = decrypt(hiera('openmrs_db_user')),
  	$openmrs_db_password = decrypt(hiera('openmrs_db_password')),
	$backup_db_password = decrypt(hiera('backup_db_password')),
	$sysadmin_email = hiera('sysadmin_email')
) {
	
	# note that public/private key sharing needs to be set up manually between production and reporting
	user { backups:
    		ensure => 'present',
    		home   => "/home/backups",
    		shell  => '/bin/sh',
  	}

	file { 'mirebalaisreportingdbsource.sh':
	    ensure  => present,
	    path    => '/usr/local/sbin/mirebalaisreportingdbsource.sh',
	    mode    => '0700',
	    owner   => 'root',
	    group   => 'root',
	    content => template('mirebalais_reporting/mirebalaisreportingdbsource.sh.erb'),
	  }

	  package { 'p7zip-full':
	  	  ensure => 'installed'
	  }

	  cron { 'mirebalais-reporting-db-source':
	    ensure  => present,
	    command => '/usr/local/sbin/mirebalaisreportingdbsource.sh > /dev/null',
	    user    => 'root',
	    hour    => 5,
	    minute  => 00,
	    environment => 'MAILTO=${sysadmin_email}',
	    require => [ File['mirebalaisreportingdbsource.sh'], Package['p7zip-full'] ]
	  }
}
