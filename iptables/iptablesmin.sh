#!/bin/bash

fflag=
farg=
# replace long options with their short counterpart
for arg in "$@"; do
  shift
  case "$arg" in
    "--client"|"client")  set -- "$@" "-c" ;;
    "--router"|"router")  set -- "$@" "-r" ;;
    "--server"|"server")  set -- "$@" "-s" ;;
    "--ssh"|"ssh")        set -- "$@" "-x" ;;
    "--snmp"|"snmp")      set -- "$@" "-n" ;;
    "--ldap"|"ldap")      set -- "$@" "-l" ;;
    "--syslog"|"syslog")  set -- "$@" "-g"  ;;
    "--flush-prev"|"flush")  set -- "$@" "-F";;
    "--vpn"|"vpn")        set -- "$@" "-v";;
    "--*")          echo "$0: ${arg}: invalid option"; exit 1 ;;
    *)              set -- "$@" "$arg" ;;
  esac
done

# parse command otpions
farg=
carg=
rarg=
sarg=
ssh=
snmp=
ldap=
syslogin=
syslogout=
flush=
vflag=
while getopts 'f:c:r:s:g:xnlFv' OPTION ; do
  case $OPTION in
    f)  farg="${OPTARG}" ;;
    c)  carg="${OPTARG}" ;;
    r)  rarg="${OPTARG}" ;;
    s)  sarg="${OPTARG}" ;;
    x)  ssh=1;;
    n)  snmp=1;;
    l)  ldap=1;;
    g)  case "${OPTARG}" in
          "in")   syslogin=1;;
          "out")  syslogout=1;;
          "inout"|"all"|"x"|"io"|"oi")    syslogin=1;syslogout=1;;
        esac
        ;;
    F) flush=1;;
    v) vflag=1;;
    ?)  echo "$0: -${OPTION}: invalid option"; exit 1 ;;
  esac
done
shift $(($OPTIND - 1))

FILE=${farg:="output.sh"}
CLIENT=${carg:="10.1.1.0/24"}
ROUTER=${rarg:="10.1.1.254"}
SERVER=${sarg:="10.9.9.1/24"}

echo '#/bin/bash' > "$FILE"

if [ ! -z "$flush" ]; then
  echo '# flush' >> "$FILE"
  echo "iptables -t nat -F" >> "$FILE"
  echo "iptables -F" >> "$FILE"
  printf "\n" >> "$FILE"
fi

echo '# abilito traffico interno' >> "$FILE"
echo 'iptables -I INPUT -i lo -j ACCEPT' >> "$FILE"
echo 'iptables -I OUTPUT -o lo -j ACCEPT' >> "$FILE"
printf "\n" >> "$FILE"

# vpn
if [ ! -z "$vflag" ]; then
  echo 'IPPUBVPN=$(ss -ntp | grep openvpn | awk'" '{ print"' $5 }'"'"' | cut -f1 -d:)' >> "$FILE"
  echo 'PORTPUBVPN=$(ss -ntp | grep openvpn | awk'" '{ print"' $5 }'"'"' | cut -f2 -d:)' >> "$FILE"
  echo 'IPPRIVATO=$(ip a | grep peer | awk -F'" 'peer ' '"'{ print $2 }'"'"'| cut -f1 -d/)' >> "$FILE"
  printf "\n" >> "$FILE"
  echo '# connessioni da macchina remota' >> "$FILE"
  echo 'iptables -I INPUT -s $IPPRIVATO -j ACCEPT' >> "$FILE"
  echo 'iptables -I OUTPUT -d $IPPRIVATO -j ACCEPT' >> "$FILE"
  echo 'iptables -I INPUT -p tcp -s $IPPUBVPN --sport $PORTPUBVPN -j ACCEPT' >> "$FILE"
  echo 'iptables -I OUTPUT -p tcp -d $IPPUBVPN --dport $PORTPUBVPN -j ACCEPT' >> "$FILE"
  printf "\n" >> "$FILE"
fi

# syslog (in)
if [[ ! -z "$syslogin" ]]; then
  echo '# regole syslog entrante' >> "$FILE"
  echo "iptables -I INPUT -p udp --dport 514 -s ${CLIENT} -d ${ROUTER} -i eth2 -j ACCEPT" >> "$FILE"
  printf "\n" >> "$FILE"
fi

# syslog (out)
if [[ ! -z "$syslogout" ]]; then
#  echo '# regole syslog uscente' >> "$FILE"
#  echo "iptables " >> "$FILE"
#  printf "\n" >> "$FILE"
fi

# regole ssh verso server
if [[ ! -z "$ssh" ]]; then
  echo '# regole ssh verso server' >> "$FILE"
  echo "iptables -I OUTPUT -m range --dst-range ${SERVER} -p tcp --dport 22 -j ACCEPT" >> "$FILE"
  echo "iptables -I INPUT -m range --src-range ${SERVER} -p tcp --sport 22 --state ESTABLISHED -j ACCEPT" >> "$FILE"
  printf "\n" >> "$FILE"
fi

if [[ ! -z "$snmp" ]]; then
  echo '# regole snmp verso server' >> "$FILE"
  echo "iptables -I OUTPUT -m range --dst-range ${SERVER} -p udp --dport 161 -j ACCEPT" >> "$FILE"
  echo "iptables -I INPUT -m range --src-range ${SERVER} -p udp --sport 161 --state ESTABLISHED -j ACCEPT" >> "$FILE"
  printf "\n" >> "$FILE"
fi

# regole ldap
if [[ ! -z "$ldap" ]]; then
  echo '# regole ldap da server' >> "$FILE"
  echo "iptables -I INPUT -m range --src-range ${SERVER} -p tcp --dport 389 -j ACCEPT" >> "$FILE"
  echo "iptables -I OUTPUT -m range --dst-range ${SERVER} -p tcp --sport 389 --state ESTABLISHED -j ACCEPT" >> "$FILE"
  printf "\n" >> "$FILE"
fi

# default
echo "# default deny" >> "$FILE"
echo "iptables -P INPUT DROP" >> "$FILE"
echo "iptables -P OUTPUT DROP" >> "$FILE"
echo "iptables -P FORWARD DROP" >> "$FILE"
