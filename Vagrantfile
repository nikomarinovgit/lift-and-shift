# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

$common = <<SCRIPT
# rm /home/vagrant/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config.d/non-interactive-ssh.conf
systemctl restart sshd 

echo "* Updating..."

subscription-manager register --username nikomarinov@gmail.com --password Exosc@le100 --force
sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms
# dnf update -y
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
# dnf install sshpass -y

SCRIPT

Vagrant.configure("2") do |config| 
	config.vm.define "infra" do |infra|
	# infra.vm.box = "RHEL-local"
	infra.vm.box = "nikomarinov/RHEL"
	infra.vm.box_version = "1"
	infra.vm.provision "shell", inline: $common
	infra.vm.hostname = "infra.okd4.poc"
	infra.vm.network "private_network",:mac => "5CA1AB1E0000", ip: "192.168.99.100"
	infra.vm.network "private_network",:mac => "5CA1AB1E0010", ip: "192.168.66.100"
	infra.vm.synced_folder "data/", "/vagrant", SharedFoldersEnableSymlinksCreate: false
	# infra.vm.provision "shell", inline: $infra
	infra.vm.provider "virtualbox" do |vb|
		vb.gui = false
		vb.memory = "16384"
		vb.cpus = "4"
		vb.name = "infra"
		vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
		end
	end


	config.vm.define "okd4-bootstrap" do |okd4_bootstrap|
	# okd4_bootstrap.vm.box = "RHEL-local"
	okd4_bootstrap.vm.box = "nikomarinov/RHEL"
	okd4_bootstrap.vm.box_version = "1"
	okd4_bootstrap.vm.provision "shell", inline: $common
	okd4_bootstrap.vm.hostname = "okd4-bootstrap.okd4.poc"
	okd4_bootstrap.vm.network "private_network",:mac => "5CA1AB1E0001", ip: "192.168.99.101"
	okd4_bootstrap.vm.network "private_network",:mac => "5CA1AB1E0101", ip: "192.168.66.101"
	okd4_bootstrap.vm.synced_folder "data/", "/vagrant", SharedFoldersEnableSymlinksCreate: false
	# okd4_bootstrap.vm.provision "shell", inline: $okd4_bootstrap
	okd4_bootstrap.vm.provider "virtualbox" do |vb|
		vb.gui = false
		vb.memory = "16384"
		vb.cpus = "4"
		vb.name = "okd4-bootstrap"
		vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
		end
	end
end
