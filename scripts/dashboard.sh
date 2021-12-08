#!/bin/bash
GRAFANA_PKG=grafana-7.0.3-1.x86_64.rpm
PROMETHEUS_PKG=prometheus-2.8.1.linux-amd64.tar.gz

echo "downloading wget"
sudo  yum -y install wget

### Install Grafana server
if [ -f $GRAFANA_PKG ]
  then 
    echo " ${GRAFANA_PKG}  exist"
   else  
    echo "Install Grafana..."
    sudo wget https://dl.grafana.com/oss/release/grafana-7.0.3-1.x86_64.rpm
    sudo yum install grafana-7.0.3-1.x86_64.rpm -y
    echo "Grafana dashboard installed"
    echo "Set Grafana service enabled"
    sudo service grafana-server status
    sudo systemctl daemon-reload
    sudo service grafana-server start
fi

### Install prometheus agent to collect data metrics from  kafka-brokers
if [ -f $PROMETHEUS_PKG ]
  then 
    echo " ${PROMETHEUS_PKG} exist"
   else  
     echo "download prometheus agent"
     sudo wget https://github.com/prometheus/prometheus/releases/download/v2.8.1/prometheus-2.8.1.linux-amd64.tar.gz
     echo "add prometheus user"
     sudo useradd --no-create-home --shell /bin/false prometheus
     echo "create folder for prometheus"
     sudo mkdir /etc/prometheus && sudo mkdir /var/lib/prometheus
     sudo chown prometheus:prometheus /etc/prometheus && sudo chown prometheus:prometheus /var/lib/prometheus

##unzip package prometheus    
    tar -xvzf prometheus-2.8.1.linux-amd64.tar.gz
    echo "rename package"
    mv prometheus-2.8.1.linux-amd64 prometheuspackage
    sudo cp prometheuspackage/prometheus /usr/local/bin/
    sudo cp prometheuspackage/promtool /usr/local/bin/
    sudo chown prometheus:prometheus /usr/local/bin/prometheus
    sudo chown prometheus:prometheus /usr/local/bin/promtool
    sudo cp -r prometheuspackage/consoles /etc/prometheus
    sudo cp -r prometheuspackage/console_libraries /etc/prometheus
    sudo chown -R prometheus:prometheus /etc/prometheus/consoles
    sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

sudo bash -c 'cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF'


sudo bash -c 'cat << EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus_master'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'Broker_cluster_kafka'
    scrape_interval: 20s
    static_configs:
      - targets: ['vkc-br1:7075', 'vkc-br2:7075', 'vkc-br3:7075']
EOF'

sudo systemctl daemon-reload
sudo systemctl start prometheus 
sudo systemctl status prometheus

fi



