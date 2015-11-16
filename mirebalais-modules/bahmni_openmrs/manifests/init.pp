class bahmni_openmrs (
  $openmrs_db = hiera('openmrs_db'),
  $openmrs_db_user = decrypt(hiera('openmrs_db_user')),
  $openmrs_db_password = decrypt(hiera('openmrs_db_password')),
  $openmrs_auto_update_database = hiera('openmrs_auto_update_database'),
  $webapp_name = hiera('webapp_name'),
  $tomcat = hiera('tomcat'),
  $emrapi_version = '1.13-SNAPSHOT'
){

  mysql_database { $openmrs_db :
    ensure  => present,
    require => [Service['mysqld']],
    charset => 'utf8',
  } ->

  mysql_user { "${openmrs_db_user}@localhost":
    ensure        => present,
    password_hash => mysql_password($openmrs_db_password),
    require => [ Service['mysqld']],
  } ->

  mysql_grant { "${openmrs_db_user}@localhost/${openmrs_db}":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "${openmrs_db_user}@localhost",
    require => [ Service['mysqld'] ],
  } ->

  mysql_grant { "root@localhost/${openmrs_db}":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "root@localhost",
    require => [Service['mysqld'] ],
    notify  => exec ['tomcat-restart']
  }

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

  file { "/home/${tomcat}/.OpenMRS/modules":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0755',
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

  maven { "/usr/local/tomcat7/webapps/openmrs.war":
    groupid => "org.openmrs.web",
    artifactid => "openmrs-webapp",
    version => "1.12.0-SNAPSHOT",
    ensure => "latest",
    packaging => "war",
    repos => "http://mavenrepo.openmrs.org/nexus/content/repositories/public",
    require => [ Package['maven'], Service[$tomcat], File["/home/${tomcat}/.OpenMRS/${webapp_name}-runtime.properties"], File['/etc/apt/apt.conf.d/99auth'] ],
    notify  => exec ['tomcat-restart']
  }

  maven { "/home/${tomcat}/.OpenMRS/modules/emrapi-${emrapi_version}.omod":
    groupid => "org.openmrs.module",
    artifactid => "emrapi-omod",
    version => "${emrapi_version}",
    ensure => "latest",
    packaging => "jar",
    repos => "http://mavenrepo.openmrs.org/nexus/content/repositories/public",
    require => [ Package['maven'], Service[$tomcat], File["/home/${tomcat}/.OpenMRS/modules"] ],
    notify  => exec ['tomcat-restart']
  }

  exec { 'tomcat-restart':
    command     => "service ${tomcat} restart",
    user        => 'root',
    refreshonly => true
  }

}
