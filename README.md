# container to help manage a cluster of coreOS machines that boot via PXE
My first container, learning and work in progress!

Forked from the nice work at [jpetazzo/pxe](https://github.com/jpetazzo/pxe). 

## Notes:
- developed using IBM blades, with a serial console on ttyS1, and a private VLAN on ethernet 2, that is used for DHCP/PXE and coreOS comms only.
- "public" IP address is set by cloud-config, not DHCP.
- DHCP subnet is currently hardcoded as a /24, from .10 to .250; but it should/could be even smaller, as we use reservations?... 
- Yes, it sounds silly to read the config files on each request on the httpserver, but this way you can change the config files on the data folder and not have to reload the container... this should only happen when a host boots.

## Enhancements over the original project:
- IP address and subnet for DHCP server and range are extracted from the IP address set on eth1 via pipework.
- boot different OSs based on configuration options.
- includes "smart" webserver to provide a personalised cloud-config to each host.
 
## TODO:
- currently glued to the host that contains the data folder. find better, more independent storage option.
- don't run more than one of these on the same data folder...
- automatic process to update the coreos pxe files?

## HOW DOES IT WORK:
When the container starts, it processes the *pxe_hosts.json* file, to create a *dhcp_reservations* and *dhcp_options* files for dnsmasq.
pxelinux is configured to offer two config files, stable or beta, based on the channel you choose for your host. 

It will also get the latest coreos release (stable and beta) and a pxelinux.0, if not present on the data folder.

When the host boots, it will get a cloud-config file from this same container, via a python web server script running on port 8080.
That script gets the client private IP address of the request, and replaces the variables on the *default.yaml* file
(represented by a `$<variable>`) for that host.
  
So you just have customise your *default.yaml* for your hardware, and add hosts to your *pxe_hosts.json*.

As the original project, you need to setup on the host a bridge that has access to the pxe network, and then connect it to the container via pipework.

## TO BUILD:
two options: git clone this repo: 
```
$ git clone https://github.com/avlis/pxe_coreos pxe_coreos
$ cd pxe_coreos
```
or just download the Dockerfile.net into an empty folder (and rename it to Dockerfile):
```
$ mkdir pxe_coreos && cd pxe_coreos
$ wget https://github.com/avlis/pxe_coreos/Dockerfile.net -O Dockerfile
 ```
 
then:
```
$ docker build -t pxe_coreos .
```

## TO LAUNCH:

make sure you have a proper *default.yaml* and a *pxe_hosts.json* file on your data folder!
(in this example, it's in /home/core/pxe_coreos.data)

you can use a script similar to the one below (or the [manage_pxe_container](https://github.com/avlis/pxe_coreos/blob/master/utilities/manage_pxe_container) one) to start the container:
```#!/bin/bash
VLAN_ADDR=192.168.90.2
PXECID=$(docker run -v /home/core/pxe_coreos.data:/cloudconfigserver/data -d pxe_coreos)
if [ -z "$PXECID" ]; then
   echo something bad happened, container not launched.
   exit 1
fi
sudo /root/bin/pipework br-internal $PXECID $VLAN_ADDR/24
```

## MANAGENENT & TROUBLESHOOTING:

check out the [manage_pxe_container](https://github.com/avlis/pxe_coreos/blob/master/utilities/manage_pxe_container) shell script on the utilites folder (on git, not on the container).

- make sure you have a properly indented *default.yaml*, and a properly written *pxe_hosts.json*.
- a while after the container starts, you should have 5 files on <data folder>/tftp: pxelinux.0 and 4 coreosfiles:  coreos_[beta|stable]_pxe[.vmlinuz|_image.cpio.gz]
- you can manually update those files and reboot your host, no need to restart the pxe_coreos container.
- check the output of the startup script with the docker logs command.
- check the content of *<data folder>/dnsmasq/dhcp_leases*, to see if dnsmasq is giving IPs to hosts;
  get those mac addresses from that file and copy to new host entries on *pxe_hosts.json*
- you can check the cloud-config file from somewhere else, just add an ?override_ipv4=`<ip>` to the url:
  `http://<ip of the container>:8080/?override_ipv4=<ip you want to check>`
- for pxe stuff... tcpdump & wireshark are your friends...
- the httpserver reloads the config files at each request, but dnsmasq doesn't: you have to restart the container, or 
  enter the container and execute the */cloudconfigserver/bin/reconfig.sh* script.
