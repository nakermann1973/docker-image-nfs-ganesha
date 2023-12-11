#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "deb http://ppa.launchpad.net/nfs-ganesha/nfs-ganesha-5/ubuntu jammy main" > /etc/apt/sources.list.d/nfs-ganesha-5.list 
echo "deb-src http://ppa.launchpad.net/nfs-ganesha/nfs-ganesha-5/ubuntu jammy main" >> /etc/apt/sources.list.d/nfs-ganesha-5.list 

apt-get update

mkdir -p /tmp/build/nfs-ganesha
cd /tmp/build/nfs-ganesha
apt-get source nfs-ganesha
apt-get -y build-dep nfs-ganesha 

cd nfs-ganesha-5.7
patch -p0 < /tmp/no_tcmalloc_ganesha.patch
debuild -b -uc -us
cd ..
mkdir -p /tmp/pkgs
cp *.deb /tmp/pkgs

apt-get install -y daemon
dpkg -i /tmp/pkgs/*ganesha*
apt-get install -y -f

