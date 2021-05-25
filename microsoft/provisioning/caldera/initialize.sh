#!/bin/sh

# Script will update caldera by git, and enforce it to run locally inside ATLAS lab (i.e 10.200.11.100).
# Used with snapshot running golang1.16 and caldera git 3.1.0

apt-get install net-tools
# /// # Adapt the local.yml file at conf directory to initialize caldera as the current local IP
# When this was used internally, the upcoming lines will extract the internal IP. The current script version will refer to the external IP.
#ip="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1-4 | cut -d/ -f1)"
#sed -i -e "s/0.0.0.0/$ip/g" /home/cmtsadmin/caldera/conf/local.yml
# // # The following commands will only be relevant in an internal caldera deployment (and are currently DISABLED)
# Manx requires websocket to work back to caldera operator browser (since it can be through iptables of openvpn, we reserve the 0.0.0.0:7012 in that line only):
#sed -i -e "s/app.contact.websocket:.*/app.contact.websocket: 0\.0\.0\.0:7012/g" /home/cmtsadmin/caldera/conf/local.yml


# // # Adapt the local.yml file at conf directory to initialize caldera as the current external IP
PUBLICIP=$(curl -s ipecho.net/plain)
while [ ! $PUBLICIP ]; do
        PUBLICIP=$(curl -s ipecho.net/plain)
done
sed -i -e "s/app.contact.dns.socket:.*/app.contact.dns.socket: $PUBLICIP:8853/g" /home/cmtsadmin/caldera/conf/local.yml
sed -i -e "s/app.contact.http:.*/app.contact.http: http:\/\/$PUBLICIP:8888/g"  /home/cmtsadmin/caldera/conf/local.yml
sed -i -e "s/app.contact.tcp:.*/app.contact.tcp: $PUBLICIP:7010/g"  /home/cmtsadmin/caldera/conf/local.yml
sed -i -e "s/app.contact.udp:.*/app.contact.udp: $PUBLICIP:7011/g"  /home/cmtsadmin/caldera/conf/local.yml
sed -i -e "s/app.contact.websocket:.*/app.contact.websocket: $PUBLICIP:7012/g"  /home/cmtsadmin/caldera/conf/local.yml
sed -i -e "s/app.contact.dns.domain:.*/app.contact.dns.domain: $1/g"  /home/cmtsadmin/caldera/conf/local.yml

# Make sure the caldera OS is aware of its public IP (otherwise errors are shown and stability wasn't examined when server.py is run - cannot bind "public IP")
sudo cat <<EOF > /etc/netplan/60-static.yaml
network:
    version: 2
    ethernets:
        eth0:
            addresses:
                - $PUBLICIP/32
EOF
sudo netplan apply

echo "script completed" > /home/cmtsadmin/finished
shutdown -r 1


#cd /home/cmtsadmin/caldera
#/usr/bin/python3 server.py
