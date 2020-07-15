#!/bin/bash

BASEDIR=$(dirname "$0")

function exitscript()
{
	rm $BASEDIR/result* 2> /dev/null
	echo -e "\n------------------------------------------------\n"
	echo "Good Bye !" 
	echo -e "\n------------------------------------------------\n"
	exit
}

trap exitscript INT

apt install sshpass -y

####################

ipmin=1
ipmax=5


#trap '' INT

echo ""
echo "The network's address must be 192.168.0.0"
read -p "Enter an user that exist in all of the network's machines : " user
read -sp "Super User Password : " passwdmachineone

while [ 1 ]
do

	echo -e "\n------------------------------------------------\n"
	echo -e "IP range of affected machines : 192.168.0.$ipmin - 192.168.0.$ipmax\n "
	echo "[TimeSync] [FileSearch] [changeIPrange] [exitconfig]"
	echo -e "\n------------------------------------------------\n"
	read -p "What do you want to configure ? " configpart
	echo -e "\n------------------------------------------------\n"

	case $configpart in
	
        changeIPrange )
		
			read -p "Enter the first IP of the range : 192.168.0." ipmin
			read -p "Enter the last IP of the range : 192.168.0." ipmax
			
		;;
		
		TimeSync )
			
			echo -e "\nLeave empty to sync the date with the internet network.\n"
			read -p "Date [YYYY-MM-DD] : " dateday
			read -p "Time [HH:MM:SS] : " datehour
					
			for ipend in $( eval echo {$ipmin..$ipmax} )
			do
				ip="192.168.0.$ipend"
				ping $ip -c 1 -W 1 2>&1> /dev/null
				if [ "$?" = 0 ]
				then
					sshpass -p "$passwdmachineone" ssh -qo StrictHostKeyChecking=no $user@$ip exit
					if [ "$?" = 0 ]
					then
						if [ -z "$dateday" ] || [ -z "$datehour" ]
						then
							sshpass -p "$passwdmachineone" ssh -o StrictHostKeyChecking=no $user@$ip "echo $passwdmachineone | sudo -S timedatectl set-ntp true" > /dev/null 2>&1
						else
							sshpass -p "$passwdmachineone" ssh -o StrictHostKeyChecking=no $user@$ip "echo $passwdmachineone | sudo -S timedatectl set-ntp false" > /dev/null 2>&1
							sshpass -p "$passwdmachineone" ssh -o StrictHostKeyChecking=no $user@$ip "echo $passwdmachineone | sudo -S timedatectl set-time $dateday" > /dev/null 2>&1
							sshpass -p "$passwdmachineone" ssh -o StrictHostKeyChecking=no $user@$ip "echo $passwdmachineone | sudo -S timedatectl set-time $datehour" > /dev/null 2>&1
						fi
					else
						echo -e "\n------------------------------------------------"
						echo "Can't connect with SSH to $ip"
						echo -e "------------------------------------------------\n"
					fi
				fi
			done
		
		;;
	
		FileSearch )
	
			read -p "Path to the folder to start the search from : " paths
			read -p "Name of the file to look for [ex: *auth.log]: " name
			echo ""
		
			echo -e "######## RESULT #############\n\n" > $BASEDIR/result.txt

			for ipend in $( eval echo {$ipmin..$ipmax} )
			do
				ip="192.168.0.$ipend"
				ping $ip -c 1 -W 1 2>&1> /dev/null
				if [ "$?" = 0 ]
				then
					sshpass -p "$passwdmachineone" ssh -qo StrictHostKeyChecking=no $user@$ip exit
					if [ "$?" = 0 ]
					then
						sshpass -p "$passwdmachineone" ssh -o StrictHostKeyChecking=no $user@$ip "echo $passwdmachineone | sudo -S find $paths -name $name > /home/$user/result.txt" > /dev/null 2>&1
						sshpass -p "$passwdmachineone" scp -o StrictHostKeyChecking=no $user@$ip:/home/$user/result.txt $BASEDIR/result$ip.txt
						echo -e "\n### $ip ###\n" >> $BASEDIR/result.txt
						cat $BASEDIR/result$ip.txt >> $BASEDIR/result.txt 
						sshpass -p "$passwdmachineone" ssh -o StrictHostKeyChecking=no $user@$ip "rm /home/$user/result*.txt 2> /dev/null"
					else
						echo -e "\n------------------------------------------------"
						echo "Can't connect with SSH to $ip"
						echo -e "------------------------------------------------\n"
					fi
				fi
			done

			cat $BASEDIR/result.txt
			rm $BASEDIR/result*.txt 2> /dev/null
		;;
		
		exitconfig )
	
			exitscript 
			break
		;;
	
	esac
done


