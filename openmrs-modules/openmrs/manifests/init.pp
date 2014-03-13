class openmrs (
    $openmrs_db = hiera('openmrs_db'),
    $openmrs_db_user = decrypt(hiera('openmrs_db_user')),
    $openmrs_db_password = decrypt(hiera('openmrs_db_password')),
    $openmrs_auto_update_database = hiera('openmrs_auto_update_database'),
    $openmrs_release = hiera('openmrs_release'),
    $tomcat = hiera('tomcat'),
  ){

  file { '/etc/apt/apt.conf.d/99auth':
    ensure  => present,
    owner   => root,
    group   => root,
    content => 'APT::Get::AllowUnauthenticated yes;',
    mode    => '0644'
  }

    file { "/home/${tomcat}/.OpenMRS":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0755',
    require => User[$tomcat]
  }

  file { "/home/${tomcat}/.OpenMRS/openmrs-runtime.properties":
    ensure  => present,
    content => template('openmrs/openmrs-runtime.properties.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["/home/${tomcat}/.OpenMRS"]
  }
}
