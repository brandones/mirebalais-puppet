class letsencrypt (
  $site_domain = hiera('site_domain')
) {

  apt::ppa { 'ppa:certbot/certbot': }

  package { 'software-properties-common':
    ensure => present
  }

  package { 'python-certbot-apache':
    ensure => present,
    require => [Apt::Ppa['ppa:certbot/certbot']]
  }

  exec { 'generate certificates':
    command => "certbot -n -m medinfo@pih.org --apache --agree-tos --domains ${site_domain} certonly",
    user    => 'root',
    require => Package['software-properties-common'],
    subscribe => Package['python-certbot-apache']
  }

}

