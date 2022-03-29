FROM ubuntu:xenial
MAINTAINER Mitchell Hewes <me@mitcdh.com>
LABEL org.opencontainers.image.source=https://github.com/apnar/docker-image-nfs-ganesha

# install prerequisites
RUN DEBIAN_FRONTEND=noninteractive \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FE869A9 \
 && echo "deb http://ppa.launchpad.net/gluster/nfs-ganesha-2.7/ubuntu xenial main" > /etc/apt/sources.list.d/nfs-ganesha-2.7.list \
 && echo "deb http://ppa.launchpad.net/gluster/libntirpc-1.7/ubuntu xenial main" > /etc/apt/sources.list.d/libntirpc-1.7.list \
 && echo "deb http://ppa.launchpad.net/gluster/glusterfs-10/ubuntu xenial main" > /etc/apt/sources.list.d/glusterfs-10.list \
 && apt-get update \
 && apt-get install -y netbase nfs-common dbus nfs-ganesha nfs-ganesha-vfs glusterfs-common \
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

