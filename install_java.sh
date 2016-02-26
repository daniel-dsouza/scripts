#!/bin/bash
echo Purging openjdk
sudo apt-get purge openjdk*
echo Installing oracle jdk
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get install oracle-java8-installer -y
echo Check version
java -version
javac -version
