class openmrs::initial_setup(
  $openmrs_db = hiera('openmrs_db'),
  $openmrs_db_user = decrypt(hiera('openmrs_db_user')),
  $openmrs_db_password = decrypt(hiera('openmrs_db_password')),
  $tomcat = hiera('tomcat'),
) {

  exec { 'tomcat-start':
    command     => "service ${tomcat} start",
    user        => 'root',
    subscribe   => Openmrs::Liquibase_migrate['migrate update to latest'],
    refreshonly => true
  }
}
