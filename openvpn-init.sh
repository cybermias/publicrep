#!/bin/bash

#Script accepts userPassword for openvpn and must recieve VNET with CIDR prefix
userPassword=$1
vnet=$2

#download the packages
cd /tmp
#wget -c http://swupdate.openvpn.org/as/openvpn-as-2.5-Ubuntu16.amd_64.deb
wget -c http://swupdate.openvpn.org/as/openvpn-as-2.5.2-Ubuntu16.amd_64.deb

#install the software
sudo dpkg -i openvpn-as-2.5.2-Ubuntu16.amd_64.deb

#update the password for user openvpn
sudo echo "openvpn:$userPassword"|sudo chpasswd

sudo apt-get install sqlite3

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



