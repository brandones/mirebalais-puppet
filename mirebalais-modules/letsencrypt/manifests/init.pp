class letsencrypt () {

  apt::ppa { 'ppa:certbot/certbot': }

  package { 'software-properties-common':
    ensure => present
  }

  package { 'python-certbot-apache':
    ensure => present,
    require => [Apt::Ppa['ppa:certbot/certbot']]
  }

}

