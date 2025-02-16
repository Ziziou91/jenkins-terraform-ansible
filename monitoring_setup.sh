#!/bin/bash

# Update packages
sudo -i
sudo apt-get update

#Install Grafana
mkdir Grafana && cd Grafana
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main" -y
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install grafana -y

# Start Grafana and ensure it runs when instance starts up
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

#Install Prometheus
sudo apt-get install prometheus -y

sudo systemctl start prometheus
sudo systemctl enable prometheus


