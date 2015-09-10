# This module installs mysql 5.6, including setting the root password and the appropriate my.cnf settings
# We may want to consider seeing if the puppet forge mysql module is better to use for this at some point
# This module is newer than the mysql_setup_56 module and uses the actual Ubuntu PPA, rather than one we host

class mysql_56 (
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
    content => template('mysql_56/my.cnf.erb'),
    require => [ Package['mysql-server-5.6'] ]
  }

  service { 'mysqld':
    ensure  => running,
    name    => 'mysql',
    enable  => true,
    require => [ File['/etc/mysql/my.cnf'], Package['mysql-server-5.6'] ]
  }

}
