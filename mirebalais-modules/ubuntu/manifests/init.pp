class ubuntu (
  $restrict_root_login = hiera('restrict_root_login')
){

  package { "ruby-augeas" :
    ensure => installed
  }

  if $restrict_root_login {
    # we change default root login to only allow key-based access
    augeas { "sshd_config":
      context => "/etc/ssh/sshd_config",
      changes => [
        "set PermitRootLogin without-password"
      ],
      require => Package["ruby-augeas"]
    }
  }

}
