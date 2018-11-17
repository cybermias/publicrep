#!/bin/bash

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
        <connection name="WIN-DESKTOP">
            <protocol>rdp</protocol>
            <param name="hostname">10.200.11.10</param>
            <param name="port">3389</param>
            <param name="username">cmtsadmin</param>
            <param name="password">cmtsAdmin12#</param>
            <param name="ignore-cert">true</param>
            <param name="security">any</param>
        </connection>

        <!-- Second authorized connection -->
        <connection name="WIN-DOMAIN">
            <protocol>rdp</protocol>
            <param name="hostname">10.200.11.200</param>
            <param name="port">3389</param>
            <param name="username">atlasAdmin</param>
            <param name="password">cmtsAdmin12#$</param>
            <param name="ignore-cert">true</param>
            <param name="security">any</param>
        </connection>

        <!-- Third authorized connection -->
        <connection name="KALI">
            <protocol>ssh</protocol>
            <param name="hostname">10.200.1.10</param>
            <param name="port">22</param>
            <param name="username">cmtsadmin</param>
            <param name="password">cmtsAdmin12#</param>
        </connection>

    </authorize>

</user-mapping>
EOF

service guacd restart
service nginx restart
service tomcat restart
sleep 5s
service guacd restart


