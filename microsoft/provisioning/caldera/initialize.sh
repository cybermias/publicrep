#!/bin/sh

# Script will update caldera by git, and enforce it to run locally inside ATLAS lab (i.e 10.200.11.100).
# Used with snapshot running golang1.16 and caldera git 3.1.0

apt-get install net-tools
# Adapt the local.yml file at conf directory to initialize caldera as the current local IP
ip="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1-4 | cut -d/ -f1)"
sed -i -e "s/0.0.0.0/$ip/g" /home/cmtsadmin/caldera/conf/local.yml

# Manx requires websocket to work back to caldera operator browser (since it can be through iptables of openvpn, we reserve the 0.0.0.0:7012 in that line only):
sed -i -e "s/app.contact.websocket:.*/app.contact.websocket: 0\.0\.0\.0:7012/g" /home/cmtsadmin/caldera/conf/local.yml

kill -9 $(pgrep -f 'server.py')


echo "script completed" > /home/cmtsadmin/finished
shutdown -r 1



#cd /home/cmtsadmin/caldera
#/usr/bin/python3 server.py
