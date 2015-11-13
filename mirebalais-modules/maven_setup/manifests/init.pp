
# Install Maven
class maven_setup() {

  class {'maven':
      version => "3.2.5",
  }

  # defaults for all maven{} declarations
  Maven {
    user  => "maven", # you can make puppet run Maven as a specific user instead of root, useful to share Maven settings and local repository
    group => "maven", # you can make puppet run Maven as a specific group
    repos => "http://mavenrepo.openmrs.org/nexus/content/repositories/public2"
  }

}