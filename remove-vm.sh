#!/bin/bash

WIN_HOME=~
vboxifname="VirtualBox Host-Only Ethernet Adapter"
vmname="default"

SOURCE=`dirname "$0"`

source $SOURCE/vbox-utils.sh

echo "[Remove vm $vmname from docker...]"

docker-machine rm default -y > /dev/null 2>&1

echo "[Remove vm $vmname from vbox & vagrant...]"

#vm_delete default
vagrant destroy --force

echo "[Remove hostonly interface & DHCP server...]"

vboxmanage dhcpserver remove --netname "HostInterfaceNetworking-${vboxifname}" 2>/dev/null
vboxmanage hostonlyif remove "$vboxifname" 2>/dev/null

rm -f "$WIN_HOME/.VirtualBox/HostInterfaceNetworking-${vboxifname}-Dhcpd.leases"

echo "[Recreate hostonly interface & DHCP server...]"

vboxmanage hostonlyif create > /dev/null 2>&1 && vboxmanage hostonlyif ipconfig "$vboxifname" --ip 192.168.99.23 --netmask 255.255.255.0
vboxmanage dhcpserver add --interface="$vboxifname" --enable --ip 192.168.99.254 --netmask 255.255.255.0 --lowerip 192.168.99.100 --upperip 192.168.99.199

