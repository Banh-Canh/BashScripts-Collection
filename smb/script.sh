#!/bin/bash

# install samba

apt install -y samba

# backup config samba

cp /etc/samba/smb.conf /etc/samba/smb.conf.old

# Configure SAMBA

cp /media/sf_SHARED_FOLDER/scripts/smb/smb.conf.template /etc/samba/smb.conf

# Create users



systemctl restart smbd nmbd
systemctl status smbd
