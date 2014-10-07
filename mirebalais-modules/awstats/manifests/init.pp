class awstats(
      $site_domain = hiera('site_domain')
) {

    package { 'awstats':
  	    ensure => installed,
    }

    file { "/etc/awstats/awstats.$site_domain.conf":
    	 ensure => present,
	 content => template('awstats/awstats.conf.erb')
    }

    file { '/usr/lib/cgi-bin/.htpasswd':
    	 ensure => present,
	 source => 'puppet:///modules/awstats/htpasswd'
    }

    cron { 'update awstats':
    	 command => "/usr/lib/cgi-bin/awstats.pl -config=$site_domain -update > /dev/null",
	 user => root,
	 hour => 0,
	 environment => "MAILTO=emrsysadmin@pih.org"
    }

    exec { 'generate initial awstats':
        command => "/usr/lib/cgi-bin/awstats.pl -config=$site_domain -update",
        subscribe => [ Package['awstats'], File["/etc/awstats/awstats.$site_domain.conf"]]
    }

}
