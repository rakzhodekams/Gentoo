# Services
- Create a user to run each Service.
# Database
- If Database is exploited, attacker only have access to this user DB. 
- If we use MySQL in our private server, is good to BIND our MySQL server to the localhost (127.0.0.1:3306)
# IP UDP / TCP ports
- All ports below 1024 are Priviledged ports ( need root access to open them ) 
# SSH 
- Set SSH connections to all Private IP known  Address to not Expose SSH service to Public
- Using external Server to connect Internet: 
> e.g: ssh -L 8080:google.com:80 ServerIP 
> e.g: ssh -D 8080 ServerIP  ( Dynamic Port Forwarding / Socks )
- SSHd_config: set banner to NONE
# SSH + SELinux
- semanage port -a -t ssh_port_t -p tcp PORT 
- semanage -l | grep ssh 
# FireWall 
- KERNEL Framework: Netfilter
- Tool Framework: IPTables
> Display Filter Table: iptables -L 
> Display NAT Table: iptables -t nat -L 
> Display using numeric output: iptables -nL 
> Display using verbose output: iptables -vL 
> Display line-number for each rule: iptables --line-number -L 
> Block IP Address: iptables -A INPUT -s IP -j DROP 
> Accept SSH from specific network: iptables -A INPUT -s 10.0.0.0/24 -p tcp --dport 22 -j ACCEPT || [1]
> Block all other SSH connections from all other networks: iptables -A INPUT -p tcp --dport -j DROP || [2]
# Information Leakage
- Avoid revealing information
- Web Server Banners ( /etc/motd | /etc/issue | /etc/issue.logo ) 
- SSH Server Banners ( /etc/gentoo-release ) 

