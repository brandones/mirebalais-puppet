class mysql_setup (
	$root_password = decrypt(hiera('mysql_root_password')),
	$mysql_bind_address = hiera('mysql_bind_address'),
  	$mysql_expire_logs_days = hiera('mysql_expire_logs_days'),
  	$mysql_innodb_buffer_pool_size = hiera('mysql_innodb_buffer_pool_size')
){

  package { 'mysql-server-5.6':
    ensure  => installed,
    require => [Exec['set-root-password'], Exec['confirm-root-password']]
  }

  exec {
    'set-root-password':
      command => "/bin/echo mysql-server mysql-server/root_password password $r$
      user => root
  }

  exec {
    'confirm-root-password':
      command => "/bin/echo mysql-server mysql-server/root_password_again passw$
      user => root
  }

  file { '/etc/mysql/my.cnf':
    ensure  => file,
    content => template('mysql/my.cnf.erb'),
    require => [ Package['mysql-server-5.6'] ]
  }

  user { 'mysql':
    ensure => 'present',
    shell  => '/bin/sh',
  }

  file { '/opt/mysql/server-5.6/':
    ensure  => present,
    owner   => mysql,
    group   => mysql,
    recurse => inf,
    require => [ Package['mysql-server'], User['mysql'] ],
  }

   file { "/etc/mysql/conf.d":
    ensure  => directory,
    owner   => mysql,
    group   => mysql,
    mode    => '0755',
    require => File['/etc/mysql'],
  }

  file { '/usr/bin/mysqladmin':
    ensure => link,
    target => '/opt/mysql/server-5.6/bin/mysqladmin',
    require => Package['mysql-server'],
  }

  file { "root_user_my.cnf":
    path        => "${root_home}/.my.cnf",
    content     => template('mysql/my.cnf.pass.erb'),
    require     => Exec['set-root-password'],
  }

   exec { 'install_db':
    creates   => '/etc/init.d/mysql.server',  # this just means that this not execute if this mysql.server file has been$
    command   => "mysql_install_db --user=mysql --datadir=/var/lib/mysql",
    path      => ["/opt/mysql/server-5.6/scripts", "/opt/mysql/server-5.6/bin"],
    require   => [ Package['mysql-server'], User['mysql'] ],
  }

  file { '/usr/bin/mysql':
      ensure => link,
      target => '/opt/mysql/server-5.6/bin/mysql',
      require => [ Package['mysql-server'] ],
  }

  file { '/etc/init.d/mysql.server':
    ensure  => present,
    source  => '/opt/mysql/server-5.6/support-files/mysql.server',
    mode    => '0755',
    owner   => 'mysql',
    group   => 'mysql',
    require => [ Exec['install_db'] ],
  }

   # make sure the old upstart startup file for mysql 5.5 is not present
  file { '/etc/init/mysql.conf':
       ensure => absent
  }

  service { 'mysqld':
    ensure  => running,
    name    => 'mysql',
    enable  => true,
    require => [ File['/etc/mysql/my.cnf'], Package['mysql-server'] ],
  }
  
}
