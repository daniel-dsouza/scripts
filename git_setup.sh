#!/bin/bash

# git setup script for Ubuntu
sudo apt-get remove git -y

# install the latest version of git
sudo apt-add-repository ppa:git-core/ppa -y
sudo apt-get update
sudo apt-get install git -y

# configure git
USER_NAME=getent passwd $USER | cut -d ':' -f 5 | cut -d ',' -f 1

git config --global user.email "daniel.dsouza5@gmail.com"
git config --global user.name $USER_NAME
git config --global push.default simple
git config --global core.editor "vim"

# configure keyring
sudo apt-get install libgnome-keyring-dev -y
cd /usr/share/doc/git/contrib/credential/gnome-keyring
sudo make
git config --global credential.helper /usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring
