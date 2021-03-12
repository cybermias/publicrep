#!/bin/bash

## Comments
# This script must be rewritten with automation for "AD" (as DNS) ip address and pfSense LAN interface ip address
# Additional automation is required for the "AD" (as NTP Sync) 

sudo wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/pfelk-installer.sh -P /tmp/
sudo chmod +x /tmp/pfelk-installer.sh
sudo bash /tmp/pfelk-installer.sh

sudo sed -i 's/\"localhost\"/\"0\"/g' /etc/elasticsearch/elasticsearch.yml
sudo bash -c 'echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml'

# DNS
sudo bash -c 'echo "nameserver 10.200.11.200" >> /etc/resolv.conf'
# NTP
sudo bash -c 'echo "Servers=10.200.11.200" >> /etc/systemd/timesyncd.conf'

# Fixing some pfelk stuff
sudo sed -i "s/5140/20514/g" /etc/pfelk/conf.d/01-inputs.conf

sudo sed -i "s/igb0/hn0/g" /etc/pfelk/conf.d/20-interfaces.conf
sudo sed -i "s/igb1/hn1/g" /etc/pfelk/conf.d/20-interfaces.conf
sudo sed -i "s/FiOS/UNTRUST/g" /etc/pfelk/conf.d/20-interfaces.conf
sudo sed -i "s/Home Network/TRUST/g" /etc/pfelk/conf.d/20-interfaces.conf

sudo systemctl restart logstash
