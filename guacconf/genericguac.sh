#!/bin/bash

# Generic Guacamole configuration file. Requires parameters OR WILL FAIL
# Parameters come in triplets (vmName vmIP vmProt). Allowed protocols are RDP, RDPatlas, SSH, VNC and SSHctf [no user/pass].

args=("$@")

cat <<EOF > /etc/guacamole/guacamole.properties
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

cat <<EOF > /etc/guacamole/user-mapping.xml
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
	
	case "$vmProt" in
	'RDP')
		cat <<EOF >> /etc/guacamole/user-mapping.xml
        <connection name="$vmName">
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
		cat <<EOF >> /etc/guacamole/user-mapping.xml
        <connection name="$vmName">
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
		cat <<EOF >> /etc/guacamole/user-mapping.xml
        <connection name="$vmName (SSH)">
            <protocol>ssh</protocol>
            <param name="hostname">$vmIP</param>
            <param name="port">22</param>
            <param name="username">cmtsadmin</param>
            <param name="password">cmtsAdmin12#</param>
        </connection>
EOF
	;;

	'SSHctf')
		cat <<EOF >> /etc/guacamole/user-mapping.xml
        <connection name="$vmName (SSH)">
            <protocol>ssh</protocol>
            <param name="hostname">$vmIP</param>
            <param name="port">22</param>
        </connection>
EOF
	;;

	'VNC')
		cat <<EOF >> /etc/guacamole/user-mapping.xml
        <connection name="$vmName (SSH)">
            <protocol>ssh</protocol>
            <param name="hostname">$vmIP</param>
            <param name="port">22</param>
            <param name="username">cmtsadmin</param>
            <param name="password">cmtsAdmin12#</param>
        </connection>
        <connection name="$vmName (VNC)">
            <protocol>vnc</protocol>
            <param name="hostname">$vmIP</param>
            <param name="port">5901</param>
            <param name="password">123456</param>
        </connection>		
EOF
	;;
		 
esac
}

cat <<EOF >> /etc/guacamole/user-mapping.xml
    </authorize>
</user-mapping>
EOF


service guacd restart
service nginx restart
service tomcat restart
sleep 5s
service guacd restart
