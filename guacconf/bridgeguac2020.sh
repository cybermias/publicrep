#!/bin/bash

# Generic Guacamole configuration file. Requires parameters OR WILL FAIL
# Parameters come in triplets (vmName vmIP vmProt). Allowed protocols are RDP, RDPatlas, SSH, VNC and SSHctf [no user/pass].

### CHANGELOG OF 2020115
### Something screwed Win7 and Guacamole 1.2 and beyond. Issues with DWM only on Win7 cause RDP to disconnect when various graphics appear (even in CMD or PUTTY)
### This version of Guac will add "disable-glyph-caching" to the RDP connection. Tests show that performance is unhindered for both WIN2016 and WIN7

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
            <param name="disable-glyph-caching">true</param>
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


sudo service guacd restart
sudo service nginx restart
sudo service tomcat restart
sleep 5s
sudo service guacd restart
