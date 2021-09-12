### Customized boot2docker replacement 

For VSCode remote container development on Windows [docker-desktop] is now 
recommended. [Docker desktop] requires you to install WSL2 which, for me, resulted in
a boat load of problems with my existing Virtual Box VMs.

This is an Ubuntu 16.04 LTS minimal VirtualBox VM configured as a drop-in replacement
for the default VM created by [docker-toolbox] on Windows. [Vagrant] is used to create a 
new *default* VM. 

The customized VM can be configured as as required. The script *bootstrap.sh* 
installs Samba and Portainer.  

### Usage

This step removes any existing *default*. The script will also delete the virtual 
box *VirtualBox Host-Only Ethernet Adapter* and it's associated DHCP server. This is
needed to guarantee the the newly created VM will have the ip address 192.168.99.100.

In a git-bash terminal window:

    ./remove-vm.sh

Use [Vagrant] to create a new [generic/ubuntu1604](https://app.vagrantup.com/generic/boxes/ubuntu1604) *default* vbox vm

    vagrant up
    vagrant halt

Create a new ssh key pair using *ssh-keygen*

    ssh-keygen -t rsa -f vscode_remote

Use the script *./docker-commission.sh* to inject ssh keys and get 
docker-machine to commission the VM and install Docker: 

    ./commission-vm.sh

Test the new docker VM by creating a simple container:

    eval $(docker-machine env default)
    docker run hello-world

Edit *C:\Windows\System32\drivers\etc\hosts* and append the line *192.168.99.100  default*:

```
# localhost name resolution is handled within DNS itself.
#	127.0.0.1       localhost
#	::1             localhost

192.168.99.100  default
```

To confirm portainer is working, visit [http://default:9000/#/dashboard](http://default:9000/#/dashboard).

You will need to change passwords on the VM users *admin* and *vscode*. The *vagrant* user can
be deleted.

### VSCODE Remote containers

The now discontinued [docker-toolbox] can be used successfully with Virtual Box but
the version of docker installed by *docker-toolbox* is old. An alternative is to
install docker-cli and docker-machine directly.

[Chocolatey](https://community.chocolatey.org/packages?q=docker-cli) is currently hosting
the following versions:

    docker-toolbox 19.03.1 => docker 19.03.1, docker-machine 0.16.1
    docker-cli 19.3.12, 
    docker-machine 0.16.2

Chocolatey installs [docker-cli] and [docker-machine] to the folder:

    C:\ProgramData\chocolatey\bin

docker.exe 20.10.5 is available from [here](https://github.com/StefanScherer/docker-cli-builder/releases). Dropping
this in to *C:\ProgramData\chocolatey\bin\* works fine. This is a stop gap until docker-cli 20.10.5 becomes
available on Chocolatey.

#### Container development

A Samba share is available on the new *default* VM

    \\default\workspaces

On the Windows host, drop VSCODE projects into this share. Projects dropped onto the
share will, on the *default* VM be owned by the user *vscode uid=1000, gui=1000* 

To make the Samba share map onto the container you will need to edit/add the following 
lines to the file *./devcontainer/devcontainer.json*:

```
"workspaceFolder": "/workspace",
"workspaceMount": "source=/workspaces/${localWorkspaceFolderBasename},target=/workspace,type=bind,consistency=cached",
```

For uid/gui consistency, in your *./devcontainer/Dockerfile* create the user *vscode*. For example:
```
FROM nikolaik/python-nodejs:python3.8-nodejs12

RUN useradd -ms /bin/bash vscode


USER vscode
ENV PATH="/home/vscode/.local/bin:${PATH}"
```

In VSCODE enter *Ctrl + Shift + P* and select *Remote Containers: Rebuild and Reopen in Container*. You
should now be good to go.

[vagrant]:https://community.chocolatey.org/packages/vagrant
[docker-toolbox]: https://community.chocolatey.org/packages/docker-toolbox
[docker-cli]: https://community.chocolatey.org/packages/docker-cli
[docker-machine]: https://community.chocolatey.org/packages/docker-machine
[docker-desktop]: https://community.chocolatey.org/packages/docker-desktop
