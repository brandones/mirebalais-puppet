class openmrs (
    $openmrs_db = hiera('openmrs_db'),
    $openmrs_db_user = decrypt(hiera('openmrs_db_user')),
    $openmrs_db_password = decrypt(hiera('openmrs_db_password')),
    $openmrs_auto_update_database = hiera('openmrs_auto_update_database'),
    $mirebalais_release = hiera('mirebalais_release'),
    $tomcat = hiera('tomcat'),
    $remote_zlidentifier_url = hiera('remote_zlidentifier_url'),
    $remote_zlidentifier_username = decrypt(hiera('remote_zlidentifier_username')),
    $remote_zlidentifier_password = decrypt(hiera('remote_zlidentifier_password')),
	$lacolline_server_url = hiera('lacolline_server_url'),
    $lacolline_username = decrypt(hiera('lacolline_username')),
    $lacolline_password = decrypt(hiera('lacolline_password')),
    $junit_username = hiera('junit_username'),
    $junit_password = decrypt(hiera('junit_password')),
    $custom_appframework_config_filename = hiera('custom_appframework_config_filename')
  ){

  file { '/etc/apt/apt.conf.d/99auth':
    ensure  => present,
    owner   => root,
    group   => root,
    content => 'APT::Get::AllowUnauthenticated yes;',
    mode    => '0644'
  }

  apt::source { 'mirebalais':
    ensure      => present,
    location    => 'http://bamboo.pih-emr.org/mirebalais-repo',
    release     => $mirebalais_release,
    repos       => '',
    include_src => false,
  }

  package { 'mirebalais':
    ensure  => latest,
    require => [ Service[$tomcat], Apt::Source['mirebalais'], File['/etc/apt/apt.conf.d/99auth'] ],
  }

  file { "/home/${tomcat}/.OpenMRS":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0755',
    require => User[$tomcat]
  }

  file { "/home/${tomcat}/.OpenMRS/mirebalais.properties":
    ensure  => present,
    content => template('openmrs/mirebalais.properties.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["/home/${tomcat}/.OpenMRS"]
  }

  file { "/home/${tomcat}/.OpenMRS/feature_toggles.properties":
    ensure  => present,
    content => template('openmrs/feature_toggles.properties.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["/home/${tomcat}/.OpenMRS"]
  }

  file { "/home/${tomcat}/.OpenMRS/mirebalais-runtime.properties":
    ensure  => present,
    content => template('openmrs/mirebalais-runtime.properties.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["/home/${tomcat}/.OpenMRS"]
  }

   # install file to customize apps for production (removing export apps) or reporting server (only including export apps)
   file { "/home/${tomcat}/.OpenMRS/appframework-config.json":
	ensure => present,
	source => "puppet:///modules/openmrs/appframework-config-${$custom_appframework_config_filename}.json",
	owner   => $tomcat,
	group   => $tomcat,
	mode    => '0644',
	require => File["/home/${tomcat}/.OpenMRS"]
   }

}
