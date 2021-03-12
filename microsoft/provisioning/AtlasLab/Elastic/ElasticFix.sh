#!/bin/bash

## Comments
# This script must be rewritten with automation for "AD" (as DNS) ip address and pfSense LAN interface ip address
# Additional automation is required for the "AD" (as NTP Sync) 

sudo sed -i 's/\"localhost\"/\"0\"/g' /etc/elasticsearch/elasticsearch.yml
sudo bash -c 'echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml'
sudo service elasticsearch restart

# DNS
sudo bash -c 'echo "nameserver 10.200.11.200" >> /etc/resolv.conf'
# NTP
sudo bash -c 'echo "Servers=10.200.11.200" >> /etc/systemd/timesyncd.conf'

#configure logstash for pfSense (with pfelk https://github.com/pfelk/pfelk/blob/main/install/ubuntu.md)
sudo mkdir -p /etc/pfelk/{conf.d,config,logs,databases,patterns,scripts,templates}
sudo rm /etc/logstash/pipelines.yml
sudo wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/logstash/pipelines.yml -P /etc/logstash/

sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/01-inputs.conf -P /etc/pfelk/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/02-types.conf -P /etc/pfelk/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/03-filter.conf -P /etc/pfelk/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/05-apps.conf -P /etc/pfelk/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/20-interfaces.conf -P /etc/pfelk/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/30-geoip.conf -P /etc/pfelk/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/45-cleanup.conf -P /etc/pfelk/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/50-outputs.conf -P /etc/pfelk/conf.d/

# Extra pfelk (not all configured)
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/35-rules-desc.conf -P /etc/pfelk/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/36-ports-desc.conf -P /etc/pfelk/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/37-enhanced_user_agent.conf -P /etc/pfelk/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/38-enhanced_url.conf -P /etc/pfelk/conf.d/


# Requires automation planning - currently not allowing other pfsense/gw ip's than X.Y.0.254
#vnet="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1)"
#trustnet="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f2)"
#sudo sed -i "s/\/10\\.0\\.0\\.1\//\/$vnet\\.$trustnet\\.0\\.254\//g" /etc/logstash/conf.d/10-syslog.conf

# Simplifying the syslog (not to change pfsense provisoning scripts for this)
sudo sed -i "s/5141/20514/g" /etc/pfelk/conf.d/01-inputs.conf

sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/patterns/pfelk.grok -P /etc/pfelk/patterns/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/patterns/openvpn.grok -P /etc/pfelk/patterns/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/databases/private-hostnames.csv -P /etc/pfelk/databases/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/databases/rule-names.csv -P /etc/pfelk/databases/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/databases/service-names-port-numbers.csv -P /etc/pfelk/databases/

sudo mkdir -p /etc/pfelk/logs
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/error-data.sh -P /etc/pfelk/scripts/
sudo chmod +x /etc/pfelk/scripts/error-data.sh

sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/pfelk-template-installer.sh
https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/pfelk-dashboard-installer.sh
sudo chmod +x pfelk-template-installer.sh
sudo chmod +x pfelk-dashboard-installer.sh
sudo ./pfelk-template-installer.sh
sudo ./pfelk-dashboard-installer.sh

sudo systemctl enable logstash.service
sudo service elasticsearch restart
sudo service kibana restart
sudo systemctl start logstash

