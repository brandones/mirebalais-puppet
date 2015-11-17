class bahmni::app (
  $tomcat = hiera('tomcat')
){

  # TODO change so the dist is downloaded from somewhere instead of built locally?

  vcsrepo { "/home/${tomcat}/bahmni-code/opemrs-module-bahmniapps":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/Bhamni/openmrs-module-bahmniapps.git',
    revision => 'master',                                                       # TODO switch to be driven by variable (which comes from manifest?)
    require  => [Service[$tomcat],Package['git']]
  }

  # TODO eventually get rid of installing all these dev tools once we are no longer building the app locally
  package { 'npm':
    ensure => installed,
  }

  exec { 'install_bower':
    command   => 'npm install -g bower',
    require   => [Package['npm']]
  }

  exec { 'install_grunt-cli':
    command   => 'npm install -g grunt-cli',
    require   => [Package['npm']]
  }

  exec { 'install_compass_gem':
    command   => 'gem install compass'
  }

  exec { 'bahmniapps_npm_install':
    cwd         => "/home/${tomcat}/bahmni-code/opemrs-module-bahmniapps/ui",
    command     => 'npm install',
    refreshonly => 'true',
    subscribe => Vcsrepo["/usr/local/${tomcat}/bahmni-code/opemrs-module-bahmniapps"]
  } ->

  exec { 'bahmniapps_bower_install':
    cwd         => "/home/${tomcat}/bahmni-code/opemrs-module-bahmniapps/ui",
    command     => 'bower install',
    refreshonly => 'true',
    subscribe => Exec["bahmniapps_npm_install"]
  } ->

  exec { 'bahmniapps_grunt':
    cwd         => "/home/${tomcat}/bahmni-code/opemrs-module-bahmniapps/ui",
    command     => 'grunt',
    refreshonly => 'true',
    subscribe => Exec["bahmniapps_bower_install"]
  } ->

  # link built distro to appropriate tomcat webapps directory
  file { '/usr/local/${tomcat}/webapps/bahmniapps':
    ensure => 'link',
    target => '/home/${tomcat}/bahmni-code/opemrs-module-bahmniapps/ui/dist',
    require => Exec['bahmniapps_grunt']
  }
}
