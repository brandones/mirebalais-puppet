class mysql (
  $root_password = decrypt(hiera('mysql_root_password')),
  $mysql_server_id = hiera('mysql_server_id'),
){

  package { 'mysql-server-5.6':
    ensure  => installed,
    require => [Exec['set-root-password'], Exec['confirm-root-password']]
  }

  exec {
    'set-root-password':
      command => "/bin/echo mysql-server mysql-server/root_password password $root_password | /usr/bin/debconf-set-selections",
      user => root
  }

  exec {
    'confirm-root-password':
      command => "/bin/echo mysql-server mysql-server/root_password_again password $root_password | /usr/bin/debconf-set-selections",
      user => root
  }

  file { '/etc/mysql/my.cnf':
    ensure  => file,
    content => template('mysql/my.cnf.erb'),
    require => [ Package['mysql-server-5.6'] ]
  }

  # Note: This doesn't seem compatible with Docker, but I expect it to work normally on Ubuntu
  service { 'mysql':
    ensure  => running,
    name    => 'mysql',
    enable  => true,
    require => [ File['/etc/mysql/my.cnf'], Package['mysql-server-5.6'] ]
  }

}
