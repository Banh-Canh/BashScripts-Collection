#!/bin/bash


BASEDIR=$(dirname "$0")

trap exitscript INT

function exitscript()
{
	rm $BASEDIR/dhcpd.conf* 2> /dev/null
	echo -e "\n------------------------------------------------\n"
	echo "Good Bye !" 
	echo -e "\n------------------------------------------------\n"
	exit
}

# install dhcp

while [ "$installyesno" != yes ] && [ "$installyesno" != no ]
do
	echo -e "\n------------------------------------------------\n"
	read -p "Do you want to install or update ISC-DHCP-SERVER ? [yes] [no] " installyesno
	echo -e "\n------------------------------------------------\n"
done

if [ "$installyesno" == yes ]
then
	apt install -y isc-dhcp-server
	echo ""
elif [ "$installyesno" == no ]
then
	echo -e "\n------------------------------------------------\n"
	echo "ISC-DHCP-SERVER has not been installed or updated."
	echo -e "\n------------------------------------------------\n"
fi

# backup config dhcp

cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.old

while [ "$configyesno" != yes ] && [ "$configyesno" != no ]
do
	read -p "Do you want to configure your DHCP server ? [yes] [no] " configyesno
done

if [ "$configyesno" == yes ]
then
	
# Configure dhcp

	echo -e "#GENERAL\n\n" > $BASEDIR/dhcpd.conf_general.temp
	echo -e "#RANGE\n\n" > $BASEDIR/dhcpd.conf_range.temp
	echo -e "#IP RESERVATION\n\n" > $BASEDIR/dhcpd.conf_ipreserv.temp

	while [ 1 ]
	do

		echo -e "\n------------------------------------------------\n"
		echo "[general] [range] [reservation] [showconfigtoapply] [showcurrentconfig] [saveconfig] [exitconfig]"
		echo -e "\n------------------------------------------------\n"
		read -p "What do you want to configure ? " configpart
		echo -e "\n------------------------------------------------\n"
  
		case $configpart in
  
			general )

				read -p "Enter the domain name [name]: " domainname
				read -p "Enter the domain name server address [ex: 8.8.8.8, 8.8.4.4, ...] : " dnsip
				echo -e "option domain-name "\"$domainname"\";\noption domain-name-servers $dnsip;\ndefault-lease-time 600;\nmax-lease-time 7200;\nddns-update-style none;\nauthoritative;\n\n" >> $BASEDIR/dhcpd.conf_general.temp
				configpart=
			;;
	  

			range )

				while [ 1 ]
				do
					read -p "Do you want to add an IP range ? [yes] [no] " addrange
					case $addrange in	    
					
						yes )
							echo -e "\n------------------------------------------------\n"
							read -p "Enter the subnet's address [ex: 192.168.0.0] : " ipsubnet
							read -p "Enter the net's mask [ex: 255.255.255.0] : " ipnetmask
							read -p "Enter the subnet ip's range [ex: 192.168.0.10 192.168.0.100] : " rangeip
							read -p "Enter the gateway [ex: 192.168.0.1] : " gatewayip
							read -p "Enter the broadcast address [ex: 192.168.0.255] : " ipbroadcast
							read -p "Enter the subnet's mask [ex: 255.255.255.0] : " ipsubnetmask
							echo -e "subnet $ipsubnet netmask $ipnetmask {\n  range $rangeip;\n  option routers $gatewayip;\n  option broadcast-address $ipbroadcast;\n  option subnet-mask $ipsubnetmask;\n}\n\n" >> $BASEDIR/dhcpd.conf_range.temp
							echo -e "\n------------------------------------------------\n"
						;;
					
						no )
							break
						;;
					esac	
				done
				configpart=	  
			;;
		
			reservation )
			
			while [ "$reserveripyesno" != no ]
			do
				while [ "$reserveripyesno" != yes ] && [ "$reserveripyesno" != no ]
				do
					read -p "Do you want to continue and reserve an IP [yes] [non] ? " reserveripyesno
				done

				if [ "$reserveripyesno" == yes ]
				then
					echo -e "\n------------------------------------------------\n"
					read -p "Enter the host's name [ex: cli-ubuntu] : " namehost
					read -p "Enter the host's mac address [ex: 08:00:27:38:f9:37] : " macaddress
					read -p "Enter the reserved ip address [ex: 192.168.0.50] : " reservedip
					echo -e "\n------------------------------------------------\n"
					reserveripyesno=
					echo -e "host $namehost {\n  hardware ethernet $macaddress;\n  fixed-address $reservedip;\n}\n" >> $BASEDIR/dhcpd.conf_ipreserv.temp
				fi
			done
			configpart= 
			;;
			
			showcurrentconfig )	
				echo -e "\n----------- CURRENT CONFIG -------------------------------------\n"
				cat /etc/dhcp/dhcpd.conf
				echo -e "\n----------- CURRENT CONFIG -------------------------------------\n"
				configpart=		
			;;

			showconfigtoapply )	
				echo -e "\n----------- CONFIG TO APPLY -------------------------------------\n"
				cat $BASEDIR/dhcpd.conf_general.temp > $BASEDIR/dhcpd.conf.temp && cat $BASEDIR/dhcpd.conf_range.temp >> $BASEDIR/dhcpd.conf.temp && cat $BASEDIR/dhcpd.conf_ipreserv.temp >> $BASEDIR/dhcpd.conf.temp 2> /dev/null
				cat $BASEDIR/dhcpd.conf.temp
				echo -e "\n----------- CONFIG TO APPLY -------------------------------------\n"
				configpart=		
			;;
			
			saveconfig )
				cp $BASEDIR/dhcpd.conf.temp /etc/dhcp/dhcpd.conf && rm $BASEDIR/dhcpd.conf.temp
				systemctl restart isc-dhcp-server
				systemctl status isc-dhcp-server
				echo -e "\n------------------------------------------------\n"
				echo "Change saved !"
				echo -e "\n------------------------------------------------\n"
				configpart=
			;;
		  
			exitconfig )
			
				exitscript
				break
			;;
		esac
	done
	
elif [ "$configyesno" == no ]
then
	echo -e "\n------------------------------------------------\n"
	echo "ISC-DHCP-SERVER has not been configured."
	echo -e "\n------------------------------------------------\n"
fi