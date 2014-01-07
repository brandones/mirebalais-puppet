class mysql_upgrade () {


  service { 'mysqld':
    ensure  => stopped,
    name    => 'mysql',
    enable  => true,
  }

  apt::source { 'mysql':
    ensure      => present,
    location    => 'http://bamboo.pih-emr.org/mysql-repo',
    release     => 'stable/',
    repos       => '',
    include_src => false,
    require => [ Service['mysqld'] ],
  }

  package { 'libaio1':
    ensure  => latest,
    require => [ Apt::Source['mysql'] ],
  }

  package { 'mysql':
    ensure  => latest,
    require => [ Package['libaio1'] ],
  }

  file { '/opt/mysql/server-5.6/':
    ensure  => present,
    owner   => mysql,
    group   => mysql,
    recurse => inf,
    require => [ Package['mysql'] ],
  }

  file { '/etc/my.cnf':
    ensure  => file,
    content => template('mysql_upgrade/my.cnf.erb'),
    require => [ File['/opt/mysql/server-5.6/'] ],
  } ~>

  file { '/etc/init.d/mysql.server':
    source  => '/opt/mysql/server-5.6/support-files/mysql.server',
    ensure  => present,
    recurse => inf,
    require => [ File['/etc/my.cnf'] ],
  }

  exec { 'update_db':
    command => '/opt/mysql/server-5.6/scripts/mysql_install_db --user=mysql --datadir=/var/lib/mysql',
    require => [ File['/etc/init.d/mysql.server'] ],
  }

  file { '/opt/mysql/server-5.6/my.cnf':
    ensure  => absent,
    require => [ Exec['update_db'] ],
  }



  
}