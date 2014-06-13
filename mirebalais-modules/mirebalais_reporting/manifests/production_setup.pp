class mirebalais_reporting::production_setup (
    $backup_user = decrypt(hiera('backup_db_user')),
    $backup_password = decrypt(hiera('backup_db_password')),
    $tomcat = hiera('tomcat')
  ){

  file { 'mysqlreportingdbdump.sh':
    ensure  => present,
    path    => '/usr/local/sbin/mysqlreportingdbdump.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('mirebalais_reporting/mirebalaisreportingdbdump.sh.erb'),
  }
}
