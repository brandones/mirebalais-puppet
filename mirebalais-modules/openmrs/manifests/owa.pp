class owa (
  $tomcat = hiera('tomcat'),
  $owa_cohort_builder_version = hiera('owa_cohort_builder_version'),
) {

  # add the owas that we use
  # TODO: add the ability to customize based on deployment, and/or use staging versions
  # TODO: this could become a pattern for installing modules as well?
  file { "/home/${tomcat}/.OpenMRS/owa":
    ensure  => directory,
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0755',
    require => User[$tomcat]
  }

  # once we upgrade to Puppet 4.4+ we can just specific the file as as source (and therefore may not need to run this every time)
  exec{'retrieve_cohort_builder_owa':
    command => "/usr/bin/wget -q https://dl.bintray.com/openmrs/owa/cohortbuilder-${owa_cohort_builder_version}.zip -O /home/${tomcat}/.OpenMRS/owa/cohortbuilder-${owa_cohort_builder_version}.zip",
    creates => "/home/${tomcat}/.OpenMRS/owa/cohortbuilder-${owa_cohort_builder_version}.zip",
    require => File["/home/${tomcat}/.OpenMRS/owa"]
  }

  file { "/home/${tomcat}/.OpenMRS/owa/cohortbuilder-${owa_cohort_builder_version}.zip":
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => Exec['retrieve_cohort_builder_owa']
  }

}
