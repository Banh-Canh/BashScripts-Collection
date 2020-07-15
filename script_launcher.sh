#!/bin/bash

BASEDIR=$(dirname "$0")
listscripts=`ls -d $BASEDIR/*/`

echo -e "\nAvailable scripts :\n\n$listscripts \n"

while [ "$readorrun" != edit ] && [ "$readorrun" != run ]
do
  read -p "Do you want to edit [edit] or run [run] a script ? " readorrun
done

if [ "$readorrun" == edit ]
then

  read -p "Enter the script's name to edit : " script
  nano $BASEDIR/$script/script.sh

elif [ "$readorrun" == run ]
then
  command=
  read -p "Enter the script's name to run : " runscript
  $BASEDIR/$runscript/script.sh
  
fi

