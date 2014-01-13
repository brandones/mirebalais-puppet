class mysql_upgrade ($root_password = decrypt(hiera('mysql_root_password'))) {


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

  service { 'mysqlserver':
    ensure  => running,
    name    => 'mysql.server',
    enable  => true,
    require => [ File['/etc/init.d/mysql.server'] ],
  }

  exec { 'update_db':
    command => 'mysql_upgrade -u root -p${root_password}',
    environment => 'PATH=\'$PATH:/opt/mysql/server-5.6/bin\'',
    require => [ Service['mysqlserver'] ],
  }

  file { '/opt/mysql/server-5.6/my.cnf':
    ensure  => absent,
    require => [ Exec['update_db'] ],
  }

   exec { 'concat_path':
    command => 'echo "PATH=\'$PATH:/opt/mysql/server-5.6/bin\'" >> /etc/environment',
    require => [ File['/opt/mysql/server-5.6/my.cnf'] ],
  }


  
}