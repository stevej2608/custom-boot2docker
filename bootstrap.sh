#!/bin/bash

HOST_NAME=$1
DEFAULT_USER="vscode"

# Add user 

add_user () {
  local username=$1
  local password=$2

  # group docker will allready

  if [ $username == "docker" ] ; then 
    adduser --quiet --disabled-password --shell /bin/bash --home /home/docker --gecos "User" docker --ingroup docker
  else 
    adduser --quiet --disabled-password --shell /bin/bash --home /home/$username --gecos "User" $username
  fi

  echo "$username:$password" | chpasswd

  # samba share

  (echo "$password"; echo "$password") | smbpasswd -s -a $username

}

# Install base packages

echo "[Install base packages]"
apt-get -qq update
apt-get -qqy install build-essential dkms linux-headers-$(uname -r)

# Set the hostname

echo "[Set the hostname]"
hostnamectl set-hostname $HOST_NAME

# Allow remote ssh

echo "[Allow remote ssh]"
sed -i "/PermitRootLogin/c\PermitRootLogin yes" /etc/ssh/sshd_config
sed -i "/PubkeyAuthentication/c\PubkeyAuthentication yes" /etc/ssh/sshd_config
sed -i "/PasswordAuthentication/c\PasswordAuthentication yes" /etc/ssh/sshd_config

# Install samba

echo "[Install samba]"
DEBIAN_FRONTEND=noninteractive apt-get install samba -y

cat > /etc/samba/smb.conf <<EOF
[global]
  server string = DEBIAN-SERVER
  workgroup = WORKGROUP
  security = user
  map to guest = Bad User
  name resolve order = bcast host

[workspaces]
path = /workspaces/
writable = yes
browsable = yes
printable = no
guest ok = no
create mask = 0644
directory mask = 0755
force user = ${DEFAULT_USER}
force group = ${DEFAULT_USER}
veto files = /.DS_Store/.Trashes/Thumbs.db/
delete veto files = yes
valid users = ${DEFAULT_USER}
EOF

# Create vscode user

echo "[Create accounts admin & $DEFAULT_USER]"

add_user admin passme99
add_user ${DEFAULT_USER} passme99

mkdir /workspaces
chown ${DEFAULT_USER}:${DEFAULT_USER} /workspaces

# Enable vbox host-only connection

cat <<EOF >> /etc/network/interfaces

# Enable vbox host-only connection

allow-hotplug eth1
iface eth1 inet dhcp
EOF

ifup eth1

# Allow docker-machine to without password

cat <<EOF >> /etc/sudoers

# Allow docker-machine to sudo without password

admin ALL=(ALL) NOPASSWD: ALL

${DEFAULT_USER} ALL=(ALL) NOPASSWD: ALL
EOF

service sshd restart
