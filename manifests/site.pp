Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }

node default {
  class { 'apt':
    always_apt_update => true,
  }
  
  class { 'newrelic': 
    license => 'ee619f9f928541a5fde6afb4a28016e9a89f137f',
  }

  include wget
  include java
  include mysql_setup_56
  include mirth
  include tomcat
  include openmrs
}

node /^((?!replication).*)$/ inherits default {
  include mysql_setup::db_setup
  include mirth::channel_setup
  include openmrs::initial_setup
}

node 'emr.hum.ht' inherits default {
  include ntpdate
  include apache2
  include awstats
  include logging
  include mysql_setup::db_setup
  include mysql_setup::backup
  include mysql_setup::replication
  include mirth::channel_setup
  include openmrs::initial_setup
}

node 'emrreplication.hum.ht' inherits default {
  include ntpdate
  include apache2
  include awstats
  include logging
  include logging::kibana
  include mysql_setup::slave
}

node 'reporting.hum.ht' {
  class { 'apt':
    always_apt_update => true,
  }

  include wget
  include java
  include mysql_setup_56  
  include tomcat
  include openmrs
  include ntpdate
  include apache2
  include awstats  
  include mysql_setup::slave
}

node 'emrtest.hum.ht' inherits default {
  include apache2
  include awstats
  include ntpdate
  include mysql_setup::db_setup
  include mirth::channel_setup
  include openmrs::initial_setup
}

node 'humdemo.pih-emr.org' inherits default {
  include apache2
  include awstats
  include mysql_setup::db_setup
  include mirth::channel_setup
  include openmrs::initial_setup
}

