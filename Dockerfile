FROM ubuntu:jammy as build
ARG DEBIAN_FRONTEND=noninteractive

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get -y upgrade \
 && ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime \
 && apt-get -y install dpkg-dev build-essential fakeroot devscripts netbase nfs-common dbus glusterfs-common gnupg \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FE869A9 \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 10353E8834DC57CA 

COPY no_tcmalloc_libntirpc.patch build_libntirpc.sh /tmp/
RUN /tmp/build_libntirpc.sh

COPY no_tcmalloc_glusterfs.patch build_glusterfs.sh /tmp/
RUN /tmp/build_glusterfs.sh

COPY no_tcmalloc_ganesha.patch build_nfs-ganesha.sh /tmp/
RUN /tmp/build_nfs-ganesha.sh

FROM ubuntu:jammy
MAINTAINER Chris Picton <chris@picton.nom.za>

COPY --from=build /tmp/pkgs /tmp/pkgs

# install prerequisites
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y netbase nfs-common dbus \
 && find /tmp/pkgs \
 && apt install -y \
   /tmp/pkgs/nfs-ganesha_*.deb \
   /tmp/pkgs/nfs-ganesha-vfs_*.deb \
   /tmp/pkgs/nfs-ganesha-gluster_*.deb \
   /tmp/pkgs/libntirpc5_*.deb \
   /tmp/pkgs/glusterfs-common_*.deb \
   /tmp/pkgs/glusterfs-ganesha_*.deb \
   /tmp/pkgs/libglusterfs0_*.deb \
   /tmp/pkgs/libgfchangelog0_*.deb \
   /tmp/pkgs/libgfapi0_*.deb \
   /tmp/pkgs/libgfrpc0_*.deb \
   /tmp/pkgs/libgfxdr0_*.deb \
   /tmp/pkgs/libglusterd0_*.deb \
   /tmp/pkgs/glusterfs-client_*.deb \
 && apt-get install -f \
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

