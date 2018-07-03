#!/bin/bash

sudo apt-get -y install git
git clone https://github.com/eystsen/pentestlab /opt/pentestlab
cd pentestlab/
 
if fuser /var/lib/dpkg/lock > /dev/null 2>&1
then
        echo "Software management (APT) is already running. Cannot install docker right now."
        echo "Just wait a minute or two and try again"
        exit
fi
 
 
sudo apt-get update
 
# apt-get dependencies
sudo apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common
 
# Add gpg key for docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
 
echo Adding to sources.list
echo "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" | sudo tee --append /etc/apt/sources.list > /dev/null
 
 
sudo apt-get -y update
sudo apt-get -y install docker-ce
 
# Start Docker on boot
sudo systemctl enable docker
cd /opt/pentestlab

sudo ./pentestlab.sh start bwapp && sudo ./pentestlab.sh start webgoat8 && sudo ./pentestlab.sh start dvwa
