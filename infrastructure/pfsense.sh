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

sudo awk -v p="$p_opt" -v i="$i_opt" '1;/<syslog>/{ print "                <enable></enable>"; print "                <remoteserver>" i ":" p "</remoteserver>"; print "                <logall></logall>"}' /conf/config.xml > /conf/config.new

## Additional manual configuration due to outdated snapshots (adding log and nat)
sed -i "" '/<nat>/,/<\/nat>/d' /conf/config.new

cat <<EOF >> /conf/nattext
        <nat>
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
        </nat>
EOF

sed '/<\/syslog>/r /conf/nattext' -i "" /conf/config.new

sudo mv /conf/config.xml /conf/config_pre_provisioning.old

sudo awk '/.*allow LAN/{print "                        <log></log>"}1' /conf/config.new > /conf/config.xml

sudo rm /tmp/config.cache


