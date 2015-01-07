class openmrs (
    $openmrs_db = hiera('openmrs_db'),
    $openmrs_db_user = decrypt(hiera('openmrs_db_user')),
    $openmrs_db_password = decrypt(hiera('openmrs_db_password')),
    $openmrs_auto_update_database = hiera('openmrs_auto_update_database'),
    $package_release = hiera('package_release'),
    $webapp_name = hiera('webapp_name'),
    $tomcat = hiera('tomcat'),
    $remote_zlidentifier_url = hiera('remote_zlidentifier_url'),
    $remote_zlidentifier_username = decrypt(hiera('remote_zlidentifier_username')),
    $remote_zlidentifier_password = decrypt(hiera('remote_zlidentifier_password')),
	$lacolline_server_url = hiera('lacolline_server_url'),
    $lacolline_username = decrypt(hiera('lacolline_username')),
    $lacolline_password = decrypt(hiera('lacolline_password')),
    $junit_username = hiera('junit_username'),
    $junit_password = decrypt(hiera('junit_password')),
    $schedule_reports = hiera('schedule_reports'),
    $appframework_config_filename = hiera('appframework_config_filename'), 
    $pih_config = hiera('pih_config')
  ){

  file { '/etc/apt/apt.conf.d/99auth':
    ensure  => present,
    owner   => root,
    group   => root,
    content => 'APT::Get::AllowUnauthenticated yes;',
    mode    => '0644'
  }

  apt::source { 'pihemr':
    ensure      => present,
    location    => 'http://bamboo.pih-emr.org/pihemr-repo',
    release     => $package_release,
    repos       => '',
    include_src => false,
  }

  package { 'pihemr':
    ensure  => latest,
    require => [ Service[$tomcat], Apt::Source['pihemr'], File["/home/${tomcat}/.OpenMRS/${webapp_name}-runtime.properties"], File['/etc/apt/apt.conf.d/99auth'] ],
  }

  file { "/home/${tomcat}/.OpenMRS":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0755',
    require => User[$tomcat]
  }

  # this is a legacy file--these properties have been moved into the main runtime properties file
  file { "/home/${tomcat}/.OpenMRS/mirebalais.properties":
    ensure  => absent
  }

  file { "/home/${tomcat}/.OpenMRS/feature_toggles.properties":
    ensure  => present,
    content => template('openmrs/feature_toggles.properties.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["/home/${tomcat}/.OpenMRS"]
  }

  file { "/home/${tomcat}/.OpenMRS/${webapp_name}-runtime.properties":
    ensure  => present,
    content => template('openmrs/openmrs-runtime.properties.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["/home/${tomcat}/.OpenMRS"]
  }

   # this is legacy, this is now handled by our custom app loader factor
   file { "/home/${tomcat}/.OpenMRS/appframework-config.json":
	ensure => absent
   }

}
