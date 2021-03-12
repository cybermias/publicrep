#!/bin/bash

## Comments
# This script must be rewritten with automation for "AD" (as DNS) ip address and pfSense LAN interface ip address
# Additional automation is required for the "AD" (as NTP Sync) 

sudo sed -i 's/\"localhost\"/\"0.0.0.0\"/g' /etc/elasticsearch/elasticsearch.yml
sudo bash -c 'echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml'

# DNS
sudo bash -c 'echo "nameserver 10.200.11.200" >> /etc/resolv.conf'
# NTP
sudo bash -c 'echo "Servers=10.200.11.200" >> /etc/systemd/timesyncd.conf'

#configure logstash for pfSense (with pfelk https://github.com/pfelk/pfelk/blob/main/install/ubuntu.md)
sudo mkdir -p /etc/pfelk/{conf.d,config,logs,databases,patterns,scripts,templates}
sudo mkdir /tmp/pfELK
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

# Fix outputs to avoid all the crap around it
sudo cat <<EOF > /etc/pfelk/conf.d/50-outputs.conf
  if "firewall" in [tags] {
    elasticsearch {
      hosts => ["http://localhost:9200"]
      index => "pfelk-firewall-%{+YYYY.MM}"
      manage_template => false
    }
  }
EOF

# Extra pfelk (not all configured)
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/35-rules-desc.conf -P /etc/pfelk/conf.d/
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/36-ports-desc.conf -P /etc/pfelk/conf.d/
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/37-enhanced_user_agent.conf -P /etc/pfelk/conf.d/
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/38-enhanced_url.conf -P /etc/pfelk/conf.d/


# Requires automation planning - currently not allowing other pfsense/gw ip's than X.Y.0.254
#vnet="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1)"
#trustnet="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f2)"
#sudo sed -i "s/\/10\\.0\\.0\\.1\//\/$vnet\\.$trustnet\\.0\\.254\//g" /etc/logstash/conf.d/10-syslog.conf

# Simplifying the syslog (not to change pfsense provisoning scripts for this)
sudo sed -i "s/5140/20514/g" /etc/pfelk/conf.d/01-inputs.conf

sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/patterns/pfelk.grok -P /etc/pfelk/patterns/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/patterns/openvpn.grok -P /etc/pfelk/patterns/
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/databases/private-hostnames.csv -P /etc/pfelk/databases/
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/databases/rule-names.csv -P /etc/pfelk/databases/
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/databases/service-names-port-numbers.csv -P /etc/pfelk/databases/

sudo wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/error-data.sh -P /etc/pfelk/scripts/
sudo chmod +x /etc/pfelk/scripts/error-data.sh

sleep 4

## Amend pfsense interfaces (NOT AUTOMATED!)
#sudo sed -i "s/igb0/hn0/g" /etc/pfelk/conf.d/20-interfaces.conf
#sudo sed -i "s/igb1/hn1/g" /etc/pfelk/conf.d/20-interfaces.conf
#sudo sed -i "s/FiOS/UNTRUST/g" /etc/pfelk/conf.d/20-interfaces.conf
#sudo sed -i "s/Home Network/TRUST/g" /etc/pfelk/conf.d/20-interfaces.conf

## Get everything up and running
sudo systemctl restart elasticsearch 
sudo systemctl restart kibana 
sudo systemctl enable logstash

sleep 5

## Add Dashboards and Templates for pfelk
# Templates
if ! [[ "${os_codename}" =~ (precise|maya|trusty|qiana|rebecca|rafaela|rosa) ]]; then
  SERVICE_ELASTIC=$(systemctl is-active elasticsearch)
  if ! [ "$SERVICE_ELASTIC" = 'active' ]; then
     { echo -e "\\n${RED}#${RESET} Failed to install pfELK Templates"; sleep 3; }
  else
     sudo wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/pfelk-template-installer.sh -P /tmp/pfELK/
     sudo chmod +x /tmp/pfELK/pfelk-template-installer.sh
     sudo bash /tmp/pfELK/pfelk-template-installer.sh > /dev/null 2>&1
     sleep 3
  fi
else
  SERVICE_ELASTIC=$(systemctl is-active elasticsearch)
  if ! [ "$SERVICE_ELASTIC" = 'active' ]; then
    { echo -e "\\n${WHITE_R}#${RESET} Failed to install pfELK Templates"; sleep 3; }
  else
     sudo wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/pfelk-template-installer.sh -P /tmp/pfELK/
     sudo chmod +x /tmp/pfELK/pfelk-template-installer.sh
     sudo bash /tmp/pfELK/pfelk-template-installer.sh > /dev/null 2>&1
     sleep 3
  fi
fi

#Dashboards
if ! [[ "${os_codename}" =~ (precise|maya|trusty|qiana|rebecca|rafaela|rosa) ]]; then
  SERVICE_KIBANA=$(systemctl is-active kibana)
  if ! [ "$SERVICE_KIBANA" = 'active' ]; then
     { echo -e "\\n${RED}#${RESET} Failed to Install pfELK Dashboards\\n\\n"; sleep 3; }
  else
     sudo wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/pfelk-dashboard-installer.sh -P /tmp/pfELK/
     sudo chmod +x /tmp/pfELK/pfelk-dashboard-installer.sh
     sudo bash /tmp/pfELK/pfelk-dashboard-installer.sh > /dev/null 2>&1
     sleep 3
  fi
else
  SERVICE_KIBANA=$(systemctl is-active kibana)
  if ! [ "$SERVICE_KIBANA" = 'active' ]; then
    { echo -e "${RED}#${RESET} Failed to Install pfELK Dashboards\\n\\n"; sleep 3; }
  else
     sudo wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/pfelk-dashboard-installer.sh -P /tmp/pfELK/
     sudo chmod +x /tmp/pfELK/pfelk-dashboard-installer.sh
     sudo bash /tmp/pfELK/pfelk-dashboard-installer.sh
     sleep 3
  fi
fi

sudo systemctl start logstash
