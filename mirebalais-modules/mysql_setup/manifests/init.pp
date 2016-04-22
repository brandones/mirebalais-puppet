class mysql_setup (
	$root_password = decrypt(hiera('mysql_root_password')),
	$mysql_bind_address = hiera('mysql_bind_address'),
  	$mysql_expire_logs_days = hiera('mysql_expire_logs_days'),
  	$mysql_innodb_buffer_pool_size = hiera('mysql_innodb_buffer_pool_size')
){


  user { 'mysql':
    ensure => 'present',
    shell  => '/bin/sh',
  }

  # make sure the old mysql 5.6 deb package we used to install manually has been removed, + old mysql-5.5 installs are removed
  package { 'mysql-client-5.5':
    ensure  => purged
  }
  package { 'mysql-client-core-5.5':
    ensure  => purged,
    require => Package['mysql-client-5.5']
  }
  package { 'mysql-server-5.5':
    ensure  => purged,
    require => Package['mysql-client-core-5.5']
  }
  package { 'mysql-server-core-5.5':
    ensure  => purged,
    require => Package['mysql-server-5.5']
  }
  package { 'mysql-commom':
    ensure  => purged,
    require => Package['mysql-server-core-5.5']
  }
  package { 'mysql':
    ensure  => purged,
    require => Package['mysql-common']
  }

  # make sure old directories and files are absent
  file {'/opt/mysql':
    ensure => absent,
    recurse => true,
    purge => true,
    force => true,
    require => Package['mysql']
  }

  file {'/etc/mysql':
    ensure => absent,
    recurse => true,
    purge => true,
    force => true,
    require => Package['mysql']
  }

  file { '/etc/init.d/mysql.server':
    ensure  => absent,
    require => Package['mysql']
  }

  # make sure the old upstart startup file for mysql 5.5 is not present
  file { '/etc/init/mysql.conf':
    ensure => absent,
    require => Package['mysql']
  }

  # make sure old mysql apt source we set up on bamboo is absent6
  apt::source { 'mysql':
    ensure      => absent,
    require => Package['mysql']
  }

  # start putting new files in place after removing old ones
  file { '/etc/mysql/my.cnf':
    ensure  => file,
    content => template('mysql_setup/my.cnf.erb'),
    require => [ File['/etc/mysql'] ]
  }

  file { '/etc/init/mysql.conf':
    ensure  => file,
    source => 'puppet:///modules/mysql_setup/mysql.conf',
    require => [ File['/etc/mysql'] ]
  }

  # install mysql 5.6
  package { 'mysql-server-5.6':
    ensure  => installed,
    require => [Exec['set-root-password'], Exec['confirm-root-password'], Package['mysql'],
      File['/opt/mysql'], File['/etc/mysql'], File['/etc/init.d/mysql.server'], File['/etc/init/mysql.conf']]
  }

  package { 'mysql-client-5.6':
    ensure  => installed,
    require => [Package['mysql-server-5.6'], Exec['set-root-password'], Exec['confirm-root-password']]
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
    content     => template('mysql_setup/my.cnf.pass.erb'),
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
