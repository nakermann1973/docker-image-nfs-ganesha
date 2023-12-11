#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "deb http://ppa.launchpad.net/gluster/glusterfs-10/ubuntu jammy main" > /etc/apt/sources.list.d/glusterfs-10.list
echo "deb-src http://ppa.launchpad.net/gluster/glusterfs-10/ubuntu jammy main" >> /etc/apt/sources.list.d/glusterfs-10.list

apt-get update

mkdir -p /tmp/build/glusterfs
cd /tmp/build/glusterfs
apt-get source glusterfs
apt-get -y build-dep glusterfs 

cd glusterfs-10.5
patch -p0 < /tmp/no_tcmalloc_glusterfs.patch
debuild -b -uc -us
cd ..
mkdir -p /tmp/pkgs
cp *.deb /tmp/pkgs

dpkg -i /tmp/pkgs/*gluster* /tmp/pkgs/libgf*
apt-get install -y -f

