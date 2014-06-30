class mirebalais_reporting::production_setup (
    $backup_user = decrypt(hiera('backup_db_user')),
    $backup_password = decrypt(hiera('backup_db_password')),
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

  package { 'p7zip-full':
  	  ensure => 'installed'
  }

  cron { 'mysql-reporting-db-dump':
    ensure  => present,
    command => '/usr/local/sbin/mirebalaisreportingdbdump.sh',
    user    => 'root',
    hour    => 2,
    minute  => 30,
    require => [ File['mirebalaisreportingdbdump.sh'], Package['7z'] ]
  }
}
