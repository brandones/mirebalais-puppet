class bahmni::config (
  $tomcat = hiera('tomcat')
){

  file { "/home/${tomcat}/.OpenMRS/bahmnicore.properties":
    ensure  => present,
    content => template('bahmni/bamnicore.properties.erb'),
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
    source   => 'https://github.com/Bhamni/default-config.git',     # TODO switch to use implementation-specific config
    revision => 'master',                                           # TODO switch to be driven by variable (which comes from manifest?)
    require => [Service[$tomcat],Package['git']]
  }

}
