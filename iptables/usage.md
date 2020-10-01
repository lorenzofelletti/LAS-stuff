# Iptablesmin Usage
iptablesmin generates the minimum iptables configuration based on the input args and output it to a file - by default named output.sh.
## Default Parameters and Output
By default the client, router and server are:
- client: 10.1.1.0/24
- router 10.1.1.254
- server 10.9.9.1/24

The default output file is:
```
# default deny
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
```

## Optional Parameters
| short option 	| long option  	| long option alternative 	| required parameters      	| description                            	|
|--------------	|--------------	|-------------------------	|--------------------------	|----------------------------------------	|
| -c           	| --client     	| client                  	| an ip address            	| client                                 	|
| -r           	| --router     	| router                  	| an ip address            	| router                                 	|
| -s           	| --server     	| server                  	| an ip address            	| server                                 	|
| -x           	| --ssh        	| ssh                     	|                          	| allow ssh                              	|
| -n           	| --snmp       	| snmp                    	|                          	| allow snmp                             	|
| -l           	| --ldap       	| ldap                    	|                          	| allow ldap                             	|
| -g           	| --syslog     	| syslog                  	| in \| out \| inout \| io 	| allow incoming and/or outgoing syslog 	|
| -F           	| --flush-prev 	| flush                   	|                          	| flush nat and iptables as first thing  	|
| -v           	| --vpn        	| vpn                     	|                          	| allow vpn                              	|
| -f           	|              	|                         	| filename                 	| set output file                        	|

## Usage examples
Note: The order in which you list the argument isn't important
```bash
# enable ldap, snmp, incoming syslog with default servers (10.9.9.1/24)
# but custom clients and router
$ ./iptablesmin.sh -c 10.1.3.0/24 -r 10.1.3.254 ldap snmp syslog in

# enable ldap, snmp, syslog in, ssh, vpn and flush previous rules, saving the output to myiptables.txt
$ ./iptablesmin.sh -F --ldap --snmp --ssh --syslog in --vpn -f "myiptables.txt"
# shorter equivalent
./iptablesmin.sh -F ldap snmp ssh syslog in vpn -f "myiptables.txt"
# even shorter equivalent
./iptablesmin.sh -F -l -n -x -g in -v -f "myiptables.txt"
```
