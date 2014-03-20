class mysql_setup_56 (
  $root_password = decrypt(hiera('mysql_root_password'))
) {

  apt::source { 'mysql':
    ensure      => present,
    location    => 'http://bamboo.pih-emr.org/mysql-repo',
    release     => 'stable/',
    repos       => '',
    include_src => false,
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

  file { '/etc/mysql/my.cnf':
    ensure  => file,
    content => template('mysql_upgrade/my.cnf.erb'),
    require => [ File['/opt/mysql/server-5.6/'] ],
  } ~>

  package { 'mysql-common':
    ensure  => absent,
    require => [ File['/etc/mysql/my.cnf'] ],
  }

  package { 'mysql-server-5.5':
    ensure  => absent,
    require => [ Package['mysql-common'] ],
  }

  package { 'mysql-server-core-5.5':
    ensure  => absent,
    require => [ Package['mysql-server-5.5'] ],
  }

  package { 'mysql-client-5.5':
    ensure  => absent,
   require => [ Package['mysql-server-core-5.5'] ],
  }

  package { 'mysql-client-core-5.5':
    ensure  => absent,
    require => [ Package['mysql-client-5.5'] ],
  }


  file { '/etc/init.d/mysql.server':
    source  => '/opt/mysql/server-5.6/support-files/mysql.server',
    ensure  => present,
    recurse => inf,
    require => [ Package['mysql-client-core-5.5'] ],
  }

  exec { 'update_db':
    command => "mysql_install_db --user=mysql --datadir=/var/lib/mysql",
    path => ["/opt/mysql/server-5.6/scripts", "/opt/mysql/server-5.6/bin"],
    require => [ File['/etc/init.d/mysql.server'] ],
  }

    service { 'mysqld':
    ensure  => running,
    name    => 'mysql.server',
    enable  => true,
    require => [ Exec['update_db'] ],
  }

   exec { 'concat_path':
    command => 'ln -s /opt/mysql/server-5.6/bin/mysql /usr/bin/mysql',
    require => [ Service['mysqld'] ],
  }


  
}