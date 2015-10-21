Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }

node default {

  class { 'apt':
    always_apt_update => true,
  }

  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include newrelic

  include java
  include mysql
  include apache2
  include tomcat

   include openmrs
   include openmrs::initial_setup
   include mysql::db_setup

}
