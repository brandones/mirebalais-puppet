class mysql_setup (
	$root_password = decrypt(hiera('mysql_root_password')),
	$mysql_bind_address = hiera('mysql_bind_address'),
  	$mysql_expire_logs_days = hiera('mysql_expire_logs_days'),
  	$mysql_innodb_buffer_pool_size = hiera('mysql_innodb_buffer_pool_size'),
    $mysql_innodb_buffer_pool_instances = hiera('mysql_innodb_buffer_pool_instances'),
    $mysql_binary_logging = hiera('mysql_binary_logging'),
    $mysql_net_read_timeout = hiera('mysql_net_read_timeout'),
    $mysql_net_write_timeout = hiera('mysql_net_write_timeout'),
    $mysql_wait_timeout = hiera('mysql_wait_timeout'),
    $mysql_interactive_timeout = hiera('mysql_interactive_timeout')
){


  user { 'mysql':
    ensure => 'present',
    shell  => '/bin/sh',
  }

  # put proper /etc/mysql directory my.cnf in place
  file { '/etc/mysql':
    ensure  => directory
  }

  # looks like in Ubuntu 16.04 the location of my.cnf is moved from /etc/mysql to /etc/alternatives
  # just making sure it is installed in both places for now, but we should clean these two blocks up
  # after we upgrade to 16.04; also note that there may be a further change if/when we upgrade to Mysql 5.7:
  # https://askubuntu.com/questions/763774/mysql-istallation-problem-on-ubuntu-16-04-my-cnf-public-ip-problem
  file { '/etc/alternatives/my.cnf':
    ensure  => present,
    content => template('mysql_setup/my.cnf.erb'),
    require => File['/etc/mysql'],
    notify  => Service['mysqld']
  }

  file { '/etc/mysql/my.cnf':
    ensure  => present,
    content => template('mysql_setup/my.cnf.erb'),
    require => File['/etc/mysql'],
    notify  => Service['mysqld']
  }

  # make sure the mysql 5,5 is uninstalled, as well as the custom "mysql" package we put in place
  # note that we put the proper my.cnf in place first because any restarting of mysql requires this package to be present
  package { 'mysql-client-5.5':
    ensure  => purged,
    require => File['/etc/mysql/my.cnf']
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
  package { 'mysql':
    ensure  => purged,
    require => Package['mysql-server-core-5.5']
  }

  # make sure old files are removed
  file {'/opt/mysql':
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

  # make sure old mysql apt source we set up on bamboo is absent
  apt::source { 'mysql':
    ensure      => absent,
    require => Package['mysql']
  }

  # set root password automatically
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


  # install mysql 5.6
  package { 'mysql-server-5.6':
    ensure  => installed,
    require => [Exec['set-root-password'], Exec['confirm-root-password'], Package['mysql'],
      File['/opt/mysql'], File['/etc/init.d/mysql.server'], File['/etc/mysql/my.cnf']]
  }

  package { 'mysql-client-5.6':
    ensure  => installed,
    require => [Package['mysql-server-5.6'], Exec['set-root-password'], Exec['confirm-root-password']]
  }

  file { "root_user_my.cnf":
    path        => "${root_home}/.my.cnf",
    content     => template('mysql_setup/my.cnf.pass.erb'),
    require     => Exec['confirm-root-password'],
  }

  service { 'mysqld':
    ensure  => running,
    name    => 'mysql',
    enable  => true,
    require => [ File['/etc/mysql/my.cnf'], File['root_user_my.cnf'], Package['mysql-server-5.6'] ],
  }
  
}
