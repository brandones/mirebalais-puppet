class apache2 (
  $tomcat = hiera('tomcat'),
  $services_ensure = hiera('services_ensure'),
  $services_enable = hiera('services_enable'),
  $site_domain = hiera('site_domain'),
  $webapp_name = hiera('webapp_name'),
){

  $ssl_cert_file = $domain ? {
    'hum.ht'      => 'gd_bundle-g2.crt',
    'pih-emr.org' => '_.pih-emr.org.crt',
    default       => '_.pih-emr.org.crt',
  }

  $ssl_cert_chain_file = $domain ? {
    'hum.ht'      => 'hum.ht.crt',
    'pih-emr.org' => 'gd_bundle.crt',
    default       => 'gd_bundle.crt',
  }

  $ssl_key_file = $domain ? {
    'hum.ht'      => 'hum.key',
    'pih-emr.org' => 'pih-emr.org.key',
    default       => 'pih-emr.org.key',
  }
  
  package { 'apache2':
    ensure => installed,
  }

  package { 'libapache2-mod-jk':
    ensure => installed,
  }

  file { '/etc/logrotate.d/apache2':
    ensure  => file,
    content  => template('apache2/logrotate.erb'),
  }

  file { '/etc/apache2/workers.properties':
    ensure  => present,
    content => template('apache2/workers.properties.erb'),
    notify  => Service['apache2']
  }

  file { '/etc/apache2/mods-available/jk.conf':
    ensure => present,
    source => 'puppet:///modules/apache2/jk.conf',
    notify => Service['apache2']
  }

  file { '/etc/apache2/sites-available/default-ssl':
    ensure => present,
    content => template('apache2/default-ssl.erb'),
    notify => Service['apache2']
  }

  file { '/etc/apache2/sites-available/default':
    ensure => file,
    source => 'puppet:///modules/apache2/sites-available/default',
    notify => Service['apache2']
  }

  file { '/etc/ssl/certs/${ssl_cert_file}':
    ensure => present,
    source => 'puppet:///modules/apache2/etc/ssl/certs/$ssl_cert_file',
    notify => Service['apache2']
  }

  file { '/etc/ssl/certs/${ssl_cert_chain_file}':
    ensure => present,
    source => 'puppet:///modules/apache2/etc/ssl/certs/$ssl_cert_chain_file',
    notify => Service['apache2']
  }

  exec { 'enable apache mods':
    command     => 'a2enmod jk && a2enmod deflate && a2enmod ssl && a2ensite default-ssl && a2enmod rewrite',
    user        => 'root',
    subscribe   => [ Package['apache2'], Package['libapache2-mod-jk'] ],
    refreshonly => true,
    notify      => Service['apache2']
  }

  service { 'apache2':
    ensure   => $services_ensure,
    enable   => $services_enable,
    require  => [ Package['apache2'], Package['libapache2-mod-jk'] ],
  }
}
