#!/bin/bash
echo Waiting for pipework to give us the eth1 interface... 
pipework --wait
echo Starting DHCP+TFTP server...
myIP=$(ip addr show dev eth1 | awk -F '[ /]+' '/global/ {print $3}')
mySUBNET=$(echo $myIP | cut -d '.' -f 1,2,3)
cd /cloudconfigserver/data
/cloudconfigserver/bin/make_dnsmasq_dhcp_reservations.py > dhcp_reservations.dnsmasq
/cloudconfigserver/bin/make_dnsmasq_dhcp_options.py > dhcp_options.dnsmasq
dnsmasq --interface=eth1 \
	--dhcp-hostsfile=/cloudconfigserver/data/dhcp_reservations.dnsmasq \
	--dhcp-optsfile=/cloudconfigserver/data/dhcp_optionsgit.dnsmasq \
	--dhcp-range=$mySUBNET.10,$mySUBNET.250,255.255.255.0,1h \
	--dhcp-boot=pxelinux.0,pxeserver,$myIP \
	--pxe-service=x86PC,"boot coreOS",pxelinux \
	--enable-tftp --tftp-root=/tftp/
/cloudconfigserver/bin/cloudconfigserver.py