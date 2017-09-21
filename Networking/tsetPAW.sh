# WAPtest undo-er
# TODO: generalise

# down all wireless interfaces
ip link set wlp3s0_sta down
ip link set wlp3s0_ap down
ip link set wlp3s0 down

# up standard wireless interface
ip link set wlp3s0 up

# start network manager
service network-manager start
sleep 2
nmcli device status

