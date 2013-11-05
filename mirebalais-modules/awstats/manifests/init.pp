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

    exec { 'generate initial awstats':
        command => "/usr/lib/cgi-bin/awstats.pl -config=$site_domain -update",
        subscribe => [ Package['awstats'], File["/etc/awstats/awstats.$site_domain.conf"]]
    }

}