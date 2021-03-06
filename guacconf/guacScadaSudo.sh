#!/bin/bash

# Based on common Guacamole configurations in Envario (guacIptables.sh). 
# Intended for ScadaSudo attemps (VNET changed to 10.0.0.0/8, however openVPN is implemented externally to all other resources in 10.0.0.0/24 (TRUST SUBNET).
# Additionally, a new guacamole credentials are integrated for the Pulse HMI pre-made OVA (RDPhmi)

### CHANGELOG OF 20210530
### Added the possibility to iptables RDP connectivity to internal hosts (!!) [Macabi Client]
### The current script treats LBH2.100 as CALDERA - Forcing a 7012 port for WS through the VPN until a more stable solution is found
### **NOTICE*** Due to time considerations, only *STATIC* iptables rules were assigned. Revise script for a more granular approach (automation! :D).


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
	'RDP')
		sudo cat <<EOF >> /etc/guacamole/user-mapping.xml
        <connection name="$vmName [RDP]">
            <protocol>rdp</protocol>
            <param name="hostname">$vmIP</param>
            <param name="port">3389</param>
            <param name="username">cmtsadmin</param>
            <param name="password">cmtsAdmin12#</param>
            <param name="ignore-cert">true</param>
            <param name="security">any</param>
            <param name="disable-glyph-caching">true</param>	
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

	'RDPhmi')
		sudo cat <<EOF >> /etc/guacamole/user-mapping.xml
        <connection name="$vmName [RDP]">
            <protocol>rdp</protocol>
            <param name="hostname">$vmIP</param>
            <param name="port">3389</param>
            <param name="username">administrator</param>
            <param name="password">1q@W3e4r</param>
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

	'SSHqr')
		sudo cat <<EOF >> /etc/guacamole/user-mapping.xml
        <connection name="$vmName [SSH]">
            <protocol>ssh</protocol>
            <param name="hostname">$vmIP</param>
            <param name="port">22</param>
            <param name="username">root</param>
            <param name="password">cmtsAdmin12#</param>
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

# IPTABLES to NAT direct RDP access to every machine *STATICALLY!* (will require automation in further version, check ChangeLog)

lahLan="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1-2).1"
lbhLan="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1-2).11"
for ((i=10; i<100; i+=1))
{
	# Setting ports 3310 to 3399 for LAH1 to LAH99 (.10 until .99)
	# Setting ports 2210 to 2299 for LAH1 to LAH99 (.10 until .99)
	sudo iptables -t nat -A PREROUTING -p tcp --dport 31$i -j DNAT --to-destination $lahLan.$i:3389
	sudo iptables -t nat -A PREROUTING -p tcp --dport 21$i -j DNAT --to-destination $lahLan.$i:22
}

# Setting ports 20033 for LBH1 (AD) RDP
# Setting ports 10022 for LBH2 (100) SSH
sudo iptables -t nat -A PREROUTING -p tcp --dport 33200 -j DNAT --to-destination $lbhLan.200:3389
sudo iptables -t nat -A PREROUTING -p tcp --dport 33122 -j DNAT --to-destination $lbhLan.100:22
sudo iptables -t nat -A PREROUTING -p tcp --dport 33180 -j DNAT --to-destination $lbhLan.100:80
sudo iptables -t nat -A PREROUTING -p tcp --dport 33188 -j DNAT --to-destination $lbhLan.100:8888

### CALDERA EDITION (Manx "reverse-shell" uses WS and it is expected at port 7012. As a pilot, it is configured to proxy it
sudo iptables -t nat -A PREROUTING -p tcp --dport 7012 -j DNAT --to-destination $lbhLan.100:7012
###

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE


echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
time (while ps -opid= -C apt-get > /dev/null; do sleep 1; done); \
  sudo apt-get -y install iptables-persistent
  
#END OF IPTABLES KOMBINA

sudo systemctl start openvpnas
#reboot now
sudo systemctl restart guacd
sudo systemctl restart nginx 
sudo systemctl restart tomcat 
sleep 5s
sudo systemctl restart guacd
