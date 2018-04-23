class letsencrypt () {

  apt::ppa { 'ppa:certbot/certbot': }
  apt::ppa { 'ppa:openjdk-r/ppa': }

  package { 'software-properties-common':
    ensure => present
  }

  package { 'python-certbot-apache':
    ensure => present,
    require => [Apt::Ppa['ppa:certbot/certbot']]
  }

}

