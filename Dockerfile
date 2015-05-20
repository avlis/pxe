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
RUN wget --no-check-certificate https://raw.githubusercontent.com/avlis/pxe/coreOS/make_dnsmasq_dhcp_reservations.py
RUN wget --no-check-certificate https://raw.githubusercontent.com/avlis/pxe/coreOS/make_dnsmasq_dhcp_options.py
RUN wget --no-check-certificate https://raw.githubusercontent.com/avlis/pxe/coreOS/cloudconfigserver.py
RUN mkdir /tftp
WORKDIR /tftp
RUN wget $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/pxelinux.0
RUN wget http://stable.release.core-os.net/amd64-usr/current/coreos_stable_pxe.vmlinuz
RUN wget http://stable.release.core-os.net/amd64-usr/current/coreos_stable_pxe_image.cpio.gz
RUN wget http://beta.release.core-os.net/amd64-usr/current/coreos_beta_pxe.vmlinuz
RUN wget http://beta.release.core-os.net/amd64-usr/current/coreos_beta_pxe_image.cpio.gz
RUN mkdir pxelinux.cfg
RUN printf "DEFAULT coreos-stable\nlabel coreos-stable\n\tmenu default\n\tkernel coreos_stable_pxe.vmlinuz\n\tappend initrd=coreos_stable_pxe_image.cpio.gz console=ttyS1,19200n8 console=tty0 coreos.autologin=ttyS1 coreos.autologin=tty0\n" >pxelinux.cfg/stable
RUN printf "DEFAULT coreos-beta\nlabel coreos-beta\n\tmenu default\n\tkernel coreos_beta_pxe.vmlinuz\n\tappend initrd=coreos_beta_pxe_image.cpio.gz console=ttyS1,19200n8 console=tty0 coreos.autologin=ttyS1 coreos.autologin=tty0\n" >pxelinux.cfg/beta
ENTRYPOINT /cloudconfigserver/bin/startup.sh
