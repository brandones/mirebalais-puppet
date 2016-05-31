class ubuntu (
  $permit_root_login = hiera('permit_root_login'),
  $ssh_password_authentication = hiera('ssh_password_authentication')
){

  file { "/etc/ssh/sshd_config":
    ensure  => present,
    owner   => root,
    group   => root,
    content => template("ubuntu/sshd_config.erb")
  }

  service { 'ssh':
    restart  => true,
    require => [ File["/etc/ssh/sshd_config"] ]
  }

}
