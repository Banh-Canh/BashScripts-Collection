#!/bin/bash

BASEDIR=$(dirname "$0")

ethernetdone=no
wifidone=no

echo "Configuration NETPLAN"
echo -e "# Let NetworkManager manage all devices on this system\n\nnetwork:\n\n  version: 2\n  renderer: NetworkManager\n" > $BASEDIR/netplan.temp

while [ "$ethornot" != oui ] && [ "$ethornot" != non ]
  do
    read -p "Souhaitez-vous configurer une interface ethernet [oui ou non] ? " ethornot
  done
  if [ "$ethornot" == oui ]
  then
    echo -e "  ethernets:\n" >> $BASEDIR/netplan.temp
    while [ "$ethernetdone" == no ]
	  do
		read -p "Quel est le nom de la carte réseau à configurer [ex: enp0s3] : " ethernetcard
		while [ "$staticordhcp" != static ] && [ "$staticordhcp" != dhcp ]
		  do
			read -p "Souhaitez-vous configurer une ip statique [static] ou dynamique [dhcp] ? " staticordhcp
		  done
		if [ "$staticordhcp" == static ]
		then
		  read -p "Entrez l'adresse IP [IP] : " staticip
		  read -p "Entrez le masque [IP] : " masque
		  read -p "Entrez la passerelle [IP] : " gatewayip
		  read -p "Entrez les DNS [IP, IP2]: " dnsips
		  echo -e "    $ethernetcard:\n      dhcp4: false\n      addresses: [$staticip/$masque]\n      gateway4: $gatewayip\n      nameservers:\n        addresses:\n          [$dnsips]\n" >> $BASEDIR/netplan.temp
		  echo " Ethernet $ethernetcard configuré !"
		elif [ "$staticordhcp" == dhcp ]
		then
		  echo -e "    $ethernetcard:\n      dhcp4: true\n" >> $BASEDIR/netplan.temp
		  echo " Ethernet $ethernetcard configuré !"
		fi
		while [ "$addeth" != oui ] && [ "$addeth" != non ]
		  do
			read -p "Souhaitez-vous configurer une autre interface ethernet ? [oui ou non] " addeth 
		  done
		if [ "$addeth" == non ]
		then
		  ethernetdone=oui
		fi
		staticordhcp=
		addeth=
	  done
  elif [ "$ethornot" == non ]
  then
    echo "!!!! Ethernet non configuré !!!!"
  fi

while [ "$wifiornot" != oui ] && [ "$wifiornot" != non ]
  do
    read -p "Souhaitez-vous configurer une interface wifi [oui ou non] ? " wifiornot
  done
  if [ "$wifiornot" == oui ]
  then
    echo -e "  wifis:\n" >> $BASEDIR/netplan.temp
	while [ "$wifidone" == no ]
	  do
		read -p "Quel est le nom de la carte réseau à configurer [ex: enp0s3] : " wificard
		while [ "$staticordhcp" != static ] && [ "$staticordhcp" != dhcp ]
		  do
			read -p "Souhaitez-vous configurer une ip statique [static] ou dynamique [dhcp] ? " staticordhcp
		  done
		if [ "$staticordhcp" == static ]
		then
		  read -p "Entrez l'adresse IP [IP] : " staticip
		  read -p "Entrez le masque [IP] : " masque
		  read -p "Entrez la passerelle [IP] : " gatewayip
		  read -p "Entrez les DNS [IP, IP2]: " dnsips
		  read -p "Entrez le SSID : " SSIDwifi
		  read -p "Entrez le mot de passe du Wifi : " mdpwifi
		  echo -e "    $wificard:\n      dhcp4: false\n      addresses: [$staticip/$masque]\n      gateway4: $gatewayip\n      nameservers:\n        addresses:\n          [$dnsips]\n      access-points:\n        "\"$SSIDwifi"\":\n         password: "\"$mdpwifi"\"\n" >> $BASEDIR/netplan.temp
		  echo " Wifi $wificard configuré !"
		elif [ "$staticordhcp" == dhcp ]
		then
		  read -p "Entrez le SSID : " SSIDwifi
		  read -p "Entrez le mot de passe du Wifi : " mdpwifi
		  echo -e "    $wificard:\n      dhcp4: true\n      access-points:\n        "\"$SSIDwifi"\":\n         password: "\"$mdpwifi"\"\n" >> $BASEDIR/netplan.temp
		  echo " Wifi $wificard configuré !"
		fi
		while [ "$addwifi" != oui ] && [ "$addwifi" != non ]
		  do
			read -p "Souhaitez-vous configurer une autre interface wifi ? [oui ou non] " addwifi 
		  done
		if [ "$addwifi" == non ]
		then
		  wifidone=oui
		fi
		staticordhcp=
		addwifi=
	  done  
  elif [ "$wifiornot" == non ]
  then
    echo "!!!! Wifi non configuré !!!!"
  fi
  
while [ "$confirmchange" != oui ] && [ "$confirmchange" != non ]
  do
    echo -e "\n------------------------------------------------\n"
    cat $BASEDIR/netplan.temp
	echo -e "\n------------------------------------------------\n"
	read -p "Configuration du netplan terminé, souhaitez-vous appliquer les changements ? [oui ou non] " confirmchange
  done
if [ "$confirmchange" == oui ]
then
  cp $BASEDIR/netplan.temp /etc/netplan/0*-network-manager* && rm $BASEDIR/netplan.temp
  netplan apply
  echo "Changements sauvegardés !"
else
  rm $BASEDIR/netplan.temp
  echo "Changements non-sauvegardés !"
fi
