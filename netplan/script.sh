#!/bin/bash

BASEDIR=$(dirname "$0")

function exitscript()
{
	rm $BASEDIR/netplan.temp* 2> /dev/null
	echo -e "\n------------------------------------------------\n"
	echo "Good Bye !" 
	echo -e "\n------------------------------------------------\n"
	exit
}

trap exitscript INT

ethernetdone=no
wifidone=no

echo "Configuration NETPLAN"
echo -e "# Let NetworkManager manage all devices on this system\n\nnetwork:\n\n  version: 2\n  renderer: NetworkManager\n" > $BASEDIR/netplan.temp

while [ "$ethornot" != yes ] && [ "$ethornot" != no ]
do
	read -p "Do you want to configure an ethernet interface [yes] [no] ? " ethornot
done
if [ "$ethornot" == yes ]
then
	echo -e "  ethernets:\n" >> $BASEDIR/netplan.temp
    while [ "$ethernetdone" == no ]
	do
		read -p "Ethernet interface's name [ex: enp0s3] : " ethernetcard
		while [ "$staticordhcp" != static ] && [ "$staticordhcp" != dhcp ]
		do
			read -p "Static [static] or dynamic [dhcp] IP ? " staticordhcp
		done
		if [ "$staticordhcp" == static ]
		then
			read -p "IP address [ex: 192.168.0.50] : " staticip
			read -p "Mask [ex: 24] : " masque
			read -p "Gateway [ex: 192.168.0.1] : " gatewayip
			read -p "DNS [8.8.8.8, 8.8.4.4, etc...]: " dnsips
			echo -e "    $ethernetcard:\n      dhcp4: false\n      addresses: [$staticip/$masque]\n      gateway4: $gatewayip\n      nameservers:\n        addresses:\n          [$dnsips]\n" >> $BASEDIR/netplan.temp
			echo " Ethernet $ethernetcard configured !"
		elif [ "$staticordhcp" == dhcp ]
		then
			echo -e "    $ethernetcard:\n      dhcp4: true\n" >> $BASEDIR/netplan.temp
			echo " Ethernet $ethernetcard configured !"
		fi
		while [ "$addeth" != yes ] && [ "$addeth" != no ]
		do
			read -p "Configure another ethernet interface ? [yes] [no] " addeth 
		done
		if [ "$addeth" == no ]
		then
			ethernetdone=yes
		fi
		staticordhcp=
		addeth=
	done
elif [ "$ethornot" == no ]
then
	echo "!!!! Ethernet interfaces not configured !!!!"
fi

while [ "$wifiornot" != yes ] && [ "$wifiornot" != no ]
do
	read -p "Configure wifi interface [yes] [no] ? " wifiornot
done
if [ "$wifiornot" == yes ]
then
    echo -e "  wifis:\n" >> $BASEDIR/netplan.temp
	while [ "$wifidone" == no ]
	do
		read -p "Wifi interface's name [ex: enp0s3] : " wificard
		while [ "$staticordhcp" != static ] && [ "$staticordhcp" != dhcp ]
		do
			read -p "Static [static] or dynamic [dhcp] IP ? " staticordhcp
		done
		if [ "$staticordhcp" == static ]
		then
			read -p "IP address [ex: 192.168.0.50] : " staticip
			read -p "Mask [ex: 24] : " masque
			read -p "Gateway [ex: 192.168.0.1] : " gatewayip
			read -p "DNS [8.8.8.8, 8.8.4.4, etc...]: " dnsips
			read -p "SSID : " SSIDwifi
			read -p "Password : " mdpwifi
			echo -e "    $wificard:\n      dhcp4: false\n      addresses: [$staticip/$masque]\n      gateway4: $gatewayip\n      nameservers:\n        addresses:\n          [$dnsips]\n      access-points:\n        "\"$SSIDwifi"\":\n         password: "\"$mdpwifi"\"\n" >> $BASEDIR/netplan.temp
			echo " Wifi $wificard configured !"
		elif [ "$staticordhcp" == dhcp ]
		then
			read -p "SSID : " SSIDwifi
			read -p "Password : " mdpwifi
			echo -e "    $wificard:\n      dhcp4: true\n      access-points:\n        "\"$SSIDwifi"\":\n         password: "\"$mdpwifi"\"\n" >> $BASEDIR/netplan.temp
			echo " Wifi $wificard configured !"
		fi
		while [ "$addwifi" != yes ] && [ "$addwifi" != no ]
		do
			read -p "Configure another wifi interface ? [yes] [no] " addwifi 
		done
		if [ "$addwifi" == no ]
		then
			wifidone=yes
		fi
		staticordhcp=
		addwifi=
	done  
elif [ "$wifiornot" == no ]
then
    echo "!!!! Wifi no configuré !!!!"
fi
  
while [ "$confirmchange" != yes ] && [ "$confirmchange" != no ]
do
    echo -e "\n------------------------------------------------\n"
    cat $BASEDIR/netplan.temp
	echo -e "\n------------------------------------------------\n"
	read -p "Apply changes ? [yes] [no] " confirmchange
done

if [ "$confirmchange" == yes ]
then
	cp $BASEDIR/netplan.temp /etc/netplan/0*-network-manager* && rm $BASEDIR/netplan.temp 2> /dev/null
	netplan apply
	echo "Changes saved !"
else
	rm $BASEDIR/netplan.temp 2> /dev/null
	echo "Changes not saved !"
fi
