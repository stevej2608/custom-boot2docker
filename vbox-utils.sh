#!/bin/bash

# Return true if VM is in given state
#
#   if vm_state $VMNAME "running"
#   then
#     echo "$VMNAME is running"
#   fi
#
function vm_state() {
  local VM=$1
  local STATE=$2
  local state=`VBoxManage showvminfo --machinereadable $VM | grep VMState=`
  if [[ $state =~ $STATE ]] ; then true ; else false ;fi
}

# Wait until vm enters given state
#
#   wait_vm_state $VMNAME "running|poweroff"

function wait_vm_state() {
  local VM=$1
  local STATE=$2
  until vm_state $VM $STATE
  do
    echo "Waiting for $VM state=$STATE"
    sleep 2
  done
}

# Return true if VM exists
#
#   if vm_exists $VMNAME
#   then
#     echo "$VMNAME exists"
#   fi
#

function vm_exists() {
  local VM=$1
  local exists=`VBoxManage list vms | grep \"$VM\"`
  if [[ $exists ]] ; then true ; else false ;fi
}

#
# Start VM
#

function vm_start() {
  local VM=$1
  if vm_exists $VM
  then
    if  vm_state $VM "poweroff"
    then
      echo "[Starting $VM ...]"
      VBoxManage startvm $VM
      sleep 1
      wait_vm_state $VM "running"
    fi
  fi
}

#
# Stop VM
#

function vm_stop() {
  local VM=$1
  if vm_exists $VM
  then
    if  vm_state $VM "running"
    then
      echo "[Stopping $VM ...]"
      VBoxManage controlvm $VM acpipowerbutton
      sleep 1
      wait_vm_state $VM "poweroff"
    fi
  fi
}

#
# Delete VM
#

function vm_delete() {
  local VM=$1
  if vm_exists $VM
  then
    vm_stop $VM
    vboxmanage unregistervm $VM --delete
  fi
}
