# LAS-stuff
stuff 4 LAS exam @ unibo 

# Iptables Minimum Configuration Generator
iptablesmin.sh generates the minimum iptables configuration based on the input args and output it to a file - by default named output.txt.
Usage examples:
```bash
$ ./iptablesmin.sh ldap ssh snmp syslog vpn
$ ./iptablesmin.sh client 10.1.2.0/24 router 10.1.2.254 ldap ssh snmp syslog in -F
```
More detailed explanation & examples [here](https://github.com/lorenzofelletti/LAS-stuff/blob/master/iptables/usage.md).
