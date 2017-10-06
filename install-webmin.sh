#!/bin/bash

echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee /etc/apt/sources.list.d/webmin.list
curl http://www.webmin.com/jcameron-key.asc | sudo apt-key add -

sudo apt update
sudo apt install -y apt-transport-https webmin
