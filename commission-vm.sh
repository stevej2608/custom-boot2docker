#!/bin/bash

SOURCE=`dirname "$0"`
source $SOURCE/vbox-utils.sh

VMNAME=default
IP_ADDR=192.168.99.100
SSH_KEY=~/.ssh/vscode_remote

# Do some sanity checks

if [ ! -f "$SSH_KEY.pub" ]; then
    echo "ssh key file '$SSH_KEY.pub' missing" && exit 1
fi

if ! vm_exists $VMNAME; then
  echo "Cannot find vm $VMNAME" && exit 1
fi

if ! vm_state $VMNAME "running"; then
  echo "VM $VMNAME must be running - start vm from VirtualBox GUI" && exit 1
fi

echo "Commissioning Docker default vm at ip addr $IP_ADDR"

# Assign ssh key

ssh-keygen -R $IP_ADDR > /dev/null 2>&1

echo "Enter admin password 'passme99' when requested"
ssh-copy-id -f -i $SSH_KEY.pub -o StrictHostKeyChecking=no admin@$IP_ADDR

echo "Enter vscode password 'passme99' when requested"
ssh-copy-id -f -i $SSH_KEY.pub -o StrictHostKeyChecking=no vscode@$IP_ADDR

# Fix the vgrant & vscode gid/uid conflict

echo "Fix the vgrant & vscode gid/uid conflict"

ssh admin@$IP_ADDR "bash -s" < ./fix-ids.sh

# Get docker-machine to commission vm

echo "Crete docker machine..."

if [[ $(docker-machine ls | grep $VMNAME) ]]; then
  echo "Remove previous '$VMNAME' machine..."
  docker-machine rm $VMNAME -y > /dev/null 2>&1
fi

docker-machine create --driver generic --generic-ip-address=$IP_ADDR --generic-ssh-user vscode --generic-ssh-key $SSH_KEY default

eval $(docker-machine env default)

# Install portainer

echo "[Installng Portainer]"

ssh admin@$IP_ADDR "bash -s" < ./install-portainer.sh

