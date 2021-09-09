#!/usr/bin/env bash

sudo apt update -q
sudo apt install -y ifupdown

echo | sudo tee /etc/network/interfaces << 'EOM'
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback
EOM

sudo ifdown --force lo && ifup -a
sudo systemctl unmask networking
sudo systemctl enable networking
sudo systemctl restart networking

sudo systemctl stop systemd-networkd.socket \
  systemd-networkd \
  networkd-dispatcher \
  systemd-networkd-wait-online
sudo systemctl disable systemd-networkd.socket \
  systemd-networkd \
  networkd-dispatcher \
  systemd-networkd-wait-online
sudo systemctl mask systemd-networkd.socket \
  systemd-networkd \
  networkd-dispatcher \
  systemd-networkd-wait-online

sudo apt purge -y nplan netplan.io

echo "YOU must edit the DNS in /etc/systemd/resolved.conf"
echo "then run sudo systemctl restart systemd-resolved"
