#!/bin/bash

echo "hosts file setup..."

sudo echo "10.30.3.2 vkc-zk1" | sudo tee -a /etc/hosts
sudo echo "10.30.3.3 vkc-zk2" | sudo tee -a /etc/hosts
sudo echo "10.30.3.4 vkc-zk3" | sudo tee -a /etc/hosts

sudo echo "10.30.3.50 vkc-br1" | sudo tee -a /etc/hosts
sudo echo "10.30.3.50 broker1" | sudo tee -a /etc/hosts

sudo echo "10.30.3.40 vkc-br2" | sudo tee -a /etc/hosts
sudo echo "10.30.3.40 broker2" | sudo tee -a /etc/hosts

sudo echo "10.30.3.30 vkc-br3" | sudo tee -a /etc/hosts
sudo echo "10.30.3.30 broker3" | sudo tee -a /etc/hosts

sudo echo "10.30.3.20 vkc-br4" | sudo tee -a /etc/hosts
sudo echo "10.30.3.20 broker4" | sudo tee -a /etc/hosts

sudo echo "10.30.3.10 vkc-br5" | sudo tee -a /etc/hosts
sudo echo "10.30.3.10 broker5" | sudo tee -a /etc/hosts

sudo echo "10.30.3.7 vkc-gfn" | sudo tee -a /etc/hosts