#!/bin/bash
echo Waiting for pipework to give us the eth1 interface... 
/cloudconfigserver/bin/pipework --wait
myIP=$(ip addr show dev eth1 | awk -F '[ /]+' '/global/ {print $3}')
mySUBNET=$(echo $myIP | cut -d '.' -f 1,2,3)
echo Got IP $myIP, on subnet $mySUBNET 
echo configuring this instance...
cd /cloudconfigserver/data
echo downloading coreos if needed
[ ! -f coreos_stable_pxe.vmlinuz ] && wget http://stable.release.core-os.net/amd64-usr/current/coreos_production_pxe.vmlinuz -O coreos_stable_pxe.vmlinuz &
[ ! -f coreos_stable_pxe_image.cpio.gz ] &&  wget http://stable.release.core-os.net/amd64-usr/current/coreos_production_pxe_image.cpio.gz -O coreos_stable_pxe_image.cpio.gz &
[ ! -f coreos_beta_pxe.vmlinuz ] &&  wget http://beta.release.core-os.net/amd64-usr/current/coreos_production_pxe.vmlinuz -O coreos_beta_pxe.vmlinuz &
[ ! -f coreos_beta_pxe_image.cpio.gz ] &&  wget http://beta.release.core-os.net/amd64-usr/current/coreos_production_pxe_image.cpio.gz -O coreos_beta_pxe_image.cpio.gz &
echo making pxe menus
printf "DEFAULT coreos-stable\nlabel coreos-stable\n\tmenu default\n\tkernel coreos_stable_pxe.vmlinuz\n\tappend initrd=coreos_stable_pxe_image.cpio.gz console=ttyS1,19200n8 console=tty0 coreos.autologin=ttyS1 coreos.autologin=tty0 cloud-config-url=http://$myIP\n" pxelinux.cfg.stable
printf "DEFAULT coreos-beta\nlabel coreos-beta\n\tmenu default\n\tkernel coreos_beta_pxe.vmlinuz\n\tappend initrd=coreos_beta_pxe_image.cpio.gz console=ttyS1,19200n8 console=tty0 coreos.autologin=ttyS1 coreos.autologin=tty0 cloud-config-url=http://$myIP\n" pxelinux.cfg.beta
echo making dnsmask config files from pxe_hosts.json file...
/cloudconfigserver/bin/make_dnsmasq_dhcp_reservations.py > dhcp_reservations.dnsmasq
/cloudconfigserver/bin/make_dnsmasq_dhcp_options.py > dhcp_options.dnsmasq
echo Starting DHCP+TFTP server...
dnsmasq --interface=eth1 \
	--dhcp-hostsfile=/cloudconfigserver/data/dhcp_reservations.dnsmasq \
	--dhcp-optsfile=/cloudconfigserver/data/dhcp_optionsgit.dnsmasq \
	--dhcp-range=$mySUBNET.10,$mySUBNET.250,255.255.255.0,1h \
	--dhcp-boot=pxelinux.0,pxeserver,$myIP \
	--pxe-service=x86PC,"boot coreOS",pxelinux \
	--enable-tftp --tftp-root=/tftp/
/cloudconfigserver/bin/cloudconfigserver.py