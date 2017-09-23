# WAPcreate undo-er
# TODO: generalise

# down all wireless interfaces
ip link set group default down

# up standard wireless interface
ip link set wlp3s0 up

# revert network interfaces file
cat defaultInterfaces > /etc/network/interfaces

# start network manager
service network-manager start
sleep 5
nmcli device status

