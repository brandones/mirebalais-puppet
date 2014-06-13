class mirebalais_reporting::production_setup (
    $backup_user = decrypt(hiera('backup_db_user')),
    $backup_password = decrypt(hiera('backup_db_password')),
    $reporting_server_user = hiera('reporting_server_user'),
    $reporting_server_url = hiera('reporting_server_url'),
    $reporting_server_backup_dir = hiera('reporting_server_backup_dir'),
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
