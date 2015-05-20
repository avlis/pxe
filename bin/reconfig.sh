#!/bin/bash
cd /cloudconfigserver/data
/cloudconfigserver/bin/make_dnsmasq_dhcp_reservations.py > dhcp_reservations.dnsmasq
/cloudconfigserver/bin/make_dnsmasq_dhcp_options.py > dhcp_options.dnsmasq
killall -HUP dnsmasq