#!/bin/bash

echo "net.ipv4.ip_forward = 1" > /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
sudo apt-get -y install iptables-persistent

iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 3389 -j DNAT --to 192.168.1.10:3389
iptables -A FORWARD -p tcp -d 192.168.1.10 --dport 3389 -j ACCEPT

iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 21122 -j DNAT --to 192.168.11.10:22
iptables -A FORWARD -p tcp -d 192.168.11.10 --dport 21122 -j ACCEPT

iptables -A POSTROUTING  -t nat -o eth0 -j MASQUERADE 

