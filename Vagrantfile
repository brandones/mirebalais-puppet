# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "bahmni.pih-emr.org"
  config.vm.network "forwarded_port", guest: 80, host: 8180
  config.vm.network "forwarded_port", guest: 443, host: 8143
  config.vm.network "forwarded_port", guest: 8080, host: 8081
  config.vm.network "forwarded_port", guest: 8443, host: 8443

  config.vm.provider :virtualbox do |vb|
     vb.customize ["modifyvm", :id, "--memory", "4096"]
   end

end
