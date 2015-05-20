#!/usr/bin/env python

import json
from pprint import pprint

with open('pxe_hosts.json') as data_file:    
    hosts_data = json.load(data_file)

for hi in hosts_data['hosts']:
	print "%s,209,\"pxelinux.cfg/%s\"" % (hosts_data['hosts'][hi]['hostname'],hosts_data['hosts'][hi]['channel'])