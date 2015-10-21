class mysql::db_setup(
  $openmrs_db = hiera('openmrs_db'),
  $openmrs_db_user = decrypt(hiera('openmrs_db_user')),
  $openmrs_db_password = decrypt(hiera('openmrs_db_password')),
  $mirth_db = hiera('mirth_db'),
  $mirth_db_user = decrypt(hiera('mirth_db_user')),
  $mirth_db_password = decrypt(hiera('mirth_db_password')),
) {

  mysql_database { $openmrs_db :
    ensure  => present,
    require => [Service['mysqld'],  Package['pihemr']],
    charset => 'utf8',
  } ->

  mysql_user { "${openmrs_db_user}@localhost":
    ensure        => present,
    password_hash => mysql_password($openmrs_db_password),
    require => [ Service['mysqld'], Package['pihemr']],
  } ->

  mysql_grant { "${openmrs_db_user}@localhost/${openmrs_db}":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "${openmrs_db_user}@localhost",
    require => [ Service['mysqld'],  Package['pihemr']],
  } ->

  mysql_grant { "root@localhost/${openmrs_db}":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "root@localhost",
    require => [Service['mysqld'],  Package['pihemr']],
    notify  => Openmrs::Liquibase_migrate ['migrate base schema'];
  }

  mysql_database { $mirth_db :
    ensure  => present,
    charset => 'utf8',
    require => [Service['mysqld'], Package['pihemr']],
  }

  mysql_user { "${mirth_db_user}@localhost":
    ensure        => present,
    password_hash => mysql_password($mirth_db_password),
    require       => Service['mysqld'],
  } ->

  mysql_grant { "${mirth_db_user}@localhost/${mirth_db}":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "${mirth_db_user}@localhost",
    require    => Service['mysqld'],
  } ->

  mysql_grant { "root@localhost/${mirth_db}":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "root@localhost",
    require    => Service['mysqld'],
  }

  mysql_grant { "${mirth_db_user}@localhost/${openmrs_db}.pacsintegration_outbound_queue":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "{mirth_db_user}@localhost",
    require    => [ Service['mysqld'], Mysql_database[$openmrs_db] ]
  }
}
