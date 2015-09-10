#! /bin/bash

puppet apply -v \
  --detailed-exitcodes \
  --logdest=console \
  --logdest=syslog \
  manifests/site.pp

test $? -eq 0 -o $? -eq 2
