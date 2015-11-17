class bahmni::config (
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

  # TODO if we do keep these, specify certain version numbers to install?
  package { 'npm':
    ensure => installed,
  }

  package { 'bower':
    ensure   => 'present',
    provider => 'npm',
    require => [Package['npm']]
  }

  package { 'grunt-cli':
    ensure   => 'present',
    provider => 'npm',
    require => [Package['npm']]
  }

}
