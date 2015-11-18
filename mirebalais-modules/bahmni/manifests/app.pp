class bahmni::app (
  $tomcat = hiera('tomcat')
){

  file { "/usr/local/${tomcat}/webapps/bahmniapps":
    ensure  => directory,
    require => [Service[$tomcat]] ,
  }

  # TODO make this something that relies on a true deployment process, and allows use to apply updates
  wget::fetch { 'download-bahmniapps':
    source      => 'http://bamboo.pih-emr.org/bahmni-repo/bahmniapps.tar.gz',
    destination => "/usr/local/${tomcat}/webapps/bahmniapps/bahmniapps.tar.gz",
    timeout     => 0,
    verbose     => false,
    require => File["/usr/local/${tomcat}/webapps/bahmniapps"]
  }

  exec { 'unzip_bahmniapps':
    cwd     => "/usr/local/${tomcat}/webapps/bahmniapps",
    command => 'gzip -d bahmniapps.tar.gz',
    refreshonly => true,
    subscribe => [ Wget::Fetch['download-bahmniapps'] ]
  }

  exec { 'untar_bahmniapps':
    cwd     => "/usr/local/${tomcat}/webapps/bahmniapps",
    command => 'tar -xf bahmniapps.tar',
    refreshonly => true,
    subscribe => [ Exec['unzip_bahmniapps'] ]
  }
}
