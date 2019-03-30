#!/bin/bash
vnet="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1-2).0.0/16"
PUBLICIP=$(curl -s ipecho.net/plain)
while [ ! $PUBLICIP ]; do
        PUBLICIP=$(curl -s ipecho.net/plain)
done

# After OpenVPN 2.7.3 update config.db required changes were moved to config_local.db
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config_local.db" "update config set value='$vnet' where name='vpn.server.routing.private_network.0';"
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config_local.db" "update config set value='$PUBLICIP' where name='host.name';"
sudo systemctl restart openvpnas
