#!/bin/bash
#
# Version    | 20.03
# Email      | support@pfelk.com
# Website    | https://pfelk.com
#
###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                   pfELK Easy Installation Script                                                                                #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################
# 
# OS       | List of Supported Distributions/OS
#          | Ubuntu Xenial Xerus ( 16.04 )
#          | Ubuntu Bionic Beaver ( 18.04 )
#          | Ubuntu Cosmic Cuttlefish ( 18.10 )
#          | Ubuntu Disco Dingo  ( 19.04 )
#          | Ubuntu Eoan Ermine  ( 19.10 )
#          | Ubuntu Focal Fossa  ( 20.04 )
#          | Debian Stretch ( 9 )
#          | Debian Buster ( 10 )
#          | Debian Bullseye ( 11 )
#          | Debian Bookworm ( 12 )
#
###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                   Dynamic Dependency Version                                                                                    #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################
#
# MaxMind      | https://github.com/maxmind/geoipupdate/releases
# GeoIP        | 4.6.0 
# Elasticstack | 7.11.0
#
###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                           Color Codes                                                                                           #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

RESET='\033[0m'
GRAY='\033[0;37m'
WHITE='\033[1;37m'
GRAY_R='\033[39m'
WHITE_R='\033[39m'
RED='\033[1;31m' # Light Red.
GREEN='\033[1;32m' # Light Green.

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                           Start Checks                                                                                          #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

header() {
  clear
  clear
  echo -e "${GREEN}#####################################################################################################${RESET}\\n"
}

header_red() {
  clear
  clear
  echo -e "${RED}#####################################################################################################${RESET}\\n"
}

# Check for root (sudo)
if [[ "$EUID" -ne 0 ]]; then
  header_red
  echo -e "${WHITE_R}#${RESET} The script need to be run as root...\\n\\n"
  echo -e "${WHITE_R}#${RESET} For Ubuntu based systems run the command below to login as root"
  echo -e "${GREEN}#${RESET} sudo -i\\n"
  echo -e "${WHITE_R}#${RESET} For Debian based systems run the command below to login as root"
  echo -e "${GREEN}#${RESET} su\\n\\n"
  exit 1
fi

if ! env | grep "LC_ALL\\|LANG" | grep -iq "en_US\\|C.UTF-8"; then
  header
  echo -e "${WHITE_R}#${RESET} Your language is not set to English ( en_US ), the script will temporarily set the language to English."
  echo -e "${WHITE_R}#${RESET} Information: This is done to prevent issues in the script..."
  export LC_ALL=C &> /dev/null
  set_lc_all=true
  sleep 3
fi

abort() {
  if [[ "${set_lc_all}" == 'true' ]]; then unset LC_ALL; fi
  echo -e "\\n\\n${RED}#########################################################################${RESET}\\n"
  echo -e "${WHITE_R}#${RESET} An error occurred. Aborting script..."
  echo -e "${WHITE_R}#${RESET} Please open an issue (pfelk.3ilson.dev) on github!\\n"
  echo -e "${WHITE_R}#${RESET} Creating support file..."
  mkdir -p "/tmp/pfELK/support" &> /dev/null
  if dpkg -l lsb-release 2> /dev/null | grep -iq "^ii\\|^hi"; then lsb_release -a &> "/tmp/pfELK/support/lsb-release"; fi
  df -h &> "/tmp/pfELK/support/df"
  free -hm &> "/tmp/pfELK/support/memory"
  uname -a &> "/tmp/pfELK/support/uname"
  dpkg -l &> "/tmp/pfELK/support/dpkg-list"
  echo "${architecture}" &> "/tmp/pfELK/support/architecture"
  sed -n '3p' "$0" &>> "/tmp/pfELK/support/script"
  grep "# Version" "$0" | head -n1 &>> "/tmp/pfELK/support/script"
  if dpkg -l tar 2> /dev/null | grep -iq "^ii\\|^hi"; then
  tar -cvf /tmp/pfELK_support.tar.gz "/tmp/pfELK" "${pfELK_dir}" &> /dev/null && support_file="/tmp/pfELK_support.tar.gz"
  elif dpkg -l zip 2> /dev/null | grep -iq "^ii\\|^hi"; then
  zip -r /tmp/pfELK_support.zip "/tmp/pfELK/*" "${pfELK_dir}/*" &> /dev/null && support_file="/tmp/pfELK_support.zip"
  fi
  if [[ -n "${support_file}" ]]; then echo -e "${WHITE_R}#${RESET} Support file has been created here: ${support_file} \\n"; fi
  if [[ -f /tmp/pfELK/services/stopped_list && -s /tmp/pfELK/services/stopped_list ]]; then
  while read -r service; do
    echo -e "\\n${WHITE_R}#${RESET} Starting ${service}..."
    systemctl start "${service}" && echo -e "${GREEN}#${RESET} Successfully started ${service}!" || echo -e "${RED}#${RESET} Failed to start ${service}!"
  done < /tmp/pfELK/services/stopped_list
  fi
  exit 1
}

if uname -a | tr '[:upper:]' '[:lower:]'; then
  pfELK_dir='/tmp/pfELK'
fi

script_logo() {
  cat << "EOF"

    ________________.____     ____  __. .___                 __         .__  .__                
_______/ ____\_   _____/|    |   |    |/ _| |   | ____   _______/  |______  |  | |  |   ___________ 
\____ \   __\ |    __)_ |    |   |      <   |   |/    \ /  ___/\   __\__  \ |  | |  | _/ __ \_  __ \
|  |_> >  |   |        \|    |___|    |  \  |   |   |  \\___ \  |  |  / __ \|  |_|  |_\  ___/|  | \/
|   __/|__|  /_______  /|_______ \____|__ \ |___|___|  /____  > |__| (____  /____/____/\___  >__|   
|__|                 \/         \/       \/          \/     \/            \/               \/   
  pfELK Installation Script - version 20.3
EOF
}

start_script() {
  mkdir -p /tmp/pfELK/logs 2> /dev/null
  mkdir -p /tmp/pfELK/upgrade/ 2> /dev/null
  mkdir -p /tmp/pfELK/dpkg/ 2> /dev/null
  mkdir -p /tmp/pfELK/geoip/ 2> /dev/null  
  header
  script_logo
  echo -e "\\n${WHITE_R}#${RESET} Starting the pfELK Install Script..."
  echo -e "${WHITE_R}#${RESET} Thank you for using pfELK Install Script :-)\\n\\n"
  sleep 4
}
start_script

help_script() {
  if [[ "${script_option_help}" == 'true' ]]; then header; script_logo; else echo -e "${WHITE_R}----${RESET}\\n"; fi
  echo -e "    Easy pfELK Install Script Options\\n"
  echo -e "
  Script usage:
  bash $0 [options]
  
  Script options:
  --clean                  Purges pfELK (Elasticstack+pfELK)
  --help 			       Displays this information :) 
  --noelastic			   Do not install Elasticsearch
  --nogeoip                Do not install MaxMind GeoIP 
  --noip				   Do not configure firewall IP Address. 
               Must Configure Manually via:
               /etc/pfelk/conf.d/01-inputs.conf
  --nosense                Do not configure pfSense/OPNsense.  
               Must Configure Manually via:
               /etc/pfelk/conf.d/01-inputs.conf\\n\\n"
  exit 0
}
  
rm --force /tmp/pfELK/script_options &> /dev/null
script_option_list=(--clean --help --nogeoip --noip --nosense)

while [ -n "$1" ]; do
  case "$1" in
  --clean)
     script_options_clean=true
     # Note: Will configure to purge Elasticsearch, logstash, kibana and delete (rm -rf /data/pfELK)
     ;;
  --help)
     script_option_help=true
     help_script;;
  --noelasticsearch)
     script_option_elasticsearch=true
     echo "--noelasticsearch" &>> /tmp/pfELK/script_options;;
  --nogeoip)
     script_option_geoip=true
     echo "--nogeoip" &>> /tmp/pfELK/script_options;;
  --noip)
     echo "--noip" &>> /tmp/pfELK/script_options;;
  --nosense)
     script_option_nosense=true
     echo "--nosense" &>> /tmp/pfELK/script_options;;
  esac
  shift
done

# shellcheck disable=SC2016
grep -io '${pfELK_dir}/logs/.*log' "$0" | grep -v 'awk' | awk '!a[$0]++' &> /tmp/pfELK/log_files
while read -r log_file; do
  if [[ -f "${log_file}" ]]; then
  log_file_size=$(stat -c%s "${log_file}")
  if [[ "${log_file_size}" -gt "10000000" ]]; then
    tail -n1000 "${log_file}" &> "${log_file}.tmp"
    cp "${log_file}.tmp" "${log_file}"; rm --force "${log_file}.tmp" &> /dev/null
  fi
  fi
done < /tmp/pfELK/log_files
rm --force /tmp/pfELK/log_files


http_proxy_found() {
  header
  echo -e "${GREEN}#${RESET} HTTP Proxy found. | ${WHITE_R}${http_proxy}${RESET}\\n\\n"
}

remove_yourself() {
  if [[ "${set_lc_all}" == 'true' ]]; then unset LC_ALL &> /dev/null; fi
  if [[ "${delete_script}" == 'true' || "${script_option_skip}" == 'true' ]]; then
  if [[ -e "$0" ]]; then
    rm --force "$0" 2> /dev/null
  fi
  fi
}

# Get distro
get_distro() {
  if [[ -z "$(command -v lsb_release)" ]]; then
  if [[ -f "/etc/os-release" ]]; then
    if grep -iq VERSION_CODENAME /etc/os-release; then
    os_codename=$(grep VERSION_CODENAME /etc/os-release | sed 's/VERSION_CODENAME//g' | tr -d '="' | tr '[:upper:]' '[:lower:]')
    elif ! grep -iq VERSION_CODENAME /etc/os-release; then
    os_codename=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="' | awk '{print $4}' | sed 's/\((\|)\)//g' | sed 's/\/sid//g' | tr '[:upper:]' '[:lower:]')
    if [[ -z "${os_codename}" ]]; then
      os_codename=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="' | awk '{print $3}' | sed 's/\((\|)\)//g' | sed 's/\/sid//g' | tr '[:upper:]' '[:lower:]')
    fi
    fi
  fi
  else
  os_codename=$(lsb_release -cs | tr '[:upper:]' '[:lower:]')
  if [[ "${os_codename}" == 'n/a' ]]; then
    os_codename=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
    if [[ "${os_codename}" == 'parrot' ]]; then
    os_codename='buster'
    fi
  fi
  if [[ "${os_codename}" =~ (hera|juno) ]]; then os_codename=bionic; fi
  if [[ "${os_codename}" == 'loki' ]]; then os_codename=xenial; fi
  if [[ "${os_codename}" == 'debbie' ]]; then os_codename=buster; fi
  fi
  if [[ "${os_codename}" =~ (precise|maya) ]]; then
  repo_codename=precise
  elif [[ "${os_codename}" =~ (trusty|qiana|rebecca|rafaela|rosa) ]]; then
  repo_codename=trusty
  elif [[ "${os_codename}" =~ (xenial|sarah|serena|sonya|sylvia) ]]; then
  repo_codename=xenial
  elif [[ "${os_codename}" =~ (bionic|tara|tessa|tina|tricia) ]]; then
  repo_codename=bionic
  elif [[ "${os_codename}" =~ (stretch|continuum) ]]; then
  repo_codename=stretch
  elif [[ "${os_codename}" =~ (buster|debbie) ]]; then
  repo_codename=buster
  else
  repo_codename="${os_codename}"
  fi
}
get_distro

if ! [[ "${os_codename}" =~ (xenial|bionic|cosmic|disco|eoan|focal|stretch|buster|bullseye|bookworm)  ]]; then
  clear
  header_red
  echo -e "${WHITE_R}#${RESET} This script is not made for your OS."
  echo -e "${WHITE_R}#${RESET} Feel free to contact pfELK (pfelk.3ilson.dev) on github, if you need help with installing pfELK or alternate installation options."
  echo -e ""
  echo -e "OS_CODENAME = ${os_codename}"
  echo -e ""
  echo -e ""
  exit 1
fi

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                            Variables                                                                                            #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

# dpkg -l | grep "elasticsearch\\|logstash\\|kibana" | awk '{print $3}' | sed 's/.*://' | sed 's/-.*//g' &> /tmp/pfELK/elk_version
# elk_version_installed=$(sort -V /tmp/pfELK/elk_version | tail -n 1)
# rm --force /tmp/pfELK/elk_version &> /dev/null
# first_digits_elk_version_installed=$(echo "${elk_version_installed}" | cut -d'.' -f1)
# second_digits_elk_version_installed=$(echo "${elk_version_installed}" | cut -d'.' -f2)
# third_digits_elk_version_installed=$(echo "${elk_version_installed}" | cut -d'.' -f3)
#
system_memory=$(awk '/MemTotal/ {printf( "%.0f\n", $2 / 1024 / 1024)}' /proc/meminfo)
system_swap=$(awk '/SwapTotal/ {printf( "%.0f\n", $2 / 1024 / 1024)}' /proc/meminfo)
system_swap_var=0
system_mem_var=4
#
maxmind_username=$(echo "${maxmind_username}")
maxmind_password=$(echo "${maxmind_password}")
maxmind_install='false'
ILM_option='false'
system_free_disk_space=$(df -kh / | awk '{print $4}' | tail -n1)
system_free_disk_space_tmp=$(df -kh /tmp | awk '{print $4}' | tail -n1)
#
#SERVER_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1)
#SERVER_IP=$(/sbin/ifconfig | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}' | head -1 | sed 's/.*://')
SERVER_IP=$(ip addr | grep -A8 -m1 MULTICAST | grep -m1 inet | cut -d' ' -f6 | cut -d'/' -f1)
if [[ -z "${SERVER_IP}" ]]; then SERVER_IP=$(hostname -I | head -n 1 | awk '{ print $NF; }'); fi
PUBLIC_SERVER_IP=$(curl ifconfi.me/ -s)
architecture=$(dpkg --print-architecture)
get_distro
#
port_5601_in_use=''
port_5601_pid=''
port_5601_service=''
port_5140_in_use=''
port_5140_pid=''
port_5140_service=''
port_5141_in_use=''
port_5141_pid=''
port_5141_service=''
port_5190_in_use=''
port_5190_pid=''
port_5190_service=''
port_5040_in_use=''
port_5040_pid=''
port_5040_service=''
elk_version=7.11.2
maxmind_version=4.6.0


###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                             Checks                                                                                              #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                  Ask to keep script or delete                                                                                   #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                 Installation Script starts here                                                                                 #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################


###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                               Download and Configure pfELK Files                                                                                #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

download_pfelk() {
  mkdir -p /etc/pfelk/{conf.d,config,logs,databases,patterns,scripts,templates}
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/01-inputs.conf -P /etc/pfelk/conf.d/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/02-types.conf -P /etc/pfelk/conf.d/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/03-filter.conf -P /etc/pfelk/conf.d/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/05-apps.conf -P /etc/pfelk/conf.d/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/20-interfaces.conf -P /etc/pfelk/conf.d/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/30-geoip.conf -P /etc/pfelk/conf.d/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/35-rules-desc.conf -P /etc/pfelk/conf.d/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/36-ports-desc.conf -P /etc/pfelk/conf.d/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/45-cleanup.conf -P /etc/pfelk/conf.d/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/conf.d/50-outputs.conf -P /etc/pfelk/conf.d/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/patterns/pfelk.grok -P /etc/pfelk/patterns/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/patterns/openvpn.grok -P /etc/pfelk/patterns/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/databases/private-hostnames.csv -P /etc/pfelk/databases/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/databases/rule-names.csv -P /etc/pfelk/databases/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/databases/service-names-port-numbers.csv -P /etc/pfelk/databases/
  mkdir -p /etc/pfelk/scripts/
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/error-data.sh -P /etc/pfelk/scripts/
  chmod +x /etc/pfelk/scripts/pfelk-error.sh
  header
  script_logo
  echo -e "\\n${WHITE_R}#${RESET} Setting up pfELK File Structure...\\n"
  sleep 4
}
download_pfelk

# ILM
ILM_option() {
# ILM Configure 
if [[ "${ILM_option}" == 'true' ]]; then
  header
  echo -e "\\n${GREEN}#${RESET} Modifying 50-outputs.conf for ILM!${RESET}\\n";
  sed -i 's/#ILM#//' /etc/pfelk/conf.d/50-outputs.conf
  sleep 3
fi
}
ILM_option

# MaxMind
maxmind_geoip() {
# MaxMind check to ensure GeoIP database files were downloaded - Success
if [[ "${maxmind_install}" == 'true' ]] && [[ -f /var/lib/GeoIP/GeoLite2-City.mmdb ]] && [[ -f /var/lib/GeoIP/GeoLite2-ASN.mmdb ]]; then
  echo "\\n${GREEN}#${RESET} MaxMind Files Present"
  sleep 3
fi
# MaxMind check to ensure GeoIP database files are downloaded - Error Display
if [[ "${maxmind_install}" == 'true' ]] && ! [[ -f /var/lib/GeoIP/GeoLite2-City.mmdb ]] && ! [[ -f /var/lib/GeoIP/GeoLite2-ASN.mmdb ]]; then
  echo -e "\\n${RED}#${RESET} Please Check Your MaxMind Configuration!"
  echo -e "${RED}#${RESET} MaxMind Files Where Not Found."
  echo -e "${RED}#${RESET} Defaulting to Elastic GeoIP Database Files."
  maxmind_install=false
  sleep 4
fi
# MaxMind configuration, if utilized 
if [[ "${maxmind_install}" == 'true' ]]; then
  header
  echo -e "\\n${RED}#${RED} Modifying 30-geoip.conf for MaxMind!${RESET}\\n\\n";
  sed -i 's/#MMR#//' /etc/pfelk/conf.d/30-geoip.conf
  sleep 3
fi
}
maxmind_geoip

# Elasticsearch install
if dpkg -l | grep "elasticsearch" | grep -q "^ii\\|^hi"; then
  header
  echo -e "${WHITE_R}#${RESET} Elasticsearch is already installed!${RESET}\\n\\n";
else
  header
  echo -e "${WHITE_R}#${RESET} Installing Elasticsearch...\\n"
  sleep 2
  if [[ "${script_option_elasticsearch}" != 'true' ]]; then
    elasticsearch_temp="$(mktemp --tmpdir=/tmp elasticsearch_"${elk_version}"_XXX.deb)"
    echo -e "${WHITE_R}#${RESET} Downloading Elasticsearch..."
    if wget "${wget_progress[@]}" -qO "$elasticsearch_temp" "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${elk_version}-amd64.deb"; then echo -e "${GREEN}#${RESET} Successfully downloaded Elasticsearch version ${elk_version}! \\n"; else echo -e "${RED}#${RESET} Failed to download Elasticsearch...\\n"; abort; fi;
  else
    echo -e "${GREEN}#${RESET} Elasticsearch has already been downloaded!"
  fi
  echo -e "${WHITE_R}#${RESET} Installing Elasticsearch..."
  echo "elasticsearch elasticsearch/has_backup boolean true" 2> /dev/null | debconf-set-selections
  if DEBIAN_FRONTEND=noninteractive dpkg -i "$elasticsearch_temp" &>> "${pfELK_dir}/logs/elasticsearch_install.log"; then
    echo -e "${GREEN}#${RESET} Successfully installed Elasticsearch! \\n"
  else
    echo -e "${RED}#${RESET} Failed to install Elasticsearch...\\n"
  fi
fi
rm --force "$elasticsearch_temp" 2> /dev/null
service elasticsearch start || abort
sleep 3

# Logstash install
if dpkg -l | grep "logstash" | grep -q "^ii\\|^hi"; then
  header
  echo -e "${WHITE_R}#${RESET} Logstash is already installed!${RESET}\\n\\n";
else
  header
  echo -e "${WHITE_R}#${RESET} Installing Logstash...\\n"
  sleep 2
  if [[ "${script_option_logstash}" != 'true' ]]; then
    logstash_temp="$(mktemp --tmpdir=/tmp logstash_"${elk_version}"_XXX.deb)"
    echo -e "${WHITE_R}#${RESET} Downloading Logstash..."
    if wget "${wget_progress[@]}" -qO "$logstash_temp" "https://artifacts.elastic.co/downloads/logstash/logstash-${elk_version}-amd64.deb"; then echo -e "${GREEN}#${RESET} Successfully downloaded Logstash version ${elk_version}! \\n"; else echo -e "${RED}#${RESET} Failed to download Logstash...\\n"; abort; fi;
  else
    echo -e "${GREEN}#${RESET} Logstash has already been downloaded!"
  fi
  echo -e "${WHITE_R}#${RESET} Installing Logstash..."
  echo "logstash logstash/has_backup boolean true" 2> /dev/null | debconf-set-selections
  if DEBIAN_FRONTEND=noninteractive dpkg -i "$logstash_temp" &>> "${pfELK_dir}/logs/logstash_install.log"; then
    echo -e "${GREEN}#${RESET} Successfully installed Logstash! \\n"
  else
    echo -e "${RED}#${RESET} Failed to install Logstash...\\n"
  fi
fi
rm --force "$logstash_temp" 2> /dev/null
service logstash start || abort
sleep 3

# Download/Install Required Templates
install_templates() {
header
script_logo
if ! [[ "${os_codename}" =~ (precise|maya|trusty|qiana|rebecca|rafaela|rosa) ]]; then
  SERVICE_ELASTIC=$(systemctl is-active elasticsearch)
  if ! [ "$SERVICE_ELASTIC" = 'active' ]; then
     { echo -e "\\n${RED}#${RESET} Failed to install pfELK Templates"; sleep 3; }
  else
     echo -e "\\n${WHITE_R}#${RESET} Installing pfELK Templates!${RESET}";
     wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/pfelk-template-installer.sh -P /tmp/pfELK/
     chmod +x /tmp/pfELK/pfelk-template-installer.sh
     /tmp/pfELK/pfelk-template-installer.sh > /dev/null 2>&1
     echo -e "${GREEN}#${RESET} Done."
     sleep 3
  fi
else
  SERVICE_ELASTIC=$(systemctl is-active elasticsearch)
  if ! [ "$SERVICE_ELASTIC" = 'active' ]; then
    { echo -e "\\n${WHITE_R}#${RESET} Failed to install pfELK Templates"; sleep 3; }
  else
     echo -e "\\n${WHITE_R}#${RESET} Installing pfELK Templates!${RESET}";
     wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/pfelk-template-installer.sh -P /tmp/pfELK/
     chmod +x /tmp/pfELK/pfelk-template-installer.sh
     /tmp/pfELK/pfelk-template-installer.sh > /dev/null 2>&1
     echo -e "${GREEN}#${RESET} Done."
     sleep 3
  fi
fi
}
install_templates

# Kibana install
if dpkg -l | grep "kibana" | grep -q "^ii\\|^hi"; then
  header
  echo -e "${WHITE_R}#${RESET} Kibana is already installed!${RESET}\\n\\n";
else
  header
  echo -e "${WHITE_R}#${RESET} Installing Kibana...\\n"
  sleep 2
  if [[ "${script_option_kibana}" != 'true' ]]; then
    kibana_temp="$(mktemp --tmpdir=/tmp kibana_"${elk_version}"_XXX.deb)"
    echo -e "${WHITE_R}#${RESET} Downloading Kibana..."
    if wget "${wget_progress[@]}" -qO "$kibana_temp" "https://artifacts.elastic.co/downloads/kibana/kibana-${elk_version}-amd64.deb"; then echo -e "${GREEN}#${RESET} Successfully downloaded Kibana version ${elk_version}! \\n"; else echo -e "${RED}#${RESET} Failed to download Kibana...\\n"; abort; fi;
  else
    echo -e "${GREEN}#${RESET} Kibana has already been downloaded!"
  fi
  echo -e "${WHITE_R}#${RESET} Installing Kibana..."
  echo "kibana kibana/has_backup boolean true" 2> /dev/null | debconf-set-selections
  if DEBIAN_FRONTEND=noninteractive dpkg -i "$kibana_temp" &>> "${pfELK_dir}/logs/kibana_install.log"; then
    echo -e "${GREEN}#${RESET} Successfully installed Kibana! \\n"
  else
    echo -e "${RED}#${RESET} Failed to install Kibana...\\n"
  fi
fi
rm --force "$kibana_temp" 2> /dev/null
service kibana start || abort
sleep 3

# Download logstash.yml & Restart Logstash
update_logstash() {
  header
  script_logo
  rm /etc/logstash/pipelines.yml
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/logstash/pipelines.yml -P /etc/logstash/
  systemctl restart logstash.service
  echo -e "\\n${WHITE_R}#${RESET} Updated Logstash.yml..."
  sleep 3
}
update_logstash

# Download Kibana.yml & Restart Kibana
update_kibana() {
  header
  script_logo
  rm /etc/kibana/kibana.yml
  wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/kibana/kibana.yml -P /etc/kibana/
  systemctl restart kibana.service
  echo -e "\\n${WHITE_R}#${RESET} Updated Kibana.yml..."
  sleep 3
}
update_kibana

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                               Finish                                                                                            #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################


# Download/Install Dashboard (saved objects)
install_kibana_saved_objects() {
header
  script_logo
if ! [[ "${os_codename}" =~ (precise|maya|trusty|qiana|rebecca|rafaela|rosa) ]]; then
  SERVICE_KIBANA=$(systemctl is-active kibana)
  if ! [ "$SERVICE_KIBANA" = 'active' ]; then
     { echo -e "\\n${RED}#${RESET} Failed to Install pfELK Dashboards\\n\\n"; sleep 3; }
  else
     echo -e "\\n${WHITE_R}#${RESET} Installing Kibana Saved Objects (i.e. pfELK Dashboards)!${RESET}";
     wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/pfelk-dashboard-installer.sh -P /tmp/pfELK/
     chmod +x /tmp/pfELK/pfelk-dashboard-installer.sh
     /tmp/pfELK/pfelk-dashboard-installer.sh > /dev/null 2>&1
     echo -e "${GREEN}#${RESET} Done."
     sleep 3
  fi
else
  SERVICE_KIBANA=$(systemctl is-active kibana)
  if ! [ "$SERVICE_KIBANA" = 'active' ]; then
    { echo -e "${RED}#${RESET} Failed to Install pfELK Dashboards\\n\\n"; sleep 3; }
  else
     echo -e "\\n${WHITE_R}#${RESET} Installing Kibana Saved Objects (i.e. pfELK Dashboards)!${RESET}";
     wget -q https://raw.githubusercontent.com/pfelk/pfelk/main/etc/pfelk/scripts/pfelk-dashboard-installer.sh -P /tmp/pfELK/
     chmod +x /tmp/pfELK/pfelk-dashboard-installer.sh
     /tmp/pfELK/pfelk-dashboard-installer.sh
     echo -e "${GREEN}#${RESET} Done."
     sleep 3
  fi
fi
}
install_kibana_saved_objects

if dpkg -l | grep "logstash" | grep -q "^ii\\|^hi"; then
  header
  script_logo
  echo -e "\\n"
  echo -e "${GREEN}#${RESET} pfELK was installed successfully"
  systemctl is-active -q kibana && echo -e "${GREEN}#${RESET} Logstash is active ( running )" || echo -e "${RED}#${RESET} Logstash failed to start... Please open an issue (pfelk.3ilson.dev) on github!"
  echo -e "\\n"
  echo -e "Open your browser and connect to ${GREEN}http://$SERVER_IP:5601${RESET}\\n"
  echo -e "Please check the documentation on github to configure your pfSense/OPNsense --> ${GREEN}https://github.com/pfelk/pfelk/blob/main/install/configuration.md${RESET}\\n"
  echo -e "\\n"
  sleep 3
  remove_yourself
else
  header_red
  script_logo
  echo -e "\\n${RED}#${RESET} Failed to successfully install pfELK"
  echo -e "${RED}#${RESET} Please contact pfELK (${RED}pfELK.3ilson.dev${RESET}) on github!${RESET}\\n\\n"
  remove_yourself
fi
