#!/bin/env sh 
# Oscar FM: odicforcesounds.com
# IPTABLES community tell us to not use Scripts:
# Flush it ! 

# Flush / Remove all iptablesABLES rules from all chains
 iptables -P INPUT ACCEPT
 iptables -P FORWARD ACCEPT
 iptables -P OUTPUT ACCEPT

 iptables -t nat -F 
 iptables -t mangle -F 
 iptables -F 
 iptables -X 

 # Allow Loopback Connections ( localhost ) 
 iptables -A INPUT -i lo -j ACCEPT 
 iptables -A OUTPUT -o lo -j ACCEPT

 # Allow out-going FTP connections 
 iptables -A OUTPUT -p tcp --dport 21 conntrack --ctstate NEW,ESTABLISHED -j ACCEPT 
 iptables -A INPUT -p tcp --dport 21 conntrack --ctstate ESTABLISHED -j ACCEPT

 # Allow out-going SSH connections 
 iptables -A OUTPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT 
 iptables -A INPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

 # Allow out-going HTTP connections
 iptables -A OUTPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
 iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT 

 # Allow out-going SSL connections
 iptables -A OUTPUT -p tcp --dport 443 -p conntrack --ctstate NEW,ESTABLISHED -j ACCEPT 
 iptables -A INPUT -p tcp --dport 443 -p conntrack --ctstate ESTABLISHED -j ACCEPT

 # Allow out-going SMTP connections
 iptables -A OUTPUT -p tcp --dport 25 -j ACCEPT

 # Allow out-going IMAPS connections 
 iptables -A OUTPUT -p tcp --dport 993 -p conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
 iptables -A INPUT -p tcp --dport 993 -p conntrack --ctstate ESTABLISHED -j ACCEPT 

# Security 
 
 # Block all ICMP Ping Request
 iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

 # Against Strings* 
 iptables -A FORWARD -m string --string '.com' -j DROP
 iptables -A FORWARD -m string --string '.exe' -j DROP

 # Against PortScans
 iptables -N port-scanning
 iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit 1/s --limit-burst 2 -j RETURN
 iptables -A port-scanning -j DROP

 # Syn-Flood Protection
 iptables -A INPUT -p tcp --syn -j syn_flood
 iptables -A syn_flood -m limit --limit 1/s --limit-burst 3 -j RETURN
 iptables -A syn_flood -j DROP
 iptables -A INPUT -p icmp -m limit --limit 1/s --limit-burst 1 -j ACCEPT 
 iptables -A INPUT -p icmp -m limit --limit 1/s --limit-burst 1 -j LOG --log-prefix PING-DROP: 
 iptables -A INPUT -p icmp -j DROP 
 iptables -A OUTPUT -p icmp -j ACCEPT 

 # Force Fragment Check
 iptables -A INPUT -f -j DROP 
 
 # DROP XMAS Packets
 iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP 
 
 # DROP NULL Packets 
 iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP 

 # Block Uncommon MSS Values 
 iptables -t mangle -A PREROUTING -p tcp -m conntrack NEW -m tcpmss ! --mss 536:65535 -j DROP 

 # Block packets with BOGUS TCP flags 
 iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
 iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
 iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
 iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
 iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
 iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
 iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP
 iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
 iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP
 iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
 iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
 iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
 iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

 # Block packets form private subnets ??



