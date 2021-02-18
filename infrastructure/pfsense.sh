#!/bin/sh

args_no=1
while [ $args_no -le $# ]
do
  case "$1" in
    -i)
      i_opt="$2"
      shift 2
      ;;
    -p)
      p_opt="$2"
      shift 2
      ;;
  esac
done

sudo cp /conf/config.xml /conf/config.bcp

## Additional manual configuration due to outdated snapshots (adding log and nat)
sudo sed -i "" '/<syslog>/,/<\/syslog>/{//!d;}' /conf/config.xml
sudo sed -i "" '/<nat>/,/<\/nat>/{//!d;}' /conf/config.xml

sudo cat <<EOF >> /conf/natdef
                <outbound>
                        <mode>automatic</mode>
                        <rule>
                                <source>
                                        <network>10.0.0.0/8</network>
                                </source>
                                <sourceport></sourceport>
                                <descr><![CDATA[Avoid NAT internally with VLANS]]></descr>
                                <target></target>
                                <targetip></targetip>
                                <targetip_subnet></targetip_subnet>
                                <interface>lan</interface>
                                <poolopts></poolopts>
                                <source_hash_key></source_hash_key>
                                <nonat></nonat>
                                <destination>
                                        <address>10.0.0.0/8</address>
                                </destination>
                                <updated>
                                        <time>1613679463</time>
                                        <username><![CDATA[admin@127.0.0.1 (Local Database)]]></username>
                                </updated>
                                <created>
                                        <time>1613679463</time>
                                        <username><![CDATA[admin@127.0.0.1 (Local Database)]]></username>
                                </created>
                        </rule>
                </outbound>
EOF

sudo cat <<EOF >> /conf/syslogdef
                <filterdescriptions>1</filterdescriptions>
                <reverse></reverse>
                <nentries>50</nentries>
                <sourceip></sourceip>
                <ipproto>ipv4</ipproto>
                <remoteserver>${i_opt}:${p_opt}</remoteserver>
                <remoteserver2></remoteserver2>
                <remoteserver3></remoteserver3>
                <logall></logall>
                <enable></enable>
EOF

sudo sed -i "" '/<syslog>/r /conf/syslogdef' /conf/config.xml
sudo sed -i "" '/<nat>/r /conf/natdef' /conf/config.xml

sudo awk '/.*allow LAN/{print "                        <log></log>"}1' /conf/config.xml > /conf/config.new
sudo rm /conf/config.xml
sudo mv /conf/config.new /conf/config.xml
sudo rm /tmp/config.cache
