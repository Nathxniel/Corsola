#!/bin/sh

########################################################### 
#                                                         #
#                       WAPcreate                         #
#                                                         #
#      creates WAP using supplied station and ap          #
#                      interfaces                         #
#                                                         #
########################################################### 

# dependancies:
#  - dhclient; Dynamic Host Configuration Protocol Client
#  - wpa_supplicant; Wi-Fi PA client and IEEE 802.1X supplicant
#  - dnsmasq; DHCP and chaching DNS server
#  - hostapd; IEEE 802.1X authenticator and Access Point
#  - nodogsplash; Wi-Fi access point captive portal

# notes:
#  - configured around to run around NetworkManager
#  - if another network manager is used, vital processes may be killed


# kill processes invoked by WAPcreate
stop() {
  if ! [ -z "$(ps -e | grep NetworkManager)" ]; then
    1>&2 echo "Error: NetworkManager appears to be running"
    exit 1;
  fi
  if ! [ -z "$(ps -e | grep Wicd)" ]; then
    1>&2 echo "Error: Wicd appears to be running"
    exit 1;
  fi
  echo "killing all processes"
  >/dev/null killall dnsmasq
  >/dev/null killall dhclient
  >/dev/null killall wpa_supplicant
  >/dev/null killall hostapd
  >/dev/null killall nodogsplash
}

# show processes invoked by WAPcreate
show() {
  if ! [ -z "$(ps -e | grep NetworkManager)" ]; then
    1>&2 echo "NOTE: NetworkManager is running\n"
  fi
  if ! [ -z "$(ps -e | grep Wicd)" ]; then
    1>&2 echo "NOTE: Wicd is running"
  fi

  echo "Showing current procceses:"
  for proc in dnsmasq dhclient wpa_supplicant hostapd nodogsplash; do
    printline=$(ps -e | grep $proc)
    if [ -z "$printline" ]; then
      echo $proc is not running; else echo $printline; 
    fi
  done
}

# help
usage() {
  1>&2 echo "usage: "
  1>&2 echo "call \"# ./WAPcreate.sh start [station_int] [ap_int]\" to run"
  1>&2 echo "call \"# ./WAPcreate.sh init [wireless int]\" to create soft ifaces"
  1>&2 echo "call \"# ./WAPcreate.sh stop\" to stop all processes"
  1>&2 echo "call \"# ./WAPcreate.sh show\" to show all processes"
  1>&2 echo "call \"# ./WAPcreate.sh help\" to show this help text"
}

# update resolv.conf
# TODO: make redundant
refreshDNS() {
  #if [ -z "$(cat /etc/resolv.conf | grep "nameserver 8.8.8.8")" ]; 
  #then
  #  echo "nameserver 8.8.8.8" > /etc/resolv.conf
  #  echo "nameserver 8.8.4.4" >> /etc/resolv.conf
  #  echo "search lan" >> /etc/resolv.conf
  #fi
  echo "search fuck.me" > /etc/resolv.conf
  echo "nameserver 10.0.10.1" >> /etc/resolv.conf
  echo "nameserver 8.8.8.8" >> /etc/resolv.conf
}

init() {
    if [ -z $1 ]; then
      usage
      exit 1;
    fi
    wirelesscard=$1

    # software interfaces (manual instructions shown below)
    iw dev $wirelesscard interface add \
      "$wirelesscard"_sta type managed
    iw dev $wirelesscard interface add \
      "$wirelesscard"_ap type managed

    ip link show
}

case "$1" in
  init)
    init $2
    exit 0
    ;;
  show)
    show
    exit 0
    ;;
  stop)
    stop
    exit 0
    ;;
  #TODO: make redundant
  refresh)
    refreshDNS
    exit 0
    ;;
  start)
    ;;
  *)
    usage
    exit 1
    ;;
esac

# Script to start wireless hotspot with internet access:

if [ -z $2 ]; then
  usage
  exit 1;
fi

station=
ap=
minfaces=3

if [ -z $3 ]; then
  if [ $(ip link show | grep -c $2) -lt $minfaces ]; then init $2; fi
  station=$2_sta
  ap=$2_ap
else
  station=$2
  ap=$3;
fi

echo "STATION = $station"
echo "AP      = $ap"

# [ ] PRE: NetworkManager has been stopped
#  - or any other network manager (e.g. Wicd)

# [X] PRE: Wi-Fi Station and AP interfaces are available
#  - (use ./WAPcreate init)
#  - software versions can be created using:
#     # iw dev wlan0 interface add wlan0_sta type managed
#     # iw dev wlan0 interface add wlan0_ap type managed

# [ ] PRE: make sure wlan0_sta has Wi-Fi connectivity set
#  - /etc/wpa_supplicant/wpa_supplicant.conf
#     ...
#       network={
#         ...
#       }
#      ...

# [X] PRE: supersede dns in dhclient
#  - /etc/dhcp/dhclient.conf
#     ...
#       #supersede domain-name "fugue.com ...
#       supersede domain-name-servers 127.0.0.1, 8.8.8.8;
#       #require ...
#      ...

# [ ] PRE: nodogsplash is installed and config is set
#  - /etc/nodogsplash/nodogsplash.conf
#   (see file, it has instructions)

# NOTE: this script is to be run as root (or using sudo)
#  $ sudo ./WAPcreate.sh
#  or
#  # ./WAPcreate.sh

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  1 - stop the network manager service
systemctl stop network-manager.service
>/dev/null stop
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  2 - configure network devices
#   2.1 - bring DOWN all wireless interfaces
ip link set group default down
#   2.2 - bring the STATION interface to be used UP
ip link set $station up
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  3 - give access point static ip
#   3.1 - edit /etc/network/interfaces
cat ./resources/defaultInterfaces > /etc/network/interfaces
echo >> /etc/network/interfaces
echo "# static access point address (by WAPcreate)" \
                               >> /etc/network/interfaces
echo "auto $ap"                >> /etc/network/interfaces
echo "iface $ap inet static"   >> /etc/network/interfaces
echo "  address 10.0.10.1"     >> /etc/network/interfaces
echo "  netmask 255.255.255.0" >> /etc/network/interfaces

## dns - test to see if manually adding our server works
#echo ""                            >> /etc/network/interfaces
#echo "auto $station"               >> /etc/network/interfaces
#echo "iface $station inet dhcp"    >> /etc/network/interfaces
#echo "  dns-nameservers 127.0.0.1" >> /etc/network/interfaces

#   3.2 - restart networking (sometimes necessary)
systemctl restart networking.service
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  4 - connect to wifi on STATION
#   4.1 - start dhcp client 
dhclient -d -v -cf "./conf/dhclient.conf" $station &
sleep 5
#   4.2 - start wpa_supplicant
wpa_supplicant -i$station -c/etc/wpa_supplicant/wpa_supplicant.conf &
sleep 5
# TODO (CURRENTLY): 
# - im writing to resolv.conf to use my nameserver as a client
# - this is potentially un-needed
#   4.3 - potentially manually write to resolv.conf 
#refreshDNS
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  5 - create NAT rules
#   -F : flush
#   -t : table
#   -X : delete-chain
#   -A : append
#   -o : out-interface
#   -i : in-interface
iptables -F
iptables -t nat -F
iptables -X
iptables -t nat -X
iptables -t nat -A POSTROUTING -o $station -j MASQUERADE
iptables -A FORWARD -i $ap -j ACCEPT
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  6 - allow ip forwarding
sysctl -w net.ipv4.ip_forward=1
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  7 - create ACCESS POINT
#   7.1 - start host access point daemon
hostapd ./conf/hostapd.conf &
sleep 5
ip link show up
#   7.2 - start dns server and dhcp server
dnsmasq -d --conf-file="./conf/dnsmasq.conf" \
  --pid-file="./resources/dnsmasq.pid" &
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# 8 - start nodogsplash
#nodogsplash
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# 9 - fucking around
echo "!!!!!!!!!!!!!!THIS IS THE NAMED SECTION!!!!!!!!!!!!!!"
systemctl restart bind9.service
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
