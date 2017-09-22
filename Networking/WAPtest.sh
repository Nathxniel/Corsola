#!/bin/sh

########################################################### 
#                                                         #
#                       WAPtest                           #
#                                                         #
#      creates WAP using supplied station and ap          #
#                      interfaces                         #
#                                                         #
########################################################### 

# dependancies:
#  - dhclient
#  - wpa_supplicant
#  - dhcpd
#  - hostapd

# kill processes invoked by WAPtest
stop() {
  if ! [ -z "$(ps -e | grep NetworkManager)" ]; then
    echo "Error: NetworkManager appears to be running"
    exit 1;
  fi
  echo "killing all processes"
  killall dhclient
  killall wpa_supplicant
  killall dhcpd
  killall hostapd
}


# show processes invoked by WAPtest
show() {
  echo "showing current processes"
  echo $(ps -e | grep dhclient)
  echo $(ps -e | grep wpa_supplicant)
  echo $(ps -e | grep dhcpd)
  echo $(ps -e | grep hostapd)
}

# help
usage() {
  echo "usage: "
  echo "call \"# ./WAPtest.sh start [station_int] [ap_int]\" to run"
  echo "call \"# ./WAPtest.sh stop\" to stop all processes"
  echo "call \"# ./WAPtest.sh show\" to show all processes"
  echo "call \"# ./WAPtest.sh help\" to show this help text"
}

case "$1" in
  show)
    show
    exit 0
    ;;
  stop)
    stop
    exit 0
    ;;
  start)
    ;;
  debug)
    # move this code block around if u need it lol
    #
    # if [ "$1" = 'debug' ]; then
    #   echo "!!!!!!!!!!!!STOPPING (debug)!!!!!!!!!!!!"
    #   exit 1;
    # fi
    ;;
  *)
    usage
    exit 1
    ;;
esac

# main functionality (start)
if [ -z $2 ] || [ -z $3 ]; then
  usage
  exit 1;
fi

station=$2
ap=$3

# Script to test wireless hotspot with internet access:
# TODO:
#   1 - finish this
#   2 - understand android phone architecture and OS
#   3 - test on android

# [ ] PRE: Wi-Fi Station and AP interfaces are available
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

# [ ] PRE: make sure ap interface has static ip
#  - /etc/network/interfaces
#     ...
#      auto wlan0_ap
#      iface wlan0_ap inet static
#        address ...
#        netmask ...
#      ...

# [ ] PRE: hostapd configuration file has been set
#  - /etc/hostapd/hostapd.conf
#     ...
#       ssid=...
#      ...

# [ ] PRE: dhcp server daemon configuration file has been set
#  - /etc/dhcp/dhcpd.conf
#     ...
#       authoritative;
#     ...
#       subnet ... {
#         ...
#         interface wlan0_ap;
#       }
#      ...

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
ip link set group default down
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  3 - bring the STATION interface to be used UP
ip link set $station up
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  4 - connect to wifi on STATION
#   4.1 - start dhcp client 
dhclient -d -v $station &
sleep 5
#   4.2 - start wpa_supplicant
wpa_supplicant -i$station -c/etc/wpa_supplicant/wpa_supplicant.conf -Dnl80211 &
sleep 5
#   4.3 - potentially manually write to resolv.conf 
#         (zeroConf mnds issues)
#         (TODO: generalise, current solution is hacky)
if [ -z "$(cat /etc/resolv.conf | grep "nameserver 8.8.8.8")" ]; then
  echo "nameserver 8.8.8.8" > /etc/resolv.conf
  echo "nameserver 8.8.4.4" >> /etc/resolv.conf
  echo "search lan" >> /etc/resolv.conf
fi
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
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
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  6 - allow ip forwarding
sysctl -w net.ipv4.ip_forward=1
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  7 - create ACCESS POINT
#   7.1 - start host access point daemon
hostapd /etc/hostapd/hostapd.conf &
sleep 5
#   7.2 - start dhcp server side daemon
#         (TODO: hostapd can up ap interface but 'ip' cant. why?)
dhcpd -d $ap &
sleep 5
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
