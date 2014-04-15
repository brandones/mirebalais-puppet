class mysql_setup_56 (
  $root_password = decrypt(hiera('mysql_root_password'))
) {

  class { 'mysql::server':
    manage_service => false,
    config_hash    => {
      'root_password' => $root_password,
      'config_file'   => '/tmp/my.cnf',
      'restart'       => false
    },
  } ->

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

  exec { 'install_db':
    command => "mysql_install_db --user=mysql --datadir=/var/lib/mysql",
    path => ["/opt/mysql/server-5.6/scripts", "/opt/mysql/server-5.6/bin"],
    creates => "/etc/init.d/mysql.server",
    require => [ Package['mysql-client-core-5.5'] ],   
  }

  file { '/usr/bin/mysql':
      ensure => link,
      target => '/opt/mysql/server-5.6/bin/mysql',
      require => [ Exec['install_db'] ],
  }
 
  file { '/etc/init.d/mysql.server':
    source  => '/opt/mysql/server-5.6/support-files/mysql.server',
    ensure  => present,
    recurse => inf,
    require => [ File['/usr/bin/mysql'] ],
  }

  service { 'mysqld':
    ensure  => running,
    name    => 'mysql.server',
    enable  => true,
    require => [ File['/etc/init.d/mysql.server'] ],
    
  }

}