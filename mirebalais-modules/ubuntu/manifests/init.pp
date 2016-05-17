class ubuntu (
  $permit_root_login = hiera('permit_root_login')
){

  file { "/etc/ssh/sshd_config":
    ensure  => present,
    owner   => root,
    group   => root,
    content => template("ubuntu/sshd_config.erb")
  }


}
