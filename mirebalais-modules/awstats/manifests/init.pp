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

    # NOTE THAT we are currenlty *disabling* awstats
    cron { 'update awstats':
    	 ensure => absent,
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
