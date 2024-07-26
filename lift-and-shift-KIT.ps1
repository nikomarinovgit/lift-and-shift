# KIT:
# vlhydak003 vlhydak004 vlhydak005
# Alex Weber

# vlhydak003
# CPU: 8
# MEM: 16
# DISK:   40 GiB
#         50 GiB

# Linux vlhydak003.at.inside 3.10.0-1160.119.1.el7.x86_64 #1 SMP Tue May 14 11:55:25 EDT 2024 x86_64 x86_64 x86_64 GNU/Linux
# 10.2.232.44	IPv4	255.255.255.0	ens224	vlhydak003	GW 10.2.232.254 DNS 10.2.35.73
# 10.247.166.45	IPv4	255.255.255.0	ens192	vlhydak003  GW 10.247.166.126 DNS 10.2.42.11

# vlhydak004
# CPU: 8
# MEM: 16
# DISK:   40 GiB
#         50 GiB

# Linux vlhydak004.at.inside 3.10.0-1160.119.1.el7.x86_64 #1 SMP Tue May 14 11:55:25 EDT 2024 x86_64 x86_64 x86_64 GNU/Linux
# 10.2.232.5	IPv4	255.255.255.0	ens224	vlhydak004	
# 10.247.166.46	IPv4	255.255.255.0	ens192	vlhydak004  3a:eh


# vlhydak005
# CPU: 8
# MEM: 16
# DISK:   40 GiB
#         50 GiB

# Linux vlhydak005.at.inside 3.10.0-1160.119.1.el7.x86_64 #1 SMP Tue May 14 11:55:25 EDT 2024 x86_64 x86_64 x86_64 GNU/Linux
# 10.2.232.6	IPv4	255.255.255.0	ens224	vlhydak005	
# 10.247.166.47	IPv4	255.255.255.0	ens192	vlhydak005




# Connectivity definitely required for startup:
# bashCopy code(ADDRESS = (PROTOCOL = TCP)(HOST = mmsk-db.at.inside)(PORT = 2531))
# cluster.broadcast.method.jgroups.channel.name=hybris-hydra-kit
# cluster.broadcast.method.jgroups.udp.mcast_address=224.0.0.1
# cluster.broadcast.method.jgroups.udp.mcast_port=47599
# solr.master.url=http://vlhydak006:8983/solr
# solr.slave.url=http://vlhydak007:8983/solr




# https://community.ibm.com/community/user/cloud/blogs/sharad-chandra/2022/04/28/migrating-vmware-virtual-machines-to-kvm


#
#       my work
#
echo y | exo c i rm vlhydak003 -f -z AT-VIE-1
echo y | exo c i rm vlhydak004 -f -z AT-VIE-1
echo y | exo c i rm vlhydak005 -f -z AT-VIE-1

echo y | exo c privnet delete nm-ls-10.2.232.0-ens224 -Q
echo y | exo c privnet delete nm-ls-10.247.166.0-ens192 -Q

exo c privnet add nm-ls-10.2.232.0-ens224 --description "nm privnet 10.2.232.0/24 for lift&shift VMs from vSphere. vlhydak003 - 10.2.232.44/24 - ens224 ; vlhydak004 - 10.2.232.5/24 - ens224 ; vlhydak005 - 10.2.232.6/24 - ens224" -z AT-VIE-1 -Q
exo c privnet add nm-ls-10.247.166.0-ens192 --description "nm privnet 10.247.166.0/24 for lift&shift VMs from vSphere. vlhydak003 - 10.247.166.45/24 - ens192 ; vlhydak004 - 10.247.166.46/24 - ens192 ; vlhydak005 - 10.247.166.47/24 - ens192" -z AT-VIE-1 -Q

exo c i add vlhydak003 --disk-size 100 --instance-type Extra-Large  --private-network nm-ls-10.2.232.0-ens224 --private-network nm-ls-10.247.166.0-ens192 --template "Linux Ubuntu 24.04 LTS 64-bit" -z AT-VIE-1 -Q
exo c i add vlhydak004 --disk-size 100 --instance-type Extra-Large  --private-network nm-ls-10.2.232.0-ens224 --private-network nm-ls-10.247.166.0-ens192 --template "Linux Ubuntu 24.04 LTS 64-bit" -z AT-VIE-1 -Q
exo c i add vlhydak005 --disk-size 100 --instance-type Extra-Large  --private-network nm-ls-10.2.232.0-ens224 --private-network nm-ls-10.247.166.0-ens192 --template "Linux Ubuntu 24.04 LTS 64-bit" -z AT-VIE-1 -Q


echo y | exo c i start --rescue-profile=netboot-efi nm-test-vm02 -Q


