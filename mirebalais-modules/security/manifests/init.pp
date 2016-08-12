class security () {

  # patch for http://thehackernews.com/2016/08/linux-tcp-packet-hacking.html
  file { '/etc/sysctl.conf':
    ensure => present,
  }->
  file_line { 'patch-sysctl.conf':
    path => '/etc/sysctl.conf',
    line => 'net.ipv4.tcp_challenge_ack_limit = 999999999',
  }

  exec { 'restart-sysctl':
    command => 'sysctl -p',
    refreshonly => true,
    subscribe => [ File_line['patch-sysctl.conf'] ]
  }

}