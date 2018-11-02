class openmrs::pwa (
  $tomcat = hiera('tomcat'),
  $tomcat_webapp_dir = hiera('tomcat_webapp_dir'),
  $package_release = hiera('package_release'),
  $pwa_pih_liberia = hiera('pwa_pih_liberia')
) {

  # TODO: once we upgrade to Puppet 4.4+ we can just specific the file as as source (and therefore may not need exec wget and download every run)
  # TODO: come up with a more streamlined way to do this & handle versioning and whether we are installing a "stable" version or not, whether to switch Adds On and Bamboo, etc

  if ($pwa_pih_liberia) {
    # install PIH Liberia from bamboo
    exec { 'retrieve_pih_liberia_pwa':
      command => "/usr/bin/wget -q http://bamboo.pih-emr.org/pwa-repo/${package_release}
        openmrs-pwa-pih-liberia.tar.gz -O ${tomcat_webapp_dir}/openmrs-pwa-pih-liberia.tar.gz",
      require => Service["$tomcat"],
      notify => File["${tomcat_webapp_dir}/openmrs-pwa-pih-liberia"]
    }

    # remove old directory
    file { "${tomcat_webapp_dir}/pih-liberia":
      ensure   => absent,
      require => Exec['retrieve_pih_liberia_pwa']
    }

    exec { 'extract pwa pih liberia' :
      command => "tar -xvf ${tomcat_webapp_dir}/openmrs-pwa-pih-liberia.tar.gz",
      require => Exec["${tomcat_webapp_dir}/openmrs-pwa-pih-liberia"],
      notify  => Exec['tomcat-restart']
    }
  }


}

