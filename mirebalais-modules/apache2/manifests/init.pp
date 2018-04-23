class apache2 (
  $tomcat = hiera('tomcat'),
  $services_ensure = hiera('services_ensure'),
  $services_enable = hiera('services_enable'),
  $site_domain = hiera('site_domain'),
  $webapp_name = hiera('webapp_name'),
  $ssl_cert_file = hiera('ssl_cert_file'),
  $ssl_chain_file = hiera('ssl_chain_file'),
  $ssl_key_file = hiera('ssl_key_file'),
  $ssl_cert_dir = hiera('ssl_cert_dir'),
  $ssl_key_dir = hiera('ssl_key_dir'),
  $ssl_install_cert = hiera('ssl_install_cert'),
  $biometrics_enabled = hiera('biometrics_enabled'),
  $biometrics_webapp_name = hiera('biometrics_webapp_name'),
  $biometrics_port = hiera('biometrics_port')
){
  
  package { 'apache2':
    ensure => installed,
  } ->

  package { 'libapache2-mod-jk':
    ensure => installed,
  } ->

  file { '/etc/logrotate.d/apache2':
    ensure  => file,
    content  => template('apache2/logrotate.erb')
  } ->

  file { '/etc/apache2/workers.properties':
    ensure  => present,
    content => template('apache2/workers.properties.erb'),
    notify  => Service['apache2']
  } ->

  file { '/etc/apache2/ports.conf':
    ensure => present,
    source => 'puppet:///modules/apache2/ports.conf',
    notify => Service['apache2']
  } ->

  file { '/etc/apache2/mods-available/jk.conf':
    ensure => present,
    source => 'puppet:///modules/apache2/jk.conf',
    notify => Service['apache2']
  } ->

  file { '/etc/apache2/sites-available/default-ssl.conf':
    ensure => present,
    content => template('apache2/default-ssl.conf.erb'),
    notify => Service['apache2']
  } ->

  file { '/etc/apache2/sites-available/default':
    ensure => absent
  } ->

  file { '/etc/apache2/sites-available/000-default.conf':
    ensure => file,
    source => 'puppet:///modules/apache2/sites-available/000-default.conf',
    notify => Service['apache2']
  } ->

  file { '/var/www/html/.htaccess':
    ensure => file,
    source => 'puppet:///modules/apache2/www/htaccess'
  } ->

  file { '/var/www/html/index.html':
    ensure => file,
    content => template('apache2/index.html.erb')
  } ->

  if ($ssl_install_cert == true) {
    file { "${ssl_cert_dir}/${ssl_cert_file}":
      ensure => file,
      source => "puppet:///modules/apache2/etc/ssl/certs/${ssl_cert_file}",
      unless => $ssl_install_cert == false
    } ->

    file { "${ssl_cert_dir}/${ssl_chain_file}":
      ensure => file,
      source => "puppet:///modules/apache2/etc/ssl/certs/${ssl_chain_file}",
    } ->

    file { "${ssl_key_dir}/${ssl_key_file}":
      ensure => present,
    } ->
  }

  exec { 'enable and disable apache mods':
    command     => 'a2enmod jk && a2enmod deflate && a2enmod ssl && a2ensite default-ssl && a2enmod rewrite & a2dismod php5',
    user        => 'root',
    subscribe   => [ Package['apache2'], Package['libapache2-mod-jk'] ],
    refreshonly => true,
    notify      => Service['apache2']
  } ->

  service { 'apache2':
    ensure   => $services_ensure,
    enable   => $services_enable,
    require  => [ Package['apache2'], Package['libapache2-mod-jk'] ],
  }
}
