#!/bin/sh

########################################################### 
#                                                         #
#                       WAPtest                           #
#                                                         #
#      creates WAP using supplied station and ap          #
#                      interfaces                         #
#                                                         #
########################################################### 

# PROGRAM ARGS: 
#   $1 = STATION interface
#   $2 = ACCESS POINT interface

if [ -z $1 ] || [ -z $2 ]; then
  echo "# ./WAPtest.sh [station_int] [ap_int]"
  exit 1;
fi

station=$1
ap=$2

# Script to test wireless hotspot with internet access:
# TODO:
#   1 - finish this
#   2 - understand android phone architecture and OS
#   3 - test on android

# [1] PRE: Wi-Fi Station and AP interfaces are available
#  - software versions can be created using:
#  # iw dev wlan0 interface add wlan0_sta type managed
#  # iw dev wlan0 interface add wlan0_ap type managed

# [2] PRE: hostapd configuration file has been set
#  - /etc/hostapd/hostapd.conf
#  - DEBUG WITH -d (run in foreground)

# [3] PRE: dhcp daemon configuration file has been set
#  - /etc/dhcp/dhcpd.conf
#  - DEBUG WITH -d (run in foreground)

# [4] PRE: make sure ap interface has static ip
#  - /etc/network/interfaces
#  - make sure wlan0_ap has static ip: 
#     ...
#      auto wlan0_ap
#      iface wlan0_ap inet static
#        address 
#      ...
#  - make sure wlan0_sta has some Wi-Fi connectivity
#   (NOTE: this can (potentially) be acheived using ip commands)

# NOTE: this script is to be run as root (or using sudo)
#  $ sudo ./WAPtest.sh
#  or
#  # ./WAPtest.sh

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  1 - stop the network manager service
service network-manager stop
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  2 - bring DOWN all wireless interfaces
ip link set wlp3s0 down
ip link set $station down
ip link set $ap down
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  3 - bring the STATION interface to be used UP
ip link set $station up
sleep 2
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  4 - connect to wifi on STATION
#   TODO: resolve DNS issues 
#   (NOTE: default resolv.conf dnserver is 127.0.1.1 [Ubuntu Server])
#   4.1 - start dhcp client if not already running
if [ -z $(ps -e | grep dhclient) ]; then
  dhclient -d -v $station &
  sleep 2
fi
#   4.2 - start wpa_supplicant
wpa_supplicant -i$station -c/etc/wpa_supplicant/wpa_supplicant.conf -Dwext &
sleep 2
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  5 - start dhcp server side daemon
if [ -z $(ps -e | grep dhcpd) ]; then
  dhcpd -d $ap &
  sleep 2
fi
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  6 - create NAT rules
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
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  7 - allow ip forwarding
sysctl -w net.ipv4.ip_forward=1
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  8 - start access point
#   8.1 - start hostapd daemon
hostapd /etc/hostapd/hostapd.conf
#   8.2 - stop dhcpd (?)
killall dhcpd
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
