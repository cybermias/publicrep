#!/bin/bash

#Script accepts userPassword for openvpn and must recieve VNET with CIDR prefix
userPassword=$1
vnet=$2

#download the packages
cd /tmp
wget -c http://swupdate.openvpn.org/as/openvpn-as-2.5-Ubuntu16.amd_64.deb

#install the software
sudo dpkg -i openvpn-as-2.5-Ubuntu16.amd_64.deb

#update the password for user openvpn
sudo echo "openvpn:$userPassword"|sudo chpasswd

#configure server network settings
PUBLICIP=$(curl -s ipecho.net/plain)
sudo apt-get install sqlite3
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config.db" "update config set value='$PUBLICIP' where name='host.name';"
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config.db" "update config set value='$vnet' where name='vpn.server.routing.private_network.0';"
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config.db" "update config set value='false' where name='vpn.client.routing.reroute_gw';"

#restart OpenVPN AS service
sudo systemctl restart openvpnas

#Remember to verify IP with every boot (for dynamic IP)
sudo echo '#!/bin/bash' > /opt/fixvpnpip.sh
sudo echo 'PUBLICIP=$(curl -s ipecho.net/plain)' >> /opt/fixvpnpip.sh
sudo echo 'sudo sqlite3 "/usr/local/openvpn_as/etc/db/config.db" "update config set value='"'"'$PUBLICIP'"'"' where name='"'"'host.name'"'"';"' >> /opt/fixvpnpip.sh
sudo chmod +x /opt/fixvpnpip.sh

sudo echo 'sh /opt/fixvpnpip.sh' > /etc/rc.local

