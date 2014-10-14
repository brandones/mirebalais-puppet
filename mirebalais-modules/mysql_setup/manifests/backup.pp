class mysql_setup::backup (
    $backup_user = decrypt(hiera('backup_db_user')),
    $backup_password = decrypt(hiera('backup_db_password')),
    $remote_db_user = hiera('remote_db_user'),
    $remote_db_server = hiera('remote_db_server'),
    $remote_backup_dir = hiera('remote_backup_dir'),
    $tomcat = hiera('tomcat')
  ){

  database_user { "${backup_user}@localhost":
    ensure        => present,
    password_hash => mysql_password($backup_password),
    provider      => 'mysql',
    require       => Service['mysqld'],
  }

  database_grant { "${backup_user}@localhost":
    privileges => [ 'Select_priv', 'Reload_priv', 'Lock_tables_priv', 'Repl_client_priv', 'Repl_slave_priv', 'Show_view_priv' ],
    require    => Database_user["${backup_user}@localhost"],
  }

  package { 'p7zip-full' :
  	  ensure => 'installed'
  }

  cron { 'mysql-backup':
    ensure  => present,
    command => '/usr/local/sbin/mysqlbackup.sh > /dev/null',
    user    => 'root',
    hour    => 1,
    minute  => 30,
    environment => 'MAILTO=emrsysadmin@pih.org',
    require => [ File['mysqlbackup.sh'], Package['p7zip-full'] ]
  }

  file { 'mysqlbackup.sh':
    ensure  => present,
    path    => '/usr/local/sbin/mysqlbackup.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('mysql_setup/mysqlbackup.sh.erb'),
  }

  cron { 'mysql-archive':
    ensure  => present,
    command => '/usr/local/sbin/mysqlarchive.sh > /dev/null',
    user     => 'root',
    monthday => 1,
    environment => 'MAILTO=emrsysadmin@pih.org',
    require => [ File['mysqlarchive.sh'] ]
  }

  file { 'mysqlarchive.sh':
    ensure  => present,
    path    => '/usr/local/sbin/mysqlarchive.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('mysql_setup/mysqlarchive.sh.erb'),
  }
}
