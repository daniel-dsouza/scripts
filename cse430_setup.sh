#!/bin/bash

CORE=$(nproc)

#setup apt and update packages
sudo apt-get remove git -y
sudo apt-add-repository ppa:git-core/ppa -y
sudo apt-get update
sudo apt-get upgrade -y

# install basics
sudo apt-get install git build-essential cmake libncurses5-dev bc -y

# get kernel sources
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.1.15.tar.xz
tar -xf linux-4.1.15.tar.xz
cd linux-4.1.15
pwd

# start building kernel
make menuconfig
make bzImage -j$CORE
make modules -j$CORE
make modules_install -j$CORE
sudo make install -j$CORE
sudo update-grub

# all done
sudo reboot
