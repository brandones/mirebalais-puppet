Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }

node default {
  class { 'apt':
    always_apt_update => true,
  }

  include wget
  include java
  include mysql
  include mysql_setup
  include mysql_setup::db_setup
  include apache2
  include awstats
  include tomcat
  include openmrs
  include openmrs::initial_setup
}
