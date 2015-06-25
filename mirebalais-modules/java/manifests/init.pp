class java {
  file { '/etc/environment':
    source => 'puppet:///modules/java/etc/environment'
  }

  apt::ppa { 'ppa:webupd8team/java': }

  package { 'oracle-java7-installer':
    ensure  => installed,
    require => [Apt::Ppa['ppa:webupd8team/java'],
                Exec['set-licence-selected'],
		Exec['set-licence-seen']]
  }

  exec {
    'set-licence-selected':
      	command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections',
	user => root
  }

  exec {
    'set-licence-seen':
      	command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections',
	user => root 
  }

}
