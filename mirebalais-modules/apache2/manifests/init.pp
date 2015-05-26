class apache2 (
  $tomcat = hiera('tomcat'),
  $services_ensure = hiera('services_ensure'),
  $services_enable = hiera('services_enable'),
  $site_domain = hiera('site_domain'),
  $webapp_name = hiera('webapp_name'),
  $ssl_cert_file = hiera('ssl_cert_file'),
  $ssl_chain_file = hiera('ssl_chain_file'),
  $ssl_key_file = hiera('ssl_key_file'),
){
  
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

  file { "/etc/ssl/certs/${ssl_cert_file}":
    ensure => file,
    source => "puppet:///modules/apache2/etc/ssl/certs/${ssl_cert_file}",
  }

  file { "/etc/ssl/certs/${ssl_chain_file}":
    ensure => file,
    source => "puppet:///modules/apache2/etc/ssl/certs/${ssl_chain_file}",
  }

  file { "/etc/ssl/private/${ssl_key_file}":
    ensure => present,
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
