#!/bin/bash

BASEDIR=$(dirname "$0")

# install squid

apt install -y squid

# backup config squid

cp /etc/squid/squid.conf /etc/squid/squid.conf.old

while [ "$configyesno" != oui ] && [ "$configyesno" != non ]
  do
        read -p "Souhaitez-vous configurer le serveur squid [oui ou non] ? " configyesno
  done

if [ "$configyesno" == oui ]
then


rm $BASEDIR/squid.co*


echo -e "\n\n#PARAMETRE AUTHENTIFICATION\n\n" > $BASEDIR/squid.conf_authtitle.temp
echo -e "\n\n#PARAMETRE ACL\n\n" > $BASEDIR/squid.conf_acltitle.temp
echo -e "\n\n#PARAMETRE HTTPACCESS\n\n" > $BASEDIR/squid.conf_httpaccesstitle.temp
echo -e "acl localnet src 0.0.0.1-0.255.255.255    # RFC 1122 "\"this"\" network (LAN)\nacl localnet src 10.0.0.0/8        # RFC 1918 local private network (LAN)\nacl localnet src 100.64.0.0/10        # RFC 6598 shared address space (CGN)\nacl localnet src 169.254.0.0/16     # RFC 3927 link-local (directly plugged) machines\nacl localnet src 172.16.0.0/12        # RFC 1918 local private network (LAN)\nacl localnet src 192.168.0.0/16        # RFC 1918 local private network (LAN)\nacl localnet src fc00::/7           # RFC 4193 local private network range\nacl localnet src fe80::/10          # RFC 4291 link-local (directly plugged) machines\nacl SSL_ports port 443\nacl Safe_ports port 80        # http\nacl Safe_ports port 21        # ftp\nacl Safe_ports port 443        # https\nacl Safe_ports port 70        # gopher\nacl Safe_ports port 210        # wais\nacl Safe_ports port 1025-65535    # unregistered ports\nacl Safe_ports port 280        # http-mgmt\nacl Safe_ports port 488        # gss-http\nacl Safe_ports port 591        # filemaker\nacl Safe_ports port 777        # multiling http\nacl CONNECT method CONNECT\n" > $BASEDIR/squid.conf_acldefault.temp
echo -e "http_access deny !Safe_ports\nhttp_access deny CONNECT !SSL_ports\nhttp_access allow localhost manager\nhttp_access deny manager\ninclude /etc/squid/conf.d/*\nhttp_access allow localhost\nhttp_access deny all\n" > $BASEDIR/squid.conf_httpaccessdefault.temp
echo "http_port 3128" >> $BASEDIR/squid.conf_httpaccessdefault.temp

# Configure Squid

  while [ 1 ]
  do

  while [ "$configpart" != acl ] && [ "$configpart" != httpaccess ] && [ "$configpart" != showconfig ] && [ "$configpart" != saveconfig ] && [ "$configpart" != exitconfig ]
  do
    echo -e "\n------------------------------------------------\n"
    echo "[acl] [httpaccess] [showconfig] [saveconfig] [exitconfig]"
        echo -e "\n------------------------------------------------\n"
        read -p "Quel partie souhaitez-vous configurer ? " configpart
        echo -e "\n------------------------------------------------\n"
  done
  
  
   case $configpart in
  
############################
    
	 acl )
	 
        while [ 1 ]
          do
          read -p "Souhaitez-vous ajouter une ACL ? [oui ou non] " addacl
          case $addacl in        
            
            oui )
			    
                echo -e "\n------------------------------------------------\n"
                read -p "Entrez parametre 1 [ex : toto] : " param1
                read -p "Entrez parametre 2 [ex : browser, proxy_auth, dstdomain etc..] : " param2 
				######
				if [ "$param2" == "proxy_auth" ]
				then
			
			      
				  while [ 1 ]
				  do
				    read -p "Vous avez entré un paramètre d'authentification, souhaitez-vous installer et configurer un service d'authentification basique (apache2-utils) [oui ou non] ? " configauthyesno
			        case $configauthyesno in  
					
					oui )
					
					apt install apache2-utils -y
					read -p "Indiquer le dossier dans lequel le fichier sera crée : " apachmdpfolder
				    echo -e "auth_param basic program /usr/lib/squid3/basic_ncsa_auth $apachmdpfolder/password" >> $BASEDIR/squid.conf_auth.temp
					mkdir -p $apachmdpfolder && touch $apachmdpfolder/password
				    param3="$apachmdpfolder/password"
					break;;
					
					non )
					
					break;;
					
					* )
					
					echo "Veuillez choisir [oui] ou [non] !"
					;;
					
				    esac
				  done
				  
			     else
				 read -p "Entrez parametre 3 [ex (si param2 = browser): Firefox] : " param3 
				 fi
				#######
				
				
                echo -e "acl $param1 $param2 $param3" >> $BASEDIR/squid.conf_acl.temp
                ;;
            
            non )			
            break;;
          esac    
          done	
        
		 configpart=
	 ;;
	 
#############################
  
    httpaccess )

	while [ 1 ]
	do
		read -p "Souhaitez-vous ajouter une règle httpaccess ? [oui ou non] " addhttpaccess
		case $addhttpaccess in	    
			
			oui )
			
				read -p "Autoriser [allow] ou refuser [deny]: " allowordeny
				read -p "Quel paramètres ACLs doivent suivre cette règle ? [ex: name1 !name2 name3] : " aclparam_vic
		
				echo -e "http_access $allowordeny $aclparam_vic" >> $BASEDIR/squid.conf_httpaccess.temp
				
			;;
			
			non )
			
			break;;
			
		esac	
	done
    
    configpart=
	
    ;;
	
	
##############################################################

    showconfig )
	
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
		
##############################################################

	saveconfig )
	
	  cp $BASEDIR/squid.conf.temp /etc/squid/squid.conf && rm $BASEDIR/squid.conf.temp
	  systemctl restart squid
	  systemctl status squid
	  echo "Changements sauvegardés !"
	  configpart=
	  
	  ;;

#############################################################
	  
	exitconfig )
	
	  rm $BASEDIR/squid.co*
	  echo "Au revoir !" 
	
	break;;

###########################################################
	

  esac
  done
  
elif [ "$configyesno" == non ]
then
	echo "Squid installé mais non configuré (par défaut)"
fi
