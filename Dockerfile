FROM ubuntu:jammy
MAINTAINER Chris Picton <chris@picton.nom.za>

# install prerequisites
RUN DEBIAN_FRONTEND=noninteractive \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FE869A9 \
 && echo "deb http://ppa.launchpad.net/nfs-ganesha/nfs-ganesha-5/ubuntu jammy main" > /etc/apt/sources.list.d/nfs-ganesha-5.list \
 && echo "deb http://ppa.launchpad.net/nfs-ganesha/libntirpc-5/ubuntu jammy main" > /etc/apt/sources.list.d/libntirpc-5.list \
 && echo "deb http://ppa.launchpad.net/gluster/glusterfs-10/ubuntu jammy main" > /etc/apt/sources.list.d/glusterfs-10.list\
 && apt-get update \
 && apt-get install -y netbase nfs-common dbus nfs-ganesha nfs-ganesha-vfs glusterfs-common nfs-ganesha-gluster \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && mkdir -p /run/rpcbind /export /var/run/dbus \
 && touch /run/rpcbind/rpcbind.xdr /run/rpcbind/portmap.xdr \
 && chmod 755 /run/rpcbind/* \
 && chown messagebus:messagebus /var/run/dbus

# Add startup script
COPY start.sh /

# NFS ports and portmapper
EXPOSE 2049 38465-38467 662 111/udp 111

# Start Ganesha NFS daemon by default
CMD ["/start.sh"]

