class bahmni::config (
  $tomcat = hiera('tomcat')
){

  file { "/home/${tomcat}/.OpenMRS/bahmnicore.properties":
    ensure  => present,
    content => template('bahmni/bahmnicore.properties.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["/home/${tomcat}/.OpenMRS"]
  }

  file { "/home/${tomcat}/.OpenMRS/patient_images":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["/home/${tomcat}/.OpenMRS"]
  }

  file { "/home/${tomcat}/.OpenMRS/document_images":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["/home/${tomcat}/.OpenMRS"]
  }

  vcsrepo { "/usr/local/${tomcat}/webapps/bahmni-config":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/PIH/wellbody-config.git',
    revision => 'master',                                           # TODO switch to be driven by variable (which comes from manifest?)
    require => [Service[$tomcat],Package['git']]
  }

}
