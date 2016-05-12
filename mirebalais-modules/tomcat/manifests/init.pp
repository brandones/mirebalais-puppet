class tomcat (
    $tomcat = hiera('tomcat'),
    $services_enable = hiera('services_enable'),
    $java_memory_parameters = hiera('java_memory_parameters'),
    $java_profiler = hiera('java_profiler'),
    $java_debug_parameters = hiera('java_debug_parameters'),
    $restart_nightly = hiera('tomcat_restart_nightly')
  ){

  # make sure old versions instaled without ap-tget have been removed
  file { "/usr/local/apache-tomcat-6.0.36" :
    ensure => absent,
    recurse => true,
    purge => true,
    force => true,
  }

  file { "/usr/local/apache-tomcat-7.0.62" :
    ensure => absent,
    recurse => true,
    purge => true,
    force => true,
  }

  # install the proper version of tomcat via apt-get
  package { $tomcat :
    ensure => installed,
    require => [ File["/usr/local/apache-tomcat-6.0.36"], File["/usr/local/apache-tomcat-7.0.62"]],
    notify  => Service["$tomcat"]
  }

  # remove the "ROOT" webapp
  file { "/var/lib/$tomcat/webapps/ROOT":
    ensure  => absent,
    recurse => true,
    purge => true,
    force => true,
    require => Package[$tomcat]
  }


  file { "/etc/${tomcat}/server.xml":
    ensure  => present,
    owner   => $tomcat,
    group   => $tomcat,
    source  => "puppet:///modules/tomcat/server.xml",
    require => [ Package[$tomcat], User[$tomcat] ],
    notify  => Service["$tomcat"]
  }


  file { "/etc/init.d/${tomcat}":
    ensure  => file,
    source  => "puppet:///modules/tomcat/init"
  }

  file { "/etc/default/${tomcat}":
    ensure  => file,
    content => template("tomcat/default.erb")
  }

  file { "/etc/logrotate.d/${tomcat}":
    ensure  => file,
    source  => "puppet:///modules/tomcat/logrotate",
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
    require => [ Package[$tomcat], File["/etc/${tomcat}/server.xml"],
      File["/etc/init.d/${tomcat}"], File["/etc/default/${tomcat}" ]],
  }

  if $restart_nightly {
    cron { 'restart-tomcat':
      ensure  => present,
      command => "service ${tomcat} restart",
      user    => 'root',
      hour    => 5,
      require => [ Service[$tomcat] ]
    }
  }
  else {
    cron { 'restart-tomcat':
      ensure  => absent
    }
  }

}
