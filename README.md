# BashScripts-Collection

## Requirements

 - Ubuntu 20.04 Focal

## This is a small collection of scripts. It includes 4 scripts:

 - Configurewithssh: A script I made with the intent to run commands & scripts to configure and interact (through ssh) with multiple servers/computers on the network. For now it allows to search and see if a file exists in any of the terminals on the network or on the specified IP range. It requires a sudoer that exists and has the same password on all terminals (far from ideal, I know).
 - DHCP configuration, text-based interface
 - SQUID (with basic auth apache2-util), text-based interface
 - NETPLAN: Scripts I made that allows the user to install and configure those services without the need to go through a text editor.

It includes a launcher that allows a listing of the availables scripts. To add new script just add a new folder with the script inside renamed script.sh. The configurations's script follow steps and procedures I learnt while installing it manually. Some configurations might be missing but it should not be too hard to implement them. See more on Github... 
