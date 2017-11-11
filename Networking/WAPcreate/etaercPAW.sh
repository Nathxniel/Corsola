# WAPcreate undo-er
# TODO: generalise

# delete all wireless interfaces
#   this is rude and unnecessary
if ! [ -z $1 ]; then
  iw dev wlp3s0_sta del
  iw dev wlp3s0_ap del;
else
  ip link set wlp3s0_sta down
  ip link set wlp3s0_ap down;
fi


# up standard wireless interface
ip link set wlp3s0 up

# revert network interfaces file
cat resources/defaultInterfaces > /etc/network/interfaces

# start network manager
service network-manager start
sleep 5
nmcli device status

