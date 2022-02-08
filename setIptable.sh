#!/bin/bash

iptoblock="$1"


#This script is for set up and run ipTables
#Start script 
# echo "***************************START SCRIPT*********************"


# echo "**************************************************"
#clear the existing rule 
iptables -F 

# echo "Deleted the existing rule"
# echo "**************************************************"

#Allow local interface 
iptables -A INPUT -i lo -j ACCEPT

#Open the port to allow local connection 
iptables -A INPUT -s 127.0.0.1 -j ACCEPT

#Enabling Connections for http (80), https(443), ssh(22)

iptables -A INPUT -p tcp --dport 22 - ACCEPT
# echo  "Enabling connection for SSH"
iptables -A INPUT -p tcp --dport 80 - ACCEPT
# echo  "Enabling connection for http"
iptables -A INPUT -p tcp --dport 443 - ACCEPT
# echo  "Enabling connection for https"

#Reject all other traffic 
iptables -A INPUT -j REJECT
iptables -A FORWARD -j REJECT
# echo "Rejected all other traffic" 

#Drop other all traffics to prevent unauthorized connection
iptables -A INPUT -j DROP
# echo "Drop all other traffics" 

#Firewall react to destination IP Address from other script.
#Drop block destination IP Address use 'expire' method for 10 minutes
#set up ipset to match against IP | timeout 0 means never expire
ipset create temp_hosts hash:ip timeout 0
iptables -I INPUT 1 -m set -j DROP --match-set temp_hosts src
iptables -I FORWARD 1 -m set -j DROP --match-set temp_host src

#Note timeout 600 = 10 minutes 120 = 2 minutes as test
ipset add temp_hosts $iptoblock timeout 120

#Exit script 
# echo "*********************END SCRIPT**************"
