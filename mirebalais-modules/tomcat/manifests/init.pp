class tomcat (
    $tomcat = hiera('tomcat'),
    $services_enable = hiera('services_enable'),
    $java_memory_parameters = hiera('java_memory_parameters'),
    $java_profiler = hiera('java_profiler'),
    $java_debug_parameters = hiera('java_debug_parameters'),
  ){

  case $tomcat {
    tomcat6: {
      	$old_tomcat = 'tomcat0'
	$old_version = '0.0.0'
	$version = '6.0.36'
      	$source  = 'http://archive.apache.org/dist/tomcat/tomcat-6/v6.0.36/bin/apache-tomcat-6.0.36.tar.gz'
    }
    tomcat7: {
	$old_tomcat = 'tomcat6'
	$old_version = '6.0.36'
      	$version = '7.0.62'
      	$source  = 'http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.62/bin/apache-tomcat-7.0.62.tar.gz'
    }
  }

  # uninstall old version of tomcat
  file { "/usr/local/apache-tomcat-${old_version}":
	ensure => absent,
	force => true
  }
  
  file { "/etc/init.d/${old_tomcat}":
    ensure  => absent
  }

  file { "/etc/default/${old_tomcat}":
    ensure  => absent
  }

  file { "/etc/logrotate.d/${old_tomcat}":
    ensure  => absent
  }

  file { "/home/${old_tomcat}":
    ensure  => absent,
    force => true
  }

  # install the proper version of tomcat
  wget::fetch { 'download-tomcat':
    source      => $source,
    destination => "/usr/local/tomcat-${version}.tgz",
    timeout     => 0,
    verbose     => false,
  }

  exec { 'tomcat-unzip':
    cwd     => '/usr/local',
    command => "tar --group=${tomcat} --owner=${tomcat} -xzf /usr/local/tomcat-${version}.tgz",
    unless  => "test -d /usr/local/apache-tomcat-${version}",
    require => [ Wget::Fetch['download-tomcat'], User[$tomcat], Package['oracle-java7-installer' ] ],
  }
   

  file { "/usr/local/apache-tomcat-${version}":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    recurse => true,
    require => Exec['tomcat-unzip'],
  }

  file { "/usr/local/apache-tomcat-${version}/conf":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    recurse => true,
    require => File["/usr/local/apache-tomcat-${version}"]
  }

  file { "/usr/local/${tomcat}":
    ensure  => 'link',
    target  => "/usr/local/apache-tomcat-${version}",
    owner   => $tomcat,
    group   => $tomcat,
    require => Exec['tomcat-unzip'],
  }

  file { "/usr/local/apache-tomcat-${version}/conf/server.xml":
    ensure  => present,
    owner   => $tomcat,
    group   => $tomcat,
    source  => "puppet:///modules/tomcat/${version}/server.xml",
    require => File["/usr/local/apache-tomcat-${version}/conf"],
    notify  => Service["$tomcat"]
  }


  file { "/etc/init.d/${tomcat}":
    ensure  => file,
    source  => "puppet:///modules/tomcat/${version}/init"
  }

  file { "/etc/default/${tomcat}":
    ensure  => file,
    content => template("tomcat/${version}/default.erb")
  }

  file { "/etc/logrotate.d/${tomcat}":
    ensure  => file,
    source  => "puppet:///modules/tomcat/${version}/logrotate",
  }

  user { $tomcat:
    ensure => 'present',
    home   => "/home/${tomcat}",
    shell  => '/bin/sh',
  }

  file { "/home/${tomcat}":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0755',
    require => User[$tomcat]
  }

  # todo add a dependency on java being installed?
  service { $tomcat:
    enable  => $services_enable,
    require => [ Exec['tomcat-unzip'], File["/usr/local/${tomcat}"], File["/etc/init.d/${tomcat}"] ],
  }  

  # ensure that the symbolic link for the old tomcat now points to the new tomcat (necessary until we 
  # update the debian package to deploy to tomcat6

#  file { "/usr/local/${old_tomcat}":
#    ensure  => 'link',
#    target  => "/usr/local/apache-tomcat-${version}",
#    owner   => $tomcat,
#    group   => $tomcat,
#    require => Exec['tomcat-unzip'],
#  }

}
