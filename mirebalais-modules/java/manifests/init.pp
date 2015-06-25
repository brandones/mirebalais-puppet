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

  # set this just in case this is the first run and /etc/environment has not yet been sourced?

  exec {
    'set JAVA_HOME':
	command => 'export JAVA_HOME="/usr/lib/jvm/java-7-oracle"',
        user => root
  }
}
