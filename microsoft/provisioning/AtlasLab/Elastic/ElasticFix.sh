#!/bin/bash

sudo sed -i 's/\"localhost\"/\"0\"/g' /etc/elasticsearch/elasticsearch.yml
sudo bash -c 'echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml'
sudo service elasticsearch restart
