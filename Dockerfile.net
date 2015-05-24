FROM alpine:latest
RUN apk add --update dnsmasq wget python && rm -rf /var/cache/apk/*
RUN mkdir -p /cloudconfigserver/bin /cloudconfigserver/data
WORKDIR /cloudconfigserver/bin
RUN wget https://raw.githubusercontent.com/avlis/pxe_coreos/master/bin/pipework
RUN wget https://raw.githubusercontent.com/avlis/pxe_coreos/master/bin/make_dnsmasq_dhcp_reservations.py
RUN wget https://raw.githubusercontent.com/avlis/pxe_coreos/master/bin/make_dnsmasq_dhcp_options.py
RUN wget https://raw.githubusercontent.com/avlis/pxe_coreos/master/bin/cloudconfigserver.py
RUN wget https://raw.githubusercontent.com/avlis/pxe_coreos/master/bin/startup.sh
RUN wget https://raw.githubusercontent.com/avlis/pxe_coreos/master/bin/reconfig.sh
RUN chmod +x *
WORKDIR /cloudconfigserver/data
ENTRYPOINT /cloudconfigserver/bin/startup.sh
