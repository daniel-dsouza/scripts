#!/bin/bash

# install Docker CE
sudo apt-get remove docker docker-engine docker.io
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt-get install docker-ce -y

# install dependencies
sudo apt install libvirt-bin qemu-kvm -y
sudo usermod -a -G libvirtd $(whoami)
newgrp libvirtd

# install docker machine
curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine
chmod +x /tmp/docker-machine
sudo cp /tmp/docker-machine /usr/local/bin/docker-machine


# install docker-machine-kvm
curl -L https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.10.0/docker-machine-driver-kvm-ubuntu16.04
sudo mv docker-machine-driver-kvm /usr/local/bin/ 
chmod +x /usr/local/bin/docker-machine-driver-kvm

# install Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

# install kubectl
sudo snap install kubectl --classic




