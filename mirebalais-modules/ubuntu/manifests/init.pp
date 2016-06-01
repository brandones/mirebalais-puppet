class ubuntu (
  $permit_root_login = hiera('permit_root_login'),
  $ssh_password_authentication = hiera('ssh_password_authentication')
){

  # **NOTE: Be careful when modifying this file via puppet because a mistake could kill ssh access to a server**
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
