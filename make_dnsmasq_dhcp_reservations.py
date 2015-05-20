#!/usr/bin/env python

import json
from pprint import pprint

with open('pxe_hosts.json') as data_file:    
    hosts_data = json.load(data_file)

for hi in hosts_data['hosts']:
	print "%s,set:%s,%s,%s" % (hosts_data['hosts'][hi]['macaddr'],hosts_data['hosts'][hi]['channel'],hi ,hosts_data['hosts'][hi]['hostname'])