#!/bin/bash

## Comments
# This script must be rewritten with automation for "AD" (as DNS) ip address and pfSense LAN interface ip address
# Additional automation is required for the "AD" (as NTP Sync) .
#
# UDP SYSLOG (from pfsense) is fixated at 20514 [sed'ing @PORT@ from 01-inputs.conf. Requires Input from template file
#

## Changing some elastic configurations
# Fixing yml for "localhost" and adding a non-cluster parameter required to work properly
sudo sed -i 's/\"localhost\"/\"0.0.0.0\"/g' /etc/elasticsearch/elasticsearch.yml
sudo bash -c 'echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml'
sudo systemctl restart elasticsearch 

# DNS nameserver addition (for the AD, requires automation through parameter)
sudo bash -c 'echo "nameserver 10.200.11.200" >> /etc/resolv.conf'
# NTP addition (for the AD, requires automation through parameter)
sudo bash -c 'echo "Servers=10.200.11.200" >> /etc/systemd/timesyncd.conf'

## PFELK configruations. Not the original instructions as they include from malconfigured declarations
## 1) pfelk_installer.sh requires human intervention, initial attempts at bypassing this requires too much efforts with minimal success
## 2) Reverting to making changes according to manual installation instructions.
## 3) Some configurations required extra efforts to avoid unknown conflicts post deployments (index / pattern may not appear)

#configure logstash for pfSense (with pfelk https://github.com/pfelk/pfelk/blob/main/install/ubuntu.md)
sudo mkdir -p /etc/logstash/{config,logs,databases,patterns,scripts,templates}
sudo mkdir /tmp/pfELK
#sudo rm /etc/logstash/pipelines.yml
#sudo wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/logstash/pipelines.yml -P /etc/logstash/

sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/01-inputs.conf -P /etc/logstash/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/02-types.conf -P /etc/logstash/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/03-filter.conf -P /etc/logstash/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/05-apps.conf -P /etc/logstash/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/20-interfaces.conf -P /etc/logstash/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/30-geoip.conf -P /etc/logstash/conf.d/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/50-outputs.conf -P /etc/logstash/conf.d/

# Fix outputs to avoid all the crap around it
sudo cat <<EOF > /etc/logstash/conf.d/50-outputs.conf
output {
  if "firewall" in [tags] {
    elasticsearch {
      hosts => ["http://localhost:9200"]
      index => "pfelk-firewall-%{+YYYY.MM}"
      manage_template => false
    }
  }
}
EOF

# Making some adaptations to the inputs file (clearing most of the non-currently-used techs: Suricata, haproxy, etc.
sudo cat <<EOF > /etc/logstash/conf.d/01-inputs.conf
input {
  udp {
    id => "pfelk-1" 
    type => "firewall-1"
    port => @PORT@
  }
}
EOF

# Adjusting 02-types.conf to fit only necessary types (firewall-2 for pfelk)
sudo cat <<EOF > /etc/logstash/conf.d/02-types.conf
filter {
  if [type] == "firewall-1" {
    mutate {
      add_field => [ "[observer][type]", "firewall" ]
      ### Adjust the name, product and serial_number as desired ###
      add_field => [ "[observer][name]", "pfSense" ]
      add_field => [ "[observer][product]", "pfSense" ]
      add_field => [ "[observer][serial_number]", "001" ]
      rename => { "host" => "[observer][ip]" } 
    }
  }
}
EOF

# Removed pfelk confs that were either not used (or had no value in the initial pfelk installation - some of them apperantly not used too)
# cleanup was also removed for debugging purposes
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/35-rules-desc.conf -P /etc/pfelk/conf.d/
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/36-ports-desc.conf -P /etc/pfelk/conf.d/
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/37-enhanced_user_agent.conf -P /etc/pfelk/conf.d/
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/38-enhanced_url.conf -P /etc/pfelk/conf.d/
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/45-cleanup.conf -P /etc/pfelk/conf.d/
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/databases/private-hostnames.csv -P /etc/pfelk/databases/
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/databases/rule-names.csv -P /etc/pfelk/databases/
#sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/databases/service-names-port-numbers.csv -P /etc/pfelk/databases/

# Replacing the syslog port (as configured in pfsense) <== Requires parameter automation
sudo sed -i "s/@PORT@/20514/g" /etc/logstash/conf.d/01-inputs.conf

# Additional error-collecting script from current pfelk
sudo wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/error-data.sh -P /etc/logstash/scripts/
sudo chmod +x /etc/logstash/scripts/error-data.sh
sleep 4

# Adding the grok pattern offered by current pfelk
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/patterns/pfelk.grok -P /etc/logstash/patterns/
sudo wget https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/patterns/openvpn.grok -P /etc/logstash/patterns/


## Leftovers from other pfelk version - requiring the pfsense IP. Not used for currently implementation.
# Requires automation planning - currently not allowing other pfsense/gw ip's than X.Y.0.254
#vnet="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1)"
#trustnet="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f2)"
#sudo sed -i "s/\/10\\.0\\.0\\.1\//\/$vnet\\.$trustnet\\.0\\.254\//g" /etc/logstash/conf.d/10-syslog.conf

# Amend pfsense interfaces (NOT AUTOMATED!) - currently not used until further investigations
#sudo sed -i "s/igb0/hn0/g" /etc/pfelk/conf.d/20-interfaces.conf
#sudo sed -i "s/igb1/hn1/g" /etc/pfelk/conf.d/20-interfaces.conf
#sudo sed -i "s/FiOS/UNTRUST/g" /etc/pfelk/conf.d/20-interfaces.conf
#sudo sed -i "s/Home Network/TRUST/g" /etc/pfelk/conf.d/20-interfaces.conf

## Get everything up and running
sleep 5

## Add Dashboards and Templates for pfelk
# Templates
if ! [[ "${os_codename}" =~ (precise|maya|trusty|qiana|rebecca|rafaela|rosa) ]]; then
  SERVICE_ELASTIC=$(systemctl is-active elasticsearch)
  if ! [ "$SERVICE_ELASTIC" = 'active' ]; then
     { echo -e "\\n${RED}#${RESET} Failed to install pfELK Templates"; sleep 3; }
  else
     sudo wget -q https://raw.githubusercontent.com/cybermias/publicrep/master/microsoft/provisioning/AtlasLab/Elastic/pfelk_templates.sh -P /tmp/pfELK/
     sudo chmod +x /tmp/pfELK/pfelk_templates.sh
     sudo bash /tmp/pfELK/pfelk_templates.sh > /dev/null 2>&1
     sleep 3
  fi
else
  SERVICE_ELASTIC=$(systemctl is-active elasticsearch)
  if ! [ "$SERVICE_ELASTIC" = 'active' ]; then
    { echo -e "\\n${WHITE_R}#${RESET} Failed to install pfELK Templates"; sleep 3; }
  else
     sudo wget -q https://raw.githubusercontent.com/cybermias/publicrep/master/microsoft/provisioning/AtlasLab/Elastic/pfelk_templates.sh -P /tmp/pfELK/
     sudo chmod +x /tmp/pfELK/pfelk_templates.sh
     sudo bash /tmp/pfELK/pfelk_templates.sh > /dev/null 2>&1
     sleep 3
  fi
fi

sudo systemctl enable logstash
sudo systemctl start logstash
