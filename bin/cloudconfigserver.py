#!/usr/bin/env python

import time
import BaseHTTPServer
import json
import re
from urlparse import urlparse, parse_qs
import os.path

HOST_NAME = '0.0.0.0' # 
PORT_NUMBER = 8080 # Maybe set this to 9000.


class MyHandler(BaseHTTPServer.BaseHTTPRequestHandler):

	def load_file(self,p_file, p_replacements):
		# Read contents from file as a single string
		file_handle = open(p_file, 'r')
		file_string = file_handle.read()
		file_handle.close()
		for r in p_replacements:
			file_string = (re.sub(r[0], r[1], file_string))
		return file_string

	def do_HEAD(s):
		s.send_response(200)
		s.send_header("Content-type", "text/plain")
		s.end_headers()
	def do_GET(s):
		"""Respond to a GET request."""
		hosts_data={}
		if not os.path.isfile('pxe_hosts.json'):
			s.wfile.write("#cloud-config\n\n#Please check your configuration folder, can't find the file [pxe_hosts.json]\n")
			return
				
		with open('pxe_hosts.json') as data_file:    
			hosts_data=json.load(data_file)
			
		myClient=''
		query_components = parse_qs(urlparse(s.path).query)	
		if 'override_ipv4' in query_components.keys():
			myClient=query_components['override_ipv4'][0][:16]

		isValidIPV4 = re.compile("\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}")
		if not isValidIPV4.match(myClient):
			myClient=s.client_address[0][:16]

		if myClient not in hosts_data['hosts'].keys():
			s.send_response(404)
			s.send_header("Content-type", "text/plain")
			s.end_headers()
			s.wfile.write("#cloud-config\n\n#Please add %s to the file [pxe_hosts.json].\n" % myClient)
		else:
			s.send_response(200)
			s.send_header("Content-type", "text/plain")
			s.end_headers()

			myReplacements=[]
			myReplacements.append( ('\$private_ipv4',myClient) )		
			for k in hosts_data['common']:
				if k[:1]=="$":
					newrep=('\\'+k, hosts_data['common'][k])
					myReplacements.append( newrep )
			for k in hosts_data['hosts'][myClient]:
				if k[:1]=="$":
					newrep=('\\'+k, hosts_data['hosts'][myClient][k])
					myReplacements.append( newrep )
			if 'template' in hosts_data['hosts'][myClient]:
				templateFile=hosts_data['hosts'][myClient]['template']
			else:
				templateFile='default.yaml'
			if os.path.isfile(templateFile):
				myBuffer=s.load_file(templateFile,myReplacements)		
				s.wfile.write(myBuffer)
			else:
				s.wfile.write("#cloud-config\n\n#Please check the entry for the host %s on pxe_hosts.json, I can't find the template file [%s].\n" % (myClient,templateFile))

if __name__ == '__main__':
	server_class = BaseHTTPServer.HTTPServer
	httpd = server_class((HOST_NAME, PORT_NUMBER), MyHandler)
	print time.asctime(), "Server Starts - %s:%s" % (HOST_NAME, PORT_NUMBER)
	try:
		httpd.serve_forever()
	except KeyboardInterrupt:
		pass
	httpd.server_close()
	print time.asctime(), "Server Stops - %s:%s" % (HOST_NAME, PORT_NUMBER)