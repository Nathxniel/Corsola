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
#  - dhclient
#  - wpa_supplicant
#  - dhcpd
#  - hostapd
#  - nodogsplash

# kill processes invoked by WAPcreate
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
  killall nodogsplash
}


# show processes invoked by WAPcreate
show() {
  echo "showing current processes"
  echo $(ps -e | grep dhclient)
  echo $(ps -e | grep wpa_supplicant)
  echo $(ps -e | grep dhcpd)
  echo $(ps -e | grep hostapd)
  echo $(ps -e | grep nodogsplash)
}

# help
usage() {
  echo "usage: "
  echo "call \"# ./WAPcreate.sh start [station_int] [ap_int]\" to run"
  echo "call \"# ./WAPcreate.sh init [wireless int]\" to create soft ifaces"
  echo "call \"# ./WAPcreate.sh stop\" to stop all processes"
  echo "call \"# ./WAPcreate.sh show\" to show all processes"
  echo "call \"# ./WAPcreate.sh help\" to show this help text"
}

# update resolv.conf
refreshDNS() {
  if [ -z "$(cat /etc/resolv.conf | grep "nameserver 8.8.8.8")" ]; then
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf
    echo "search lan" >> /etc/resolv.conf
  fi
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
  init)
    if [ -z $2 ]; then
      usage
      exit 1;
    fi
    wirelesscard=$2

    # software interfaces (manual instructions shown below)
    iw dev $wirelesscard interface add "$wirelesscard"_sta type managed
    iw dev $wirelesscard interface add "$wirelesscard"_ap type managed
    exit 0
    ;;
  refresh)
    refreshDNS
    exit 0
    ;;
  debug)
    # move this code block around if u need it lol
    #
    # if [ "$1" = 'debug' ]; then
    #   echo "!!!!!!!!!!!!STOPPING (debug)!!!!!!!!!!!!"
    #   exit 1;
    # fi
    ;;
  start)
    ;;
  *)
    usage
    exit 1
    ;;
esac

# Script to start wireless hotspot with internet access:

if [ -z $2 ] || [ -z $3 ]; then
  usage
  exit 1;
fi

station=$2
ap=$3

# [ ] PRE: Wi-Fi Station and AP interfaces are available
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

# [ ] PRE: supersede dns in dhclient
#  - /etc/dhcp/dhclient.conf
#     ...
#       #supersede domain-name "fugue.com ...
#       supersede domain-name-servers 127.0.0.1, 8.8.8.8;
#       #require ...
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

# [ ] PRE: nodogsplash is installed and config is set
#  - /etc/nodogsplash/nodogsplash.conf
#   (see file, it has instructions)

# NOTE: this script is to be run as root (or using sudo)
#  $ sudo ./WAPcreate.sh
#  or
#  # ./WAPcreate.sh

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  1 - stop the network manager service
service network-manager stop
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
cat ./defaultInterfaces > /etc/network/interfaces
echo >> /etc/network/interfaces
echo "# static access point address (by WAPcreate)" \
  >> /etc/network/interfaces
echo "auto $ap" >> /etc/network/interfaces
echo "iface $ap inet static" >> /etc/network/interfaces
echo "  address 10.0.10.1" >> /etc/network/interfaces
echo "  netmask 255.255.255.0" >> /etc/network/interfaces
#   3.2 - restart networking
service networking restart
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#  4 - connect to wifi on STATION
#   4.1 - start dhcp client 
dhclient -d -v $station &
sleep 5
#   4.2 - start wpa_supplicant
wpa_supplicant -i$station -c/etc/wpa_supplicant/wpa_supplicant.conf &
sleep 5
#   4.3 - potentially manually write to resolv.conf 
#         (zeroConf mnds issues; resolv.conf is not written to)
#         (TODO: create service, current solution is hacky)
refreshDNS
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
hostapd /etc/hostapd/hostapd.conf &
sleep 5
ip link show up
#   7.2 - start dhcp server side daemon
dhcpd -d $ap &
sleep 5
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# 8 - start nodogsplash
nodogsplash
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
