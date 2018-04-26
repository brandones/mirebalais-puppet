class owa (
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

  file { "/home/${tomcat}/.OpenMRS/owa/cohortbuilder-${owa_cohort_builder_version}.zip":
    ensure  => present,
    source  => "https://dl.bintray.com/openmrs/owa/cohortbuilder-${owa_cohort_builder_version}.zip",
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0644',
    require => File["/home/${tomcat}/.OpenMRS/owa"]
  }

}
