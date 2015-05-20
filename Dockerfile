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
WORKDIR /cloudconfigserver/data
ENTRYPOINT /cloudconfigserver/bin/startup.sh
