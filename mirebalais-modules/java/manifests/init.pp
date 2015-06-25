class java {
  file { '/etc/environment':
    source => 'puppet:///modules/java/etc/environment'
  }

  apt::ppa { 'ppa:webupd8team/java': }

  package { 'oracle-java6-installer':
	ensure => purged
  }

  package { 'oracle-java7-installer':
    ensure  => installed,
    require => [Apt::Ppa['ppa:webupd8team/java'],
		Package['oracle-java6-installer'],
                Exec['skipping license approval']]
  }

  exec {'skipping license approval':
    command     => 'echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections',
    user        => 'root',
    subscribe   => Apt::Ppa['ppa:webupd8team/java'],
    refreshonly => true
  }
}
