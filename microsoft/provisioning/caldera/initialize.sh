#!/bin/bash

# Script will update caldera by git, and enforce it to run locally inside ATLAS lab (i.e 10.200.11.100).

apt-get update
pip3 install --upgrade setuptools
cd /opt/caldera

git checkout tags/3.1.0
git submodule update --recursive
pip3 install -r requirements.txt
pip3 install aiohttp_apispec

# Adapt the local.yml file at conf directory to initialize caldera as the current local IP
ip=$(ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
sed -i -e "s/0.0.0.0/$ip/g" /opt/caldera/conf/local.yml

sudo apt-get install -y software-properties-common
sudo apt-get purge golang-go
sudo rm -rvf /usr/local/go/
sudo add-apt-repository ppa:longsleep/golang-backports
sudo apt update
sudo apt install -y golang-go

service caldera restart
