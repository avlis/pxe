#!/bin/bash
cd /cloudconfigserver/data
/cloudconfigserver/bin/make_dnsmasq_dhcp_reservations.py > dnsmasq/dhcp_reservations
/cloudconfigserver/bin/make_dnsmasq_dhcp_options.py > dnsmasq/dhcp_options
killall5 -HUP dnsmasq