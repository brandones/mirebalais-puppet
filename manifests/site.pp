node default {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }
  include mirebalais

  if $environment != 'test' {
    include mirebalais_logging
  }

}