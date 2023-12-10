FROM ubuntu:jammy as build
ARG DEBIAN_FRONTEND=noninteractive
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y gnupg \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FE869A9 \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 10353E8834DC57CA \
 && echo "deb http://ppa.launchpad.net/nfs-ganesha/nfs-ganesha-5/ubuntu jammy main" > /etc/apt/sources.list.d/nfs-ganesha-5.list \
 && echo "deb-src http://ppa.launchpad.net/nfs-ganesha/nfs-ganesha-5/ubuntu jammy main" >> /etc/apt/sources.list.d/nfs-ganesha-5.list \
 && echo "deb http://ppa.launchpad.net/nfs-ganesha/libntirpc-5/ubuntu jammy main" > /etc/apt/sources.list.d/libntirpc-5.list \
 && echo "deb http://ppa.launchpad.net/gluster/glusterfs-10/ubuntu jammy main" > /etc/apt/sources.list.d/glusterfs-10.list\
 && apt-get update \
 && ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime \
 && apt-get -y install dpkg-dev build-essential fakeroot devscripts \
 && apt-get install -y netbase nfs-common dbus glusterfs-common ceph-common 

RUN export DEBIAN_FRONTEND=noninteractive \
 && mkdir /tmp/build \
 && cd tmp/build \
 && apt-get source nfs-ganesha \
 && apt-get -y build-dep nfs-ganesha \
 && apt-get -y install libntirpc-dev

COPY no_tcmalloc.patch /tmp/
RUN export DEBIAN_FRONTEND=noninteractive \
  && cd /tmp/build/nfs-ganesha-5.? \
  && patch -p0 < /tmp/no_tcmalloc.patch \
  && debuild -b -uc -us \
  && cd .. \
  && mkdir -p /tmp/pkgs \
  && cp *.deb /tmp/pkgs
   

FROM ubuntu:jammy
MAINTAINER Chris Picton <chris@picton.nom.za>

COPY --from=build /tmp/pkgs /tmp/pkgs

# install prerequisites
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y gnupg \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FE869A9 \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 10353E8834DC57CA \
 && echo "deb http://ppa.launchpad.net/nfs-ganesha/nfs-ganesha-5/ubuntu jammy main" > /etc/apt/sources.list.d/nfs-ganesha-5.list \
 && echo "deb http://ppa.launchpad.net/nfs-ganesha/libntirpc-5/ubuntu jammy main" > /etc/apt/sources.list.d/libntirpc-5.list \
 && echo "deb http://ppa.launchpad.net/gluster/glusterfs-10/ubuntu jammy main" > /etc/apt/sources.list.d/glusterfs-10.list\
 && apt-get update \
 && apt-get install -y netbase nfs-common dbus glusterfs-common \
 && find /tmp/pkgs \
 && apt install -y /tmp/pkgs/nfs-ganesha_*.deb /tmp/pkgs/nfs-ganesha-vfs_*.deb /tmp/pkgs/nfs-ganesha-gluster_*.deb \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && mkdir -p /run/sendsigs.omit.d \
 && mkdir -p /var/run/ganesha

# Add startup script
COPY start.sh /

# NFS ports and portmapper
EXPOSE 2049 38465-38467 662 111/udp 111

# Start Ganesha NFS daemon by default
CMD ["/start.sh"]

