#!/usr/bin/env python

import json
from pprint import pprint

with open('pxe_hosts.json') as data_file:    
    hosts_data = json.load(data_file)

for hi in hosts_data['hosts']:
	print "%s,%s,%s" % (hosts_data['hosts'][hi]['macaddr'],hi ,hosts_data['hosts'][hi]['hostname'])