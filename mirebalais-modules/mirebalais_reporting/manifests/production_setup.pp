class mirebalais_reporting::production_setup (
    $backup_db_user = decrypt(hiera('backup_db_user')),
    $backup_db_password = decrypt(hiera('backup_db_password')),
    $tomcat = hiera('tomcat')
  ){

  file { 'mirebalaisreportingdbdump.sh':
    ensure  => present,
    path    => '/usr/local/sbin/mirebalaisreportingdbdump.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('mirebalais_reporting/mirebalaisreportingdbdump.sh.erb'),
  }

  # note that we don't install p7zip-full here because it is already installed as part of the mysql_setup::backup package

  cron { 'mysql-reporting-db-dump':
    ensure  => present,
    command => '/usr/local/sbin/mirebalaisreportingdbdump.sh >/dev/null',
    user    => 'root',
    hour    => 2,
    minute  => 30,
    environment => 'MAILTO=emrsysadmin@pih.org',
    require => [ File['mirebalaisreportingdbdump.sh'], Package['p7zip-full'] ]
  }

   

  file { 'mirebalaisreportscleanup.sh':
	ensure => present,
	path => '/usr/local/sbin/mirebalaisreportscleanup.sh',
	mode => '0700',
	owner => 'root',
	group => 'root',
	content => template('mirebalais_reporting/mirebalaisreportscleanup.sh.erb')
  }

  cron { 'mirebalais-reports-cleanup':
	ensure => present,
	command => '/usr/local/sbin/mirebalaisreportscleanup.sh >/dev/null',
	user => 'root',
	hour =>	5,
	minute => 00,
	environment => 'MAILTO=emrsysadmin@pih.org',
	require => [ File['mirebalaisreportscleanup.sh'] ]
  }

}
