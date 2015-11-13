
# Install Maven
class maven_setup() {

  package { 'maven':
    ensure => installed,
  }

}