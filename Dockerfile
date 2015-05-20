FROM stackbrew/debian:jessie
ENV ARCH amd64
ENV DIST wheezy
ENV MIRROR http://ftp.nl.debian.org
RUN apt-get -q update
RUN apt-get -qy install dnsmasq wget python
RUN mkdir /cloudconfigserver
RUN mkdir /cloudconfigserver/data
RUN mkdir /cloudconfigserver/bin
COPY bin/* /cloudconfigserver/bin/
RUN chmod +x /cloudconfigserver/bin/*
WORKDIR /cloudconfigserver/data
ENTRYPOINT /cloudconfigserver/bin/startup.sh
