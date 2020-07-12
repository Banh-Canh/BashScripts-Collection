#!/bin/bash

BASEDIR=$(dirname "$0")

function exitscript()
{
	rm $BASEDIR/squid.conf* 2> /dev/null
	echo -e "\n------------------------------------------------\n"
	echo "Good Bye !" 
	echo -e "\n------------------------------------------------\n"
	exit
}

trap exitscript INT

# install squid

while [ "$installyesno" != yes ] && [ "$installyesno" != no ]
do
	echo -e "\n------------------------------------------------\n"
	read -p "Do you want to install or update squid proxy server ? [yes] [no] " installyesno
	echo -e "\n------------------------------------------------\n"
done

if [ "$installyesno" == yes ]
then
	apt install -y squid
	echo ""
elif [ "$installyesno" == no ]
then
	echo -e "\n------------------------------------------------\n"
	echo "Squid has not been installed or updated."
	echo -e "\n------------------------------------------------\n"
fi

# backup config squid

cp /etc/squid/squid.conf /etc/squid/squid.conf.old

while [ "$configyesno" != yes ] && [ "$configyesno" != no ]
do
	read -p "Do you want to configure Squid [yes] [no] ? " configyesno
done

if [ "$configyesno" == yes ]
then

	echo -e "\n\n#AUTHENTICATION\n\n" > $BASEDIR/squid.conf_authtitle.temp
	echo -e "\n\n#ACL\n\n" > $BASEDIR/squid.conf_acltitle.temp
	echo -e "\n\n#HTTPACCESS\n\n" > $BASEDIR/squid.conf_httpaccesstitle.temp
	echo -e "acl localnet src 0.0.0.1-0.255.255.255    # RFC 1122 "\"this"\" network (LAN)\nacl localnet src 10.0.0.0/8        # RFC 1918 local private network (LAN)\nacl localnet src 100.64.0.0/10        # RFC 6598 shared address space (CGN)\nacl localnet src 169.254.0.0/16     # RFC 3927 link-local (directly plugged) machines\nacl localnet src 172.16.0.0/12        # RFC 1918 local private network (LAN)\nacl localnet src 192.168.0.0/16        # RFC 1918 local private network (LAN)\nacl localnet src fc00::/7           # RFC 4193 local private network range\nacl localnet src fe80::/10          # RFC 4291 link-local (directly plugged) machines\nacl SSL_ports port 443\nacl Safe_ports port 80        # http\nacl Safe_ports port 21        # ftp\nacl Safe_ports port 443        # https\nacl Safe_ports port 70        # gopher\nacl Safe_ports port 210        # wais\nacl Safe_ports port 1025-65535    # unregistered ports\nacl Safe_ports port 280        # http-mgmt\nacl Safe_ports port 488        # gss-http\nacl Safe_ports port 591        # filemaker\nacl Safe_ports port 777        # multiling http\nacl CONNECT method CONNECT\n" > $BASEDIR/squid.conf_acldefault.temp
	echo -e "http_access deny !Safe_ports\nhttp_access deny CONNECT !SSL_ports\nhttp_access allow localhost manager\nhttp_access deny manager\ninclude /etc/squid/conf.d/*\nhttp_access allow localhost\nhttp_access deny all\n" > $BASEDIR/squid.conf_httpaccessdefault.temp
	echo "http_port 3128" >> $BASEDIR/squid.conf_httpaccessdefault.temp

# Configure Squid

	while [ 1 ]
	do

		echo -e "\n------------------------------------------------\n"
		echo "[acl] [httpaccess] [showconfigtoapply] [showcurrentconfig] [saveconfig] [exitconfig]"
		echo -e "\n------------------------------------------------\n"
		read -p "What do you want to configure ? " configpart
		echo -e "\n------------------------------------------------\n"
  
		case $configpart in
  
			acl )
	 
				while [ 1 ]
				do
					read -p "Do you want to add an ACL ? [yes] [no] " addacl
					case $addacl in        
            
						yes )
						
							echo -e "\n------------------------------------------------\n"
							read -p "Enter parameter 1 [ex : toto] : " param1
							read -p "Entrez parameter 2 [ex : browser, proxy_auth, dstdomain etc..] : " param2 
							if [ "$param2" == "proxy_auth" ]
							then
								while [ 1 ]
								do
									read -p "You entered an authentication parameter, do you want to install and configure a basic authentication system (apache2-utils) ? " configauthyesno
									case $configauthyesno in  
									
										yes )
											apt install apache2-utils -y
											echo ""
											read -p "Path to the folder where the password file will be stored : " apachmdpfolder
											echo -e "auth_param basic program /usr/lib/squid3/basic_ncsa_auth $apachmdpfolder/password" >> $BASEDIR/squid.conf_auth.temp
											mkdir -p $apachmdpfolder && touch $apachmdpfolder/password
											param3="$apachmdpfolder/password"
											break
										;;
					
										no )
											break
										;;
					
										* )
										;;
					
									esac
								done
				  
							else
								read -p "Enter parameter 3 [ex (if param2 = browser): Firefox] : " param3 
							fi
							echo -e "acl $param1 $param2 $param3" >> $BASEDIR/squid.conf_acl.temp
						;;
            
						no )			
							break
						;;
					esac    
				done	
				configpart=
			;;
  
			httpaccess )

			while [ 1 ]
			do
				read -p "Do you want to add a httpaccess rule ? [yes] [no] " addhttpaccess
				case $addhttpaccess in	    
					
					yes )
					
						read -p "Allow [allow] or Deny [deny]: " allowordeny
						read -p "What ACLs should follow this rule ? [ex: name1 !name2 name3] : " aclparam_vic
				
						echo -e "http_access $allowordeny $aclparam_vic" >> $BASEDIR/squid.conf_httpaccess.temp
						
					;;
					
					no )
						break
					;;
					
					* )
					;;
				esac	
			done
			configpart=
			
			;;

			showconfigtoapply )
	
				echo -e "\n------------------------------------------------\n"
				cat $BASEDIR/squid.conf_authtitle.temp > $BASEDIR/squid.conf.temp 
				cat $BASEDIR/squid.conf_auth.temp >> $BASEDIR/squid.conf.temp 
				
				cat $BASEDIR/squid.conf_acltitle.temp >> $BASEDIR/squid.conf.temp
				cat $BASEDIR/squid.conf_acldefault.temp >> $BASEDIR/squid.conf.temp
				cat $BASEDIR/squid.conf_acl.temp >> $BASEDIR/squid.conf.temp
				
				cat $BASEDIR/squid.conf_httpaccesstitle.temp >> $BASEDIR/squid.conf.temp
				cat $BASEDIR/squid.conf_httpaccess.temp >> $BASEDIR/squid.conf.temp
				cat $BASEDIR/squid.conf_httpaccessdefault.temp >> $BASEDIR/squid.conf.temp
				
				cat $BASEDIR/squid.conf.temp
				echo -e "\n------------------------------------------------\n"
		
				configpart=
		
			;;
			
			showcurrentconfig )
	
				echo -e "\n------------------------------------------------\n"
				cat /etc/squid/squid.conf
				echo -e "\n------------------------------------------------\n"
		
				configpart=
		
			;;

			saveconfig )
	
				cp $BASEDIR/squid.conf.temp /etc/squid/squid.conf
				systemctl restart squid
				systemctl status squid
				echo "Changes Saved !"
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
	echo "Squid has not been configured."
fi
