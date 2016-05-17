class ubuntu (

){

  package { "ruby-augeas" :
    ensure => installed
  }

  # we change default root login to only allow key-based access
  augeas { "sshd_config":
    context => "/etc/ssh/sshd_config",
    changes => [
      "set PermitRootLogin without-password"
    ],
    require => Package["ruby-augeas"]
  }

}
