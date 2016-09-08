#! /bin/bash

if [ -z "$1" ]
then
  echo "You need to provide the name of the manifest to install"
  echo "./puppet-apply.sh MANIFEST"
  echo "MANIFEST can be malawi|site|default-openmrs|bahmni"
  exit 1
fi

puppet apply -v -d\
  --detailed-exitcodes \
  --logdest=console \
  --logdest=syslog \
  manifests/$1.pp

test $? -eq 0 -o $? -eq 2
