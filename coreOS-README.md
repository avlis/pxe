This version of this container tries to help managing a cluster of coreOS machines that boot via PXE.

(learning and work in progress!)

Notes:
- developed using IBM blades, with a serial console on ttyS1, and a private VLAN on ethernet 2, that is used for PXE and coreOS comms only.


Enhancements over the original project:
- IP address and subnet is calculated from the IP address set on eth1 via pipework.
 
TODO:
- currently glued to the host that contains the data folder. 

to launch:

export PXECID=$(docker run -v /home/core/pxe_coreos.data:/cloudconfigserver/data -d pxe_coreos)
if [ -z "$PXECID" ]; then
   echo container not launched.
   exit 1
fi
sudo /root/bin/pipework br-internal $PXECID 192.168.90.2/24