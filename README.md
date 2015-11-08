sePuppet project for automatically create required infrastructure for Mirebalais OpenMRS-based app.

More info:
- https://github.com/PIH/openmrs-module-mirebalais
- http://mirebalaisemr.blogspot.com.br/


Using Vagrant:

* vagrant up
* vagrant ssh
* sudo apt-get install openssh-server git
* sudo rm -fR /etc/puppet
* sudo mkdir /etc/puppet
* sudo cp -a /vagrant/* /etc/puppet/
* cd /etc/puppet
* sudo ./install.sh local