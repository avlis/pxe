FROM stackbrew/debian:jessie
ENV ARCH=amd64
	DIST=wheezy
	MIRROR=http://ftp.nl.debian.org
RUN apt-get -q update && apt-get -qy install dnsmasq wget python
RUN mkdir -p /cloudconfigserver/bin /cloudconfigserver/data
COPY bin/* /cloudconfigserver/bin/
RUN chmod +x /cloudconfigserver/bin/*
WORKDIR /cloudconfigserver/data
ENTRYPOINT /cloudconfigserver/bin/startup.sh
