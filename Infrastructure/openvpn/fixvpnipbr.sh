#!/bin/bash
vnet="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1-2).0.0/16"
static="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1-2).253.252"
brnet="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1-2).253.240"

PUBLICIP=$(curl -s ipecho.net/plain)
while [ ! $PUBLICIP ]; do
        PUBLICIP=$(curl -s ipecho.net/plain)
done

# After OpenVPN 2.7.3 update config.db required changes were moved to config_local.db
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config_local.db" "update config set value='$vnet' where name='vpn.server.routing.private_network.0';"
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config_local.db" "update config set value='$PUBLICIP' where name='host.name';"

# Assigning static IP to user profile cmtsadmin - enforcing bridged connection! (VERSION BEFORE SACLI)
#sudo sqlite3 "/usr/local/openvpn_as/etc/db/userprop.db" "insert into config VALUES(3,'conn_ip','$static');"
#sudo sqlite3 "/usr/local/openvpn_as/etc/db/userprop.db" "insert into config VALUES(3,'access_from.0','+ALL_S2C_SUBNETS');"
#sudo sqlite3 "/usr/local/openvpn_as/etc/db/userprop.db" "insert into config VALUES(3,'access_to.0','+ROUTE:$vnet');"
#sudo sqlite3 "/usr/local/openvpn_as/etc/db/config.db" "insert into config VALUES(1,'vpn.server.static.0.netmask_bits','24');"
#sudo sqlite3 "/usr/local/openvpn_as/etc/db/config.db" "insert into config VALUES(1,'vpn.server.static.0.network','$brnet');"

sudo /usr/local/openvpn_as/scripts/sacli -k vpn.daemon.0.client.network -v $brnet ConfigPut
sudo /usr/local/openvpn_as/scripts/sacli -k vpn.daemon.0.client.netmask_bits -v 29 ConfigPut

sudo /usr/local/openvpn_as/scripts/sacli -u cmtsadmin -k access_to.0 -v "+ROUTE:$vnet" UserPropPut
sudo /usr/local/openvpn_as/scripts/sacli -u cmtsadmin -k access_from.0 -v "+ALL_S2C_SUBNETS" UserPropPut



sleep 2

sudo systemctl stop openvpnas
sudo systemctl start openvpnas
