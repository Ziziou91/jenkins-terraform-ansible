#!/bin/bash

cd node-test-app/
pm2 start app.js


# yum update -y

# # Install Python
# yum install -y python3 python3-pip


# # Create user monitoring with no password
# sudo su
# useradd -m -s /bin/bash monitoring
# cd /home/monitoring


# # Download the latest node-exporter tar file from official documentation
# wget https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz
# tar -xzvf node_exporter-1.2.2.linux-amd64.tar.gz
# mv node_exporter-1.2.2.linux-amd64 /home/monitoring/node_exporter
# chown -R monitoring:monitoring /home/monitoring/node_exporter

# # Add file contents into service file
# cat <<EOT >> /etc/systemd/system/node_exporter.service
# [Unit]
# Description=Node Exporter
# Wants=network-online.target
# After=network-online.target
# [Service]
# User=monitoring
# ExecStart=/home/monitoring/node_exporter/node_exporter
# [Install]
# WantedBy=default.target
# EOT

# systemctl daemon-reload
# systemctl start node_exporter
# systemctl enable node_exporter