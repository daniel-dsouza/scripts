#!/bin/bash

cd ${HOME}/Documents
wget https://github.com/google/protobuf/releases/download/v3.4.1/protobuf-cpp-3.4.1.tar.gz
tar -xf protobuf-cpp-3.4.1.tar.gz
cd protobuf-cpp-3.4.1

# download dependencies
sudo apt-get install autoconf automake libtool curl make g++ unzip -y

# build the c++ version
./autogen.sh
./configure
make -j${nproc} && make check && sudo make install && sudo ldconfig

# download Go binaries
go get -u github.com/golang/protobuf/protoc-gen-go
