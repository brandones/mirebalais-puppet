#! /bin/bash

if [ ! -d /etc/puppet-decrypt ]
then
    mkdir /etc/puppet-decrypt
fi

if [ "$1" != "local" ]
then
  if [ ! -f /etc/puppet-decrypt/encryptor_secret_key ] || [ ! -f /etc/ssl/private/hum.key ] || [ ! -f /etc/ssl/private/pih-emr.org.key ]
  then
    echo "Please provide a username to fetch private data"
    read user

    scp $user@amigo.pih-emr.org:/etc/mirebalais/* .

    mv encryptor_secret_key /etc/puppet-decrypt/
    mv hum.key /etc/ssl/private/
    mv pih-emr.org.key /etc/ssl/private/
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

# For Haiti servers, don't update the tzdata package
if [$HOSTNAME == ""]
then
    apt-mark hold tzdata
fi



apt-get update

# hack to make sure we have ruby1.9 installed instead of ruby1.8
if [ $(lsb_release -rs) == "14.04" ]
then
cp -r Gemfile1404 Gemfile
apt-get remove ruby1.8
apt-get install -y ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 \
build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev

gem install bundler --no-ri --no-rdoc

bundle

librarian-puppet install
fi

if [ $(lsb_release -rs) == "16.04" ]
then
add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty universe'
apt-get -y update
apt-get -y upgrade
cp -r Gemfile1604 Gemfile
sudo apt-get -y install build-essential ruby-full

gem install bundler --no-ri --no-rdoc

bundle
bundle update
librarian-puppet install

mkdir -p /opt/puppetlabs
mkdir -p /opt/puppetlabs/puppet
mkdir -p /etc/puppetlabs
mkdir -p /etc/puppetlabs/puppet
mkdir -p /var/log/puppetlabs/
mkdir -p /var/log/puppetlabs/puppet
cp -r puppet-apply-1604.sh puppet-apply.sh
#cp -r mirebalais-modules/ntpdate/templates/ntp.conf1604.erb mirebalais-modules/ntpdate/templates/ntp.conf.erb

fi

echo "modulepath = $(pwd)/modules:$(pwd)/mirebalais-modules" > puppet.conf
echo "environment = $1" >> puppet.conf

#replace /etc/puppet/hieradata with $(pwd)/hieradata in hiera.yaml
#sed -i '/etc/puppet/c\$(pwd)' $(pwd)/hiera.yaml
sed -i "s|/etc/puppet|\"$(pwd)\"|g" hiera.yaml
sed -i 's|"||g' hiera.yaml