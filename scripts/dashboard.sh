#!/bin/bash

### Install Grafana server

sudo wget https://dl.grafana.com/oss/release/grafana-7.0.3-1.x86_64.rpm
sudo yum install grafana-7.0.3-1.x86_64.rpm -y
sudo service grafana-server status
sudo systemctl daemon-reload
sudo service grafana-server start