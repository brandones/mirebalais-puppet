class bahmni_openmrs::config (
  $tomcat = hiera('tomcat')
){

  vcsrepo { '/usr/local/tomcat7/webapps/bahmni-config':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/Bhamni/default-config.git',     # TODO switch to use implementation-specific config
    revision => 'master',
    require => [Service[$tomcat],Package['git']]
  }

}
