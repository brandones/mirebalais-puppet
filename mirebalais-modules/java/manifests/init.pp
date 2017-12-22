class java (
  $tomcat = hiera('tomcat')
){

  file { '/etc/environment':
    source => 'puppet:///modules/java/etc/environment'
  }

  apt::ppa { 'ppa:webupd8team/java': }

  # uninstall Oracle java 7
  package { 'oracle-java7-installer':
    ensure  => purged,
    require => [Apt::Ppa['ppa:webupd8team/java']]
  }

  # uninstall OpenJDK 7
  package { 'openjdk-7-jdk':
    ensure  => purged
  }

  # install OpenJDK 8
  package { 'openjdk-8-jdk':
    ensure  => present,
    notify => Service[$tomcat],
    require => [Package['oracle-java7-installer'], Package['openjdk-7-jdk'], File['/etc/environment']]
  }


  /*exec { 'set-licence-selected':
      command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections',
			user => root
  }

  exec { 'set-licence-seen':
      command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections',
      user => root
  }*/

}
