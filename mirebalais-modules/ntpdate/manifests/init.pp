class ntpdate(
  $timezone = hiera('server_timezone'),
  $server_1 = hiera('ntp_server_1'),
  $server_2 = hiera('ntp_server_2'),
  $server_3 = hiera('ntp_server_3'),
  $server_4 = hiera('ntp_server_4')
) {
  file { '/etc/ntp.conf':
    content => template('ntpdate/ntp.conf.erb')
  }

  file { '/etc/default/rcS':
    source => 'puppet:///modules/ntpdate/etc/rcS_default'
  }

  file { '/etc/timezone':
       ensure => present,
       content => "${timezone}\n"
  }

  exec { 'stop ntp':
    command     => 'service ntp stop',
    subscribe   => [ File['/etc/ntp.conf'], File['/etc/timezone'] ],
    refreshonly => true
  }

  exec { 'update time':
    command     => 'ntpdate-debian',
    subscribe   => Exec['stop ntp'],
    refreshonly => true
  }

  exec { 'start ntp':
    command     => 'service ntp start',
    subscribe   => Exec['update time'],
    refreshonly => true
  }
}
