#!/bin/bash

# INITIALIZE JUMPER FOR CSP'ERS

# PERSISTENT IP FORWARDING for eth0
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

# AUTOMATIC SILENT INSTALL FOR iptables-persistent (NORMAL INSTALL REQUIRES USER INTERVENTION)_
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
sudo apt-get -y install iptables-persistent

## ADDING HARD-CODED PREDEFINED/FIXED IP ASSIGNMENTS
##
# FIXING MAIN/NORMAL RDP TO LAH1
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 3389 -j DNAT --to 10.0.1.10:3389
iptables -A FORWARD -p tcp -d 10.0.1.10 --dport 3389 -j ACCEPT

# FIXING MAIN/NORMAL X2GO-SSH TO LAH1
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 22011 -j DNAT --to 10.0.1.10:22
iptables -A FORWARD -p tcp -d 10.0.1.10 --dport 22011 -j ACCEPT

# FIXING MAIN/NORMAL RDP TO LBH1
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 4389 -j DNAT --to 10.0.11.10:3389
iptables -A FORWARD -p tcp -d 10.0.11.10 --dport 4389 -j ACCEPT

# FIXING MAIN/NORMAL X2GO-SSH TO LBH1
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 22111 -j DNAT --to 10.0.11.10:22
iptables -A FORWARD -p tcp -d 10.0.11.10 --dport 22111 -j ACCEPT

# FIXING MAIN/NORMAL RDP TO LBH2
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 4390 -j DNAT --to 10.0.11.20:3389
iptables -A FORWARD -p tcp -d 10.0.11.20 --dport 4390 -j ACCEPT

# FIXING MAIN/NORMAL X2GO-SSH TO LBH2
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 22112 -j DNAT --to 10.0.11.20:22
iptables -A FORWARD -p tcp -d 10.0.11.20 --dport 22112 -j ACCEPT

# MASQUERADE RULE
iptables -A POSTROUTING  -t nat -o eth0 -j MASQUERADE 
