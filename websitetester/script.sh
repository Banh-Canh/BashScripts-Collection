#!/bin/bash

read -p "Site internet à tester : " website
read -p "Chemin absolu du download : " download
ping $website -c 2 -W 3 && wget -r -N $website -P $download && echo "ça marche, go download" || echo "epic fail"

