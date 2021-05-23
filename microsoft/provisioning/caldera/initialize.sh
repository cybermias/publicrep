#!/bin/bash

# Script will update caldera by git, and enforce it to run locally inside ATLAS lab (i.e 10.200.11.100).
# Used with snapshot running golang1.16 and caldera git 3.1.0

# Adapt the local.yml file at conf directory to initialize caldera as the current local IP
ip="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1-4 | cut -d/ -f1)"
sudo sed -i -e "s/0.0.0.0/$ip/g" /home/cmtsadmin/caldera/conf/local.yml

sudo kill -9 $(pgrep -f 'server.py')

sudo reboot now

#cd /home/cmtsadmin/caldera
#/usr/bin/python3 server.py
