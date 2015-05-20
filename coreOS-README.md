This version of this container tries to help manage a cluster of coreOS machines that boot via PXE.

(learning and work in progress!)

Notes:
- developed using IBM blades, with a serial console on ttyS1, and a private VLAN on ethernet 2, that is used for DHCP/PXE and coreOS comms only.
- "public" IP address is set by cloud-config, not DHCP.

Enhancements over the original project:
- IP address and subnet for container and DHCP range is calculated from the IP address set on eth1 via pipework.
 
TODO:
- currently glued to the host that contains the data folder. 
- don't run more than one of these on the same data folder...
- automatic process to update the coreos pxe files


HOW DOES IT WORK:

When the container starts, it processes the pxe_hosts.json file, to create a dhcp_reservations and dhcp_options file for dnsmasq.
pxelinux is configured to offer two config files, stable or beta, based on the channel you choose for your host. 

it will also get the latest coreos release (stable and beta) and a pxelinux.0, if not present on the data folder.

When the host boots, it will get a cloud-config file from this same container, via a python web server script running on port 8080.
That script gets the client private IP address of the request, and replaces the variables on the default.yaml file
(represented by a $<placeholder>) for that host.
  
So you just have customise your default.yaml for your hardware, and add hosts to your pxe_hosts.json.

TO LAUNCH:

make sure you have a proper default.yaml and a pxe_hosts.json file on your data folder!

export PXECID=$(docker run -v /home/core/pxe_coreos.data:/cloudconfigserver/data -d pxe_coreos)
if [ -z "$PXECID" ]; then
   echo container not launched.
   exit 1
fi
sudo /root/bin/pipework br-internal $PXECID 192.168.90.2/24