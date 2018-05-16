#!/bin/bash

echo 'deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo xenial main' | sudo tee /etc/apt/sources.list.d/realsense-public.list
sudo apt-key adv --keyserver keys.gnupg.net --recv-key 6F3EFCDE -y

sudo apt-get update
sudo apt install -y librealsense2-dkms librealsense2-utils librealsense2-dev librealsense2-dbg

if (modinfo uvcvideo | grep "version:" | grep -q "realsense")
then
    echo Success
else
    echo Looks like your video module was not modified
fi
