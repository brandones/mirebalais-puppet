
# Install Git
class git() {

  package { 'git':
    ensure => installed,
  }

}