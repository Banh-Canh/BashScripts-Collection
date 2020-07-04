#!/bin/bash

randomnumber=$(( RANDOM % 10 ))

while [ "$win" != yes ]
do
	read -p "Choissez un nombre : " nombre

	if [ "$nombre" -eq "$randomnumber" ]
	then
	  echo "GG toi"
	  win=yes
	  
	elif [ "$nombre" -lt "$randomnumber" ]
	then
	  echo "Trop petit"
	  
	elif [ "$nombre" -gt "$randomnumber" ]
	then
	  echo "Trop grand"
	  
	fi
done
