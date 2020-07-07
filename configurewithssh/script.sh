#!/bin/bash

BASEDIR=$(dirname "$0")

apt install sshpass -y

####################

ipmin=1
ipmax=5


#trap '' INT

read -p "Entrez le nom d'user présent sur toutes les machines : " user
read -p "Quel est le mot de passe SU de toutes vos machines du réseaux ? " passwdmachineone

while [ 1 ]
do

	echo -e "\n------------------------------------------------\n"
	echo -e "Range d'IP des postes à configurer : 192.168.0.$ipmin - 192.168.0.$ipmax\n "
	echo "[TimeSync] [FileSearch] [changeIPrange] [exitconfig]"
	echo -e "\n------------------------------------------------\n"
	read -p "Quel partie souhaitez-vous configurer ? " configpart
	echo -e "\n------------------------------------------------\n"

	case $configpart in
	
        changeIPrange )
		
			read -p "Entrez la première IP de la range : 192.168.0." ipmin
			read -p "Entrez la dernière IP de la range : 192.168.0." ipmax
			
		;;
		
		TimeSync )
			
			echo -e "\nLaisser vide pour activer la synchronisation avec le réseau internet.\n"
			read -p "Entrez la date à appliquer à l'ensemble des machines [YYYY-MM-DD] : " dateday
			read -p "Entrez l'heure à appliquer à l'ensemble des machines [HH:MM:SS] : " datehour
					
			for ipend in $( eval echo {$ipmin..$ipmax} )
			do
				ip="192.168.0.$ipend"
				ping $ip -c 1 -W 1
				if [ "$?" = 0 ]
				then
					if [ -z "$dateday" ] || [ -z "$datehour" ]
					then
						sshpass -p "$passwdmachineone" ssh -o StrictHostKeyChecking=no $user@$ip "echo $passwdmachineone | sudo -S timedatectl set-ntp true"
					else
						sshpass -p "$passwdmachineone" ssh -o StrictHostKeyChecking=no $user@$ip "echo $passwdmachineone | sudo -S timedatectl set-ntp false"
						sshpass -p "$passwdmachineone" ssh -o StrictHostKeyChecking=no $user@$ip "echo $passwdmachineone | sudo -S timedatectl set-time $dateday"
						sshpass -p "$passwdmachineone" ssh -o StrictHostKeyChecking=no $user@$ip "echo $passwdmachineone | sudo -S timedatectl set-time $datehour"
					fi				
				fi
			done
		
		;;
	
		FileSearch )
	
			read -p "Sur quels dossiers souhaitez vous lancer la recherche inter-ordinateurs ? " paths
			read -p "Quel est le nom du fichier recherché ? " name
		
			echo -e "######## RESULT #############\n\n" > $BASEDIR/result.txt

			echo -e "\n### This PC ###\n" >> $BASEDIR/result.txt
			find $paths -name $name >> $BASEDIR/result.txt

			for ipend in $( eval echo {$ipmin..$ipmax} )
			do
				ip="192.168.0.$ipend"
				ping $ip -c 1 -W 1
				if [ "$?" = 0 ]
				then
					sshpass -p "$passwdmachineone" ssh -o StrictHostKeyChecking=no $user@$ip "echo $passwdmachineone | sudo -S find $paths -name $name > /home/$user/result.txt"
					sshpass -p "$passwdmachineone" scp -o StrictHostKeyChecking=no $user@$ip:/home/$user/result.txt $BASEDIR/result$ip.txt
					echo -e "\n### $ip ###\n" >> $BASEDIR/result.txt
					cat $BASEDIR/result$ip.txt >> $BASEDIR/result.txt
					sshpass -p "$passwdmachineone" ssh -o StrictHostKeyChecking=no $user@$ip "rm /home/$user/result*.txt"
				fi
			done

			cat $BASEDIR/result.txt
			rm $BASEDIR/result*.txt
		;;
		
		exitconfig )
	
			echo "Au revoir !" 
	
		break;;
	
	esac
done


