#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "deb http://ppa.launchpad.net/nfs-ganesha/libntirpc-5/ubuntu jammy main" > /etc/apt/sources.list.d/libntirpc-5.list 
echo "deb-src http://ppa.launchpad.net/nfs-ganesha/libntirpc-5/ubuntu jammy main" >> /etc/apt/sources.list.d/libntirpc-5.list 
apt-get update

mkdir -p /tmp/build/libntirpc
cd /tmp/build/libntirpc
apt-get source libntirpc
apt-get -y build-dep libntirpc 

cd libntirpc-5.0
patch -p0 < /tmp/no_tcmalloc_libntirpc.patch
debuild -b -uc -us
cd ..
mkdir -p /tmp/pkgs
cp *.deb /tmp/pkgs

dpkg -i /tmp/pkgs/libntirpc*
apt-get install -y -f

