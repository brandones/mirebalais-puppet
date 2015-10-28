class mysql_setup (
	$root_password = decrypt(hiera('mysql_root_password')),
	$mysql_bind_address = hiera('mysql_bind_address'),
  	$mysql_expire_logs_days = hiera('mysql_expire_logs_days'),
  	$mysql_innodb_buffer_pool_size = hiera('mysql_innodb_buffer_pool_size')
){

  # make sure the old mysql 5.6 deb package we used to install manually has been removed
  package { 'mysql':
    ensure  => purged
  }

  # make sure old conf file and directory are absent
  file {'/opt/mysql':
    ensure => absent,
    recurse => true,
    purge => true,
    force => true,
    require => Package['mysql']
  }

# make sure the old upstart startup file for mysql 5.5 is not present
  file { '/etc/init/mysql.conf':
    ensure => absent
  }

  # install mysql
  package { 'mysql-server-5.6':
    ensure  => installed,
    require => [Package['mysql'], Exec['set-root-password'], Exec['confirm-root-password']]
  }

  package { 'mysql-client-5.6':
    ensure  => installed,
    require => [Package['mysql'], Exec['set-root-password'], Exec['confirm-root-password']]
  }

  exec {
    'set-root-password':
      command => "/bin/echo mysql-server mysql-server/root_password password $root_password | /usr/bin/debconf-set-selections",
      user => root
  }

  exec {
    'confirm-root-password':
      command => "/bin/echo mysql-server mysql-server/root_password_again password $root_password | /usr/bin/debconf-set-selections",
      user => root,
      require => Exec['set-root-password']
  }

  file { "root_user_my.cnf":
    path        => "${root_home}/.my.cnf",
    content     => template('mysql_setup_56/my.cnf.pass.erb'),
    require     => Exec['confirm-root-password'],
  }

  file { '/etc/mysql/my.cnf':
    ensure  => file,
    content => template('mysql_setup/my.cnf.erb'),
    require => [ Package['mysql-server-5.6'] ]
  }

  service { 'mysqld':
    ensure  => running,
    name    => 'mysql',
    enable  => true,
    require => [ File['/etc/mysql/my.cnf'], File['root_user_my.cnf'], Package['mysql-server-5.6'] ],
  }
  
}
