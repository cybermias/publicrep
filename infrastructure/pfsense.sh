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

## Additional manual configuration due to outdated snapshots (adding log and nat)
sudo sed -i "" '/<syslog>/,/<\/syslog>/{//!d;}' /conf/config.xml
sudo sed -i "" '/<nat>/,/<\/nat>/{//!d;}' /conf/config.xml

sudo cat <<EOF > /conf/natdef
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

sudo cat <<EOF > /conf/syslogdef
                <filterdescriptions>1</filterdescriptions>
                <reverse></reverse>
                <nentries>50</nentries>
                <sourceip></sourceip>
                <ipproto>ipv4</ipproto>
                <remoteserver>$i_opt:$p_opt</remoteserver>
                <remoteserver2></remoteserver2>
                <remoteserver3></remoteserver3>
                <logall></logall>
                <enable></enable>
EOF

sudo sed -i "" '/<syslog>/r /conf/syslogdef' /conf/config.xml
sudo sed -i "" '/<nat>/r /conf/natdef' /conf/config.xml

sudo cat <<EOF > /etc/syslog.conf
!radvd,routed,zebra,ospfd,ospf6d,bgpd,miniupnpd,igmpproxy
*.*                                                             %/var/log/routing.log
*.*                                                             @${i_opt}:${p_opt}
!ntp,ntpd,ntpdate
*.*                                                             %/var/log/ntpd.log
*.*                                                             @${i_opt}:${p_opt}
!ppp
*.*                                                             %/var/log/ppp.log
*.*                                                             @${i_opt}:${p_opt}
!poes
*.*                                                             %/var/log/poes.log
*.*                                                             @${i_opt}:${p_opt}
!l2tps
*.*                                                             %/var/log/l2tps.log
*.*                                                             @${i_opt}:${p_opt}
!charon,ipsec_starter
*.*                                                             %/var/log/ipsec.log
*.*                                                             @${i_opt}:${p_opt}
!openvpn
*.*                                                             %/var/log/openvpn.log
*.*                                                             @${i_opt}:${p_opt}
!dpinger
*.*                                                             %/var/log/gateways.log
*.*                                                             @${i_opt}:${p_opt}
!dnsmasq,named,filterdns,unbound
*.*                                                             %/var/log/resolver.log
*.*                                                             @${i_opt}:${p_opt}
!dhcpd,dhcrelay,dhclient,dhcp6c,dhcpleases,dhcpleases6
*.*                                                             %/var/log/dhcpd.log
*.*                                                             @${i_opt}:${p_opt}
!relayd
*.*                                                             %/var/log/relayd.log
*.*                                                             @${i_opt}:${p_opt}
!hostapd
*.*                                                             %/var/log/wireless.log
*.*                                                             @${i_opt}:${p_opt}
!filterlog
*.*                                                             %/var/log/filter.log
*.*                                                             @${i_opt}:${p_opt}
!-ntp,ntpd,ntpdate,charon,ipsec_starter,openvpn,poes,l2tps,relayd,hostapd,dnsmasq,named,filterdns,unbound,dhcpd,dhcrelay,dhclient,dhcp6c,dpinger,radvd,routed,zebra,ospfd,ospf6d,bgpd,miniupnpd,igmpproxy,filterlog
local3.*                                                        %/var/log/vpn.log
local4.*                                                        %/var/log/portalauth.log
local5.*                                                        %/var/log/nginx.log
local7.*                                                        %/var/log/dhcpd.log
*.notice;kern.debug;lpr.info;mail.crit;daemon.none;news.err;local0.none;local3.none;local4.none;local7.none;security.*;auth.info;authpriv.info;daemon.info      %/var/log/system.log
auth.info;authpriv.info                                         |exec /usr/local/sbin/sshguard -i /var/run/sshguard.pid
*.emerg                                                         *
local3.*                                                        @${i_opt}:${p_opt}
local4.*                                                        @${i_opt}:${p_opt}
local7.*                                                        @${i_opt}:${p_opt}
*.emerg;*.notice;kern.debug;lpr.info;mail.crit;news.err;local0.none;local3.none;local7.none;security.*;auth.info;authpriv.info;daemon.info      @${i_opt}:${p_opt}
!*
*.*                                                             @${i_opt}:${p_opt}
EOF

sudo service syslogd restart

sudo awk '/.*allow LAN/{print "                        <log></log>"}1' /conf/config.xml > /conf/config.new
sudo rm /conf/config.xml
sudo mv /conf/config.new /conf/config.xml
sudo rm /tmp/config.cache
