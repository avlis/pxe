FROM stackbrew/debian:jessie
ENV ARCH amd64
ENV DIST wheezy
ENV MIRROR http://ftp.nl.debian.org
RUN apt-get -q update
RUN apt-get -qy install dnsmasq wget python
RUN wget --no-check-certificate https://raw.github.com/jpetazzo/pipework/master/pipework
RUN chmod +x pipework
RUN mkdir /cloudconfigserver
RUN mkdir /cloudconfigserver/data
RUN mkdir /cloudconfigserver/bin
WORKDIR /cloudconfigserver/bin
RUN wget --no-check-certificate https://raw.githubusercontent.com/avlis/pxe/coreOS/pipework
RUN wget --no-check-certificate https://raw.githubusercontent.com/avlis/pxe/coreOS/make_dnsmasq_dhcp_reservations.py
RUN wget --no-check-certificate https://raw.githubusercontent.com/avlis/pxe/coreOS/make_dnsmasq_dhcp_options.py
RUN wget --no-check-certificate https://raw.githubusercontent.com/avlis/pxe/coreOS/cloudconfigserver.py
RUN wget --no-check-certificate https://raw.githubusercontent.com/avlis/pxe/coreOS/startup.sh
RUN chmod +x *
RUN mkdir /tftp
WORKDIR /tftp
RUN wget $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/pxelinux.0
RUN ln -s /cloudconfigserver/data/coreos_stable_pxe.vmlinuz 
RUN ln -s /cloudconfigserver/data/coreos_stable_pxe_image.cpio.gz
RUN ln -s /cloudconfigserver/data/coreos_beta_pxe.vmlinuz
RUN ln -s /cloudconfigserver/data/coreos_beta_pxe_image.cpio.gz
RUN mkdir pxelinux.cfg
ENTRYPOINT /cloudconfigserver/bin/startup.sh
