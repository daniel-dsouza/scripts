#!/bin/bash

# git setup script for Ubuntu
sudo apt-get remove git -y

# install the latest version of git
sudo apt-add-repository ppa:git-core/ppa -y
sudo apt-get update
sudo apt-get install git -y

# configure git
git config --global user.email "daniel.dsouza5@gmail.com"
git config --global user.name "Daniel D'Souza"
git config --global push.default simple
git config --global core.editor "vim"

# configure keyring
sudo apt-get install libgnome-keyring-dev -y
cd /usr/share/doc/git/contrib/credential/gnome-keyring
sudo make
git config --global credential.helper /usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring
