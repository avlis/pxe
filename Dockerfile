FROM alpine:latest
RUN apk add --update dnsmasq wget python && rm -rf /var/cache/apk/*
RUN mkdir -p /cloudconfigserver/bin /cloudconfigserver/data
COPY bin/* /cloudconfigserver/bin/
RUN chmod +x /cloudconfigserver/bin/*
WORKDIR /cloudconfigserver/data
ENTRYPOINT /cloudconfigserver/bin/startup.sh
