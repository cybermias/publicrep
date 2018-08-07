#!/bin/bash

# Script considers openvpn to already be installed (at time of creation, the version that exists is 2.5.2) and "openvpn" user exists

# Script accepts userPassword for openvpn and must either recieve (or calculate) VNET with CIDR prefix - In this version VNET is calculated (SNAPSHOTs)
userPassword=$1
vnet="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1-2).0.0/16"

# Packages were already downloaded as per snapshot

# Regardless of Snapshot, openvpn user is changed accordingly update the password for user openvpn
sudo echo "openvpn:$userPassword"|sudo chpasswd

sudo apt-get install sqlite3

sudo echo '127.0.0.1 CMTS-OVPN' >> /etc/hosts

#configure server network settings
PUBLICIP=$(curl -s ipecho.net/plain)
while [ ! $PUBLICIP ]; do
        PUBLICIP=$(curl -s ipecho.net/plain)
done

echo $PUBLICIP > /opt/publicip
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config.db" "update config set value='$PUBLICIP' where name='host.name';"
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config.db" "update config set value='$vnet' where name='vpn.server.routing.private_network.0';"
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config.db" "update config set value='false' where name='vpn.client.routing.reroute_gw';"

#restart OpenVPN AS service
sudo systemctl restart openvpnas

#Remember to verify IP with every boot (for dynamic IP)
sudo echo '#!/bin/bash' > /etc/init.d/fixvpnpip.sh
sudo echo 'PUBLICIP=$(curl -s ipecho.net/plain)' >> /etc/init.d/fixvpnpip.sh
sudo echo 'while [ ! $PUBLICIP ]; do' >> /etc/init.d/fixvpnpip.sh
sudo echo '        PUBLICIP=$(curl -s ipecho.net/plain)' >> /etc/init.d/fixvpnpip.sh
sudo echo 'done' >> /etc/init.d/fixvpnpip.sh
sudo echo 'sudo sqlite3 "/usr/local/openvpn_as/etc/db/config.db" "update config set value='"'"'$PUBLICIP'"'"' where name='"'"'host.name'"'"';"' >> /etc/init.d/fixvpnpip.sh
chmod ugo+x /etc/init.d/fixvpnpip.sh
sudo update-rc.d fixvpnpip.sh defaults
