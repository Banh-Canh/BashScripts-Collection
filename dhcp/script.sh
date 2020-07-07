#!/bin/bash


BASEDIR=$(dirname "$0")

# install dhcp

apt install -y isc-dhcp-server

# backup config dhcp

cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.old

while [ "$configyesno" != oui ] && [ "$configyesno" != non ]
  do
	read -p "Souhaitez-vous configurer le serveur dhcp [oui ou non] : " configyesno
  done

if [ "$configyesno" == oui ]
then

# Configure dhcp

  while [ 1 ]
  do

  while [ "$configpart" != general ] && [ "$configpart" != range ] && [ "$configpart" != reservation ] && [ "$configpart" != showconfig ] && [ "$configpart" != saveconfig ] && [ "$configpart" != exitconfig ]
  do
    echo -e "\n------------------------------------------------\n"
    echo "[general] [range] [reservation] [showconfig] [saveconfig] [exitconfig]"
	echo -e "\n------------------------------------------------\n"
	read -p "Quel partie souhaitez-vous configurer ? " configpart
	echo -e "\n------------------------------------------------\n"
  done
  

   
  case $configpart in
  
    general )

	echo -e "#PARAMETRE GENERAUX\n\n" > $BASEDIR/dhcpd.conf_general.temp
	
	read -p "Entrez le nom du domaine [nom]: " domainname
	read -p "Entrez les DNS [IP, IP2] : " dnsip
	echo -e "option domain-name "\"$domainname"\";\noption domain-name-servers $dnsip;\ndefault-lease-time 600;\nmax-lease-time 7200;\nddns-update-style none;\nauthoritative;\n\n" >> $BASEDIR/dhcpd.conf_general.temp
  
    configpart=
	
    ;;
  
##########################################################

    range )

	echo -e "#PARAMETRE RANGE\n\n" > $BASEDIR/dhcpd.conf_range.temp
	
		while [ 1 ]
	      do
		  read -p "Souhaitez-vous ajouter une range ? [oui ou non] " addrange
		  case $addrange in	    
			
			oui )
			    echo -e "\n------------------------------------------------\n"
				read -p "Entrez l'ip du sous-réseau [ex: 192.168.0.0] : " ipsubnet
				read -p "Entrez le masque du réseau [ex: 255.255.255.0] : " ipnetmask
				read -p "Entrez la range d'IP [IP IP2] : " rangeip
				read -p "Entrez l'adresse de la passerelle [IP] : " gatewayip
				read -p "Entrez l'adresse broadcast [IP] : " ipbroadcast
				read -p "Entrez le masque du sous-réseau [ex: 255.255.255.0] : " ipsubnetmask
				echo -e "subnet $ipsubnet netmask $ipnetmask {\n  range $rangeip;\n  option routers $gatewayip;\n  option broadcast-address $ipbroadcast;\n  option subnet-mask $ipsubnetmask;\n}\n\n" >> $BASEDIR/dhcpd.conf_range.temp
				echo -e "\n------------------------------------------------\n"
			;;
			
			non )
			break;;
		  esac	
		  done

	  configpart=
	  
	  ;;

############################################################
	
	reservation )
	
	echo -e "#RESERVATION IPs\n\n" > $BASEDIR/dhcpd.conf_ipreserv.temp

	while [ "$reserveripyesno" != non ]
	  do
		while [ "$reserveripyesno" != oui ] && [ "$reserveripyesno" != non ]
		  do
			read -p "Souhaitez-vous continuer et réserver une IP [oui ou non] ? " reserveripyesno
		  done

		if [ "$reserveripyesno" == oui ]
		then
		  echo -e "\n------------------------------------------------\n"
		  read -p "Indiquez un nom d'hôte [ex: cli-ubuntu] " namehost
		  read -p "Indiquez son adresse MAC [ex: 08:00:27:38:f9:37] " macaddress
		  read -p "Indiquez l'adresse IP à réserver [IP] " reservedip
		  echo -e "\n------------------------------------------------\n"
		  reserveripyesno=
		  echo -e "host $namehost {\n  hardware ethernet $macaddress;\n  fixed-address $reservedip;\n}\n" >> $BASEDIR/dhcpd.conf_ipreserv.temp
		fi
	  done
	  configpart=
	  
	;;
	
##############################################################

    showconfig )
	
		echo -e "\n------------------------------------------------\n"
		cat $BASEDIR/dhcpd.conf_general.temp > $BASEDIR/dhcpd.conf.temp && cat $BASEDIR/dhcpd.conf_range.temp >> $BASEDIR/dhcpd.conf.temp && cat $BASEDIR/dhcpd.conf_ipreserv.temp >> $BASEDIR/dhcpd.conf.temp
		cat $BASEDIR/dhcpd.conf.temp
		echo -e "\n------------------------------------------------\n"
		configpart=
		
	;;
		
##############################################################
    
	saveconfig )
	
	  cp $BASEDIR/dhcpd.conf.temp /etc/dhcp/dhcpd.conf && rm $BASEDIR/dhcpd.conf.temp
	  systemctl restart isc-dhcp-server
	  systemctl status isc-dhcp-server
	  echo "Changements sauvegardés !"
	  configpart=
	  
	  ;;
	  
#############################################################
	  
	exitconfig )
	
	  if [ -f "$BASEDIR/dhcpd.conf.temp" ]
	  then
	    rm $BASEDIR/dhcpd.conf.temp
	  fi
	  echo "Au revoir !" 
	
	break;;

###########################################################
	
  esac
  done
  
elif [ "$configyesno" == non ]
then
	echo "DHCP installé mais non configuré (par défaut)"
fi