class bahmni::app (
  $tomcat = hiera('tomcat')
){

  # TODO change so the dist is downloaded from somewhere instead of built locally?

  vcsrepo { "/usr/local/${tomcat}/bahmni-code/opemrs-module-bahmniapps":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/Bhamni/openmrs-module-bahmniapps.git',
    revision => 'master',                                                       # TODO switch to be driven by variable (which comes from manifest?)
    require => [Service[$tomcat],Package['git']]
  }

  # TODO eventually get rid of installing all these dev tools once we are no longer building the app locally
  package { 'npm':
    ensure => installed,
  }

  exec { 'install_bower':
    command   => 'npm install -g bower',
    require => [Package['npm']]
  }

  exec { 'install_grunt-cli':
    command   => 'npm install -g grunt-cli',
    require => [Package['npm']]
  }

  exec { 'install_compass_gem':
    command   => 'gem install compass'
  }

}
