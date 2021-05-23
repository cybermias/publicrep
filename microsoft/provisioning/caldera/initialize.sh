#!/bin/bash

# Script will update caldera by git, and enforce it to run locally inside ATLAS lab (i.e 10.200.11.100).
# Used with snapshot running golang1.16 and caldera git 3.1.0

apt-get update
pip3 install --upgrade setuptools
cd /opt/caldera

# Adapt the local.yml file at conf directory to initialize caldera as the current local IP
ip=$(ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
sed -i -e "s/0.0.0.0/$ip/g" /opt/caldera/conf/local.yml

service caldera restart
