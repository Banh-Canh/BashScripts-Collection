#!/bin/bash

BASEDIR=$(dirname "$0")
listscripts=`ls -d $BASEDIR/*/`

echo -e "\nListe des scripts disponibles:\n\n$listscripts \n"

while [ "$readorrun" != edit ] && [ "$readorrun" != run ]
do
  read -p "Souhaitez-vous editer [edit] ou lancer [run] un script ? " readorrun
done

if [ "$readorrun" == edit ]
then

  read -p "Entrez le nom du script à éditer : " script
  nano $BASEDIR/$script/script.sh

elif [ "$readorrun" == run ]
then
  command=
  read -p "Entrez le nom du script à lancer : " runscript
  $BASEDIR/$runscript/script.sh
  
fi

