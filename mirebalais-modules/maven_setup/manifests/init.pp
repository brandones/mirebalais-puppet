
# Install Maven
class maven_setup() {

  package { 'maven':
    ensure => installed,
  }

  # defaults for all maven{} declarations
  Maven {
    repos => "http://mavenrepo.openmrs.org/nexus/content/repositories/public2"
  }

}