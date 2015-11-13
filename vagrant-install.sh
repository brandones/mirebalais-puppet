#! /bin/bash

sudo apt-get install -y git openssh-server emacs
sudo rm -fR /etc/puppet
cd /etc
sudo git clone https://github.com/PIH/mirebalais-puppet.git puppet
cd puppet
sudo git checkout master
