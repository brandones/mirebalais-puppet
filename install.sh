#! /bin/bash

if [ -z "$1" ]
then
  echo "You need to provide the environment to install in:"
  echo "./install.sh ENVIRONMENT"
  echo "ENVIRONMENT can be test|production"
  exit 1
fi

if [ ! -d /etc/puppet-decrypt ]
then
    mkdir /etc/puppet-decrypt
fi

if [ "$1" != "test" ]
then
  if [ ! -f /etc/puppet-decrypt/encryptor_secret_key ] || [ ! -f /etc/ssl/private/hum.key ]
  then
    echo "Please provide a username to fetch private data"
    read user

    scp $user@dev.pih-emr.org:/etc/mirebalais/* .

    mv encryptor_secret_key /etc/puppet-decrypt/
    mv hum.key /etc/ssl/private/
  fi

  if [ ! -f ~/.ssh/id_dsa ]
  then
    ssh-keygen -q -t dsa -f ~/.ssh/id_dsa -P ''
  fi

  echo "Please make sure you have copied this ssh public key to the backup server so that database backups can be uploaded there:"
  cat ~/.ssh/id_dsa.pub
  read -p "Press a key to continue"

else
    if [ !  -f /etc/puppet-decrypt/encryptor_secret_key ]
    then
	echo "Creating a dummy secret key"
	ssh-keygen -N testmeout -f /etc/puppet-decrypt/encryptor_secret_key
    fi
fi 


apt-get update
apt-get remove ruby1.8
apt-get install -y ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 \
build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev

gem install bundler --no-ri --no-rdoc

bundle

librarian-puppet install

echo "modulepath = /etc/puppet/modules:/etc/puppet/mirebalais-modules" > puppet.conf
echo "environment = $1" >> puppet.conf

puppet apply -v \
  --detailed-exitcodes \
  --logdest=console \
  --logdest=syslog \
  manifests/site.pp

test $? -eq 0 -o $? -eq 2
