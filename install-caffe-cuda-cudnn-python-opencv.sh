#!/bin/bash

# Install Dependencies
sudo apt install -y libprotobuf-dev \
 libleveldb-dev \
 libsnappy-dev \
 libopencv-dev \
 libhdf5-serial-dev \
 protobuf-compiler

sudo apt install -y --no-install-recommends -y libboost-all-dev
sudo apt install -y libatlas-base-dev
sudo apt install -y libgflags-dev libgoogle-glog-dev liblmdb-dev
sudo apt install -y python-pip python3-pip python-dev python3-dev python-skimage python3-skimage python-protobuf

# these things may be broken/out of date on older 16.04 systems...
sudo -H pip3 install python-dateutil python-util --upgrade
sudo -H pip3 install protobuf

# Download Caffe and config
git clone https://github.com/BVLC/caffe.git ~/Documents/caffe
wget -P ${HOME}/Documents/caffe/ https://gist.githubusercontent.com/daniel-dsouza/2b58eb6e98fc15a40089e03a615e8723/raw/d1a80471a953bf8f4a8320f1219d37aeb01adf54/Makefile.config

# now it can find the Boost properly
sudo ln -s /usr/lib/x86_64-linux-gnu/libboost_python-py35.so /usr/lib/x86_64-linux-gnu/libboost_python3.so
sudo ln -s /usr/lib/x86_64-linux-gnu/libboost_python-py27.so /usr/lib/x86_64-linux-gnu/libboost_python2.so
sudo ldconfig

# Time to build
cd ~/Documents/caffe
make all -j$(nproc)

# let Python3 know where Caffe was installed
make pycaffe -j$(nproc)
USER_SITE=$(python3 -m site --user-site)
mkdir -p $USER_SITE
echo $(pwd)/python > ${USER_SITE}/caffe.pth

# make test
make test
make runtest


