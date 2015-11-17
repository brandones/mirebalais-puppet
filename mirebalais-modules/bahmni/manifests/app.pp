class bahmni::app (
  $tomcat = hiera('tomcat')
){

  # TODO make this something that relies on a true deployment process, and allows use to apply updates
  wget::fetch { 'download-bahmniapps':
    source      => 'http://bamboo.pih-emr.org/bahmniapps-repo/bahmniapps.zip',
    destination => "/usr/local/${tomcat}/webapps/bahmniapps/bahmniapps.zip",
    timeout     => 0,
    verbose     => false
  }

  exec { 'unzip_bahmniapps':
    cwd     => "/usr/local/${tomcat}/webapps/bahmniapps",
    command => 'gzip -d bahmniapps.zip',
    refreshonly => true,
    subscribe => [ Wget::Fetch['download-bahmniapps'] ]
  }
}
