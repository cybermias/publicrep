#!/bin/bash

# UPDATED AT 20190826 - Following CSP3 class. Based on guachde (from CTF event) - including bridge.
# At CSP3 Yossi Barishiev needed a domain environment that could allow him to install Symantec. We use ATLASORG.
# This file (guaccsp3) is fixed to support the current usernames of Atlasorg.
# Login to DC will be done with atlasadmin, while logging to workstation is with normal domain users.
#
# Specified to work with CSP-VPN-PF-ATLASORGCTG-SYMANTEC-V0.9.json

# Generic Guacamole configuration file. Requires parameters OR WILL FAIL
# Parameters come in triplets (vmName vmIP vmProt). Allowed protocols are RDP, RDPatlas, SSH, VNC and SSHctf [no user/pass].
vnet="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1-2).0.0/16"
static="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1-2).253.252"
brnet="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1-2).253.0"

args=("$@")

sudo cat <<EOF > /etc/guacamole/guacamole.properties
# Hostname and port of guacamole proxy
guacd-hostname: localhost
guacd-port:     4822
# MySQL properties
#mysql-hostname: localhost
#mysql-port: 3306
#mysql-database: cmtsguac
#mysql-username: cmtsadmin
#mysql-password: cmtsAdmin12#
#mysql-default-max-connections-per-user: 0
#mysql-default-max-group-connections-per-user: 0
auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
basic-user-mapping: /etc/guacamole/user-mapping.xml
EOF

sudo cat <<EOF > /etc/guacamole/user-mapping.xml
<?xml version="1.0" encoding="UTF-8"?>
<user-mapping>
    <authorize username="cmtsadmin" password="cmtsAdmin12#">
EOF

for ((i=0; i<$#; i+=3))
{
	vmName=${args[$i]}
	vmIP=${args[$i+1]}
	vmProt=${args[$i+2]}
	
	#echo "Args are: $vmName $vmIP $vmProt"
	
	sudo echo "Args are: $vmName $vmIP $vmProt" >> /opt/guacargs
	
	case "$vmProt" in
	'RDPadmin')
		sudo cat <<EOF >> /etc/guacamole/user-mapping.xml
        <connection name="$vmName [RDP]">
            <protocol>rdp</protocol>
            <param name="hostname">$vmIP</param>
	    <param name="domain">atlas.lab</param>
            <param name="port">3389</param>
            <param name="username">jeremy</param>
            <param name="password">atlasAdmin!</param>
            <param name="ignore-cert">true</param>
            <param name="security">any</param>
        </connection>
EOF
	;;
	
  	'RDPkant')
		sudo cat <<EOF >> /etc/guacamole/user-mapping.xml
        <connection name="$vmName [RDP]">
            <protocol>rdp</protocol>
            <param name="hostname">$vmIP</param>
            <param name="port">3389</param>
	    <param name="domain">atlas.lab</param>
            <param name="username">ikant</param>
            <param name="password">Aa12345</param>
            <param name="ignore-cert">true</param>
            <param name="security">any</param>
        </connection>
EOF
	;;
  
	'RDPatlas')
		sudo cat <<EOF >> /etc/guacamole/user-mapping.xml
        <connection name="$vmName [RDP]">
            <protocol>rdp</protocol>
            <param name="hostname">$vmIP</param>
            <param name="port">3389</param>
            <param name="username">atlasadmin</param>
            <param name="password">cmtsAdmin12#</param>
            <param name="ignore-cert">true</param>
            <param name="security">any</param>
        </connection>
EOF
	;;

	'SSH')
		sudo cat <<EOF >> /etc/guacamole/user-mapping.xml
        <connection name="$vmName [SSH]">
            <protocol>ssh</protocol>
            <param name="hostname">$vmIP</param>
            <param name="port">22</param>
            <param name="username">cmtsadmin</param>
            <param name="password">cmtsAdmin12#</param>
        </connection>
EOF
	;;

	'SSHctf')
		sudo cat <<EOF >> /etc/guacamole/user-mapping.xml
        <connection name="$vmName [SSH]">
            <protocol>ssh</protocol>
            <param name="hostname">$vmIP</param>
            <param name="port">22</param>
        </connection>
EOF
	;;

	'VNC')
		sudo cat <<EOF >> /etc/guacamole/user-mapping.xml
        <connection name="$vmName [SSH]">
            <protocol>ssh</protocol>
            <param name="hostname">$vmIP</param>
            <param name="port">22</param>
            <param name="username">cmtsadmin</param>
            <param name="password">cmtsAdmin12#</param>
        </connection>
        <connection name="$vmName [VNC]">
            <protocol>vnc</protocol>
            <param name="hostname">$vmIP</param>
            <param name="port">5901</param>
            <param name="password">123456</param>
        </connection>		
EOF
	;;
		 
esac
}

sudo cat <<EOF >> /etc/guacamole/user-mapping.xml
    </authorize>
</user-mapping>
EOF

sudo cat <<EOF > /etc/nginx/conf.d/default.conf
server {
    listen       80;
    server_name  localhost;
    location /mylab/ {
        proxy_pass http://localhost:8080/guacamole/;
    }
}
EOF

rm /etc/nginx/conf.d/guacamole_ssl.conf

#sudo service guacd restart
#sudo service nginx restart
#sudo service tomcat restart
sleep 5s
#sudo service guacd restart

# ADDING OPENVPN CONFIGURATION NOT TO ALTER ORIGINAL FIXVPNIP.SH (2.7.3 needs to be upgraded, its also faulty here)
# Added at 20190709 - Before Itzik mimikatz class at HDE
#sudo /usr/local/openvpn_as/scripts/sacli -k vpn.daemon.0.client.network -v $brnet ConfigPut
#sudo /usr/local/openvpn_as/scripts/sacli -k vpn.daemon.0.client.netmask_bits -v 29 ConfigPut

#sudo /usr/local/openvpn_as/scripts/sacli -u cmtsadmin -k access_to.0 -v "+ROUTE:$vnet" UserPropPut
#sudo /usr/local/openvpn_as/scripts/sacli -u cmtsadmin -k access_from.0 -v "+ALL_S2C_SUBNETS" UserPropPut

# SACLI FAILS (both init.d and both azure custom script). Not sure why

sudo systemctl stop openvpnas

sleep 2

PUBLICIP=$(curl -s ipecho.net/plain)
while [ ! $PUBLICIP ]; do
        PUBLICIP=$(curl -s ipecho.net/plain)
done

# After OpenVPN 2.7.3 update config.db required changes were moved to config_local.db
# Note about IP DHCP assignment. For some reason, giving a pool is always "cut" by half by the openvpn service. 
# Assign /28 and the server will provide an IP from /29 (while the first host is always an openvpn server ip).
# The solution is to assign /28 (.0 to .14). The service will provide dhcp from /29 of .9 to .14.
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config_local.db" "update config set value='$vnet' where name='vpn.server.routing.private_network.0';"
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config_local.db" "update config set value='$PUBLICIP' where name='host.name';"

sudo sqlite3 "/usr/local/openvpn_as/etc/db/config_local.db" "update config set value='28' where name='vpn.daemon.0.client.netmask_bits';"
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config_local.db" "update config set value='$brnet' where name='vpn.daemon.0.client.network';"
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config_local.db" "update config set value='route' where name='vpn.server.routing.private_access';"

sudo sqlite3 "/usr/local/openvpn_as/etc/db/userprop.db" "insert into config VALUES(3,'access_from.0','+ALL_S2C_SUBNETS');"
sudo sqlite3 "/usr/local/openvpn_as/etc/db/userprop.db" "insert into config VALUES(3,'access_to.0','+ROUTE:$vnet');"


sudo systemctl start openvpnas
#reboot now
sudo service guacd restart
sudo service nginx restart
sudo service tomcat restart
sleep 5s
sudo service guacd restart
