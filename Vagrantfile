MACHINE_NAME = "default"

Vagrant.configure("2") do |config|

  # https://app.vagrantup.com/debian/boxes/bullseye64

  config.vm.box = "generic/ubuntu1604"
  config.vm.hostname = MACHINE_NAME 

  #config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "public_network"

  config.vm.provision :shell, path: "bootstrap.sh", :args => [MACHINE_NAME]

  config.vm.provider "virtualbox" do |v|
    v.name = MACHINE_NAME
    v.memory = "8192"
    v.cpus = 3
    v.customize ["modifyvm", :id, "--vram", "16"]
    v.customize ["modifyvm", :id, "--nic2", "hostonly", "--macaddress2", "080027daf115", "--hostonlyadapter2", "VirtualBox Host-Only Ethernet Adapter"]
    v.customize ["modifyvm", :id, "--autostart-enabled", "on", "--autostop-type", "acpishutdown"]
  end

end
