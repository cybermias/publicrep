#!/bin/bash

sudo sed -i 's/\"localhost\"/\"0\"/g' /etc/elasticsearch/elasticsearch.yml
sudo bash -c 'echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml'
sudo service elasticsearch restart

sudo bash -c 'echo "nameserver 10.200.11.200" >> /etc/resolv.conf'
