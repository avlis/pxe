#!/usr/bin/env python

import time
import BaseHTTPServer
import json
import re

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
		with open('pxe_hosts.json') as data_file:    
			hosts_data=json.load(data_file)
		myClient=s.client_address[0]

		if myClient not in hosts_data['hosts'].keys():
			#print "error: host %s not found" % (myClient) 
			s.send_response(404)
			s.send_header("Content-type", "text/plain")
			s.end_headers()
		else:
			#print "sending config to host %s" % (myClient) 
			s.send_response(200)
			s.send_header("Content-type", "text/plain")
			s.end_headers()

			myReplacements=[]
			myReplacements.append( ('\$private_ipv4',myClient) )		
			for k in hosts_data['common']:
				newrep=('\$'+k, hosts_data['common'][k])
				myReplacements.append( newrep )
			for k in hosts_data['hosts'][myClient]:
				newrep=('\$'+k, hosts_data['hosts'][myClient][k])
				myReplacements.append( newrep )
			myBuffer=s.load_file('default.yaml',myReplacements)		
			s.wfile.write(myBuffer)

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