#!/bin/bash

#setup apt and update packages
sudo apt-get remove git -y
sudo apt-add-repository ppa:git-core/ppa -y
sudo apt-get update
sudo apt-get upgrade -y

# install basics
sudo apt-get install git build-essential cmake libncurses5-dev -y

# get kernel sources
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.1.15.tar.xz
tar -xf linux-4.1.15.tar.xz
cd linux-4.1.15
pwd

# start building kernel
make menuconfig
make bzImage
make modules
make modules_install
sudo make install
sudo update-grub

# all done
sudo reboot
