Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }

node default {

  class { 'apt':
    always_apt_update => true,
  }

  include security
  include mailx
  include ntpdate
  include apt_upgrades
  include wget
  include newrelic

  include java
  include mysql_setup
  include apache2
  include tomcat

  #include openmrs_lesotho
}