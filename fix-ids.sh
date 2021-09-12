#!/bin/bash

# Vagrant creates user vagrant uid=1000, gui=1000 as part of
# the VM build process. By default vscode dev containers 
# use the same uid/gid values. This script will change the
# vagrant uid/gid to 2000/2000 and then change the vscode
# uid/gid to 1000/1000
#
# This script cannot be run as vgrant or vscode. Use 
# docker:
#
#  ssh docker@default "bash -s" < ./fix-ids.sh

modify_user () {
  local username=$1
  local uid=$2
  local gid=$3

  if [[ $(id $username) =~ uid=([0-9]+).*gid=([0-9]+) ]]; then 
    local uid_old=${BASH_REMATCH[1]}
    local gid_old=${BASH_REMATCH[2]}
  else
    echo "Unknown user $username" && exit 1
  fi

  echo "Change $username uid $uid_old => $uid  gid $gid_old => $gid"

  sudo usermod -u $uid $username
  sudo groupmod -g $gid $username

  sudo find /home -group $gid_old -exec chgrp -h $username {} \;
  sudo find /home -user $uid_old -exec chown -h $username {} \;
}

sudo pkill -9 -u `id -u vagrant`
sudo pkill -9 -u `id -u vscode`

modify_user vagrant 2000 2000
modify_user vscode 1000 1000

id vscode

sudo chown -R vscode:vscode /workspaces

  # Allow user to run docker

sudo usermod -aG docker admin
sudo usermod -aG docker vscode

