class bahmni::config (
  $tomcat = hiera('tomcat')
){

  vcsrepo { "/usr/local/${tomcat}/webapps/bahmni-config":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/Bhamni/default-config.git',     # TODO switch to use implementation-specific config
    revision => 'master',                                           # TODO switch to be driven by variable (which comes from manifest?)
    require => [Service[$tomcat],Package['git']]
  }

}
