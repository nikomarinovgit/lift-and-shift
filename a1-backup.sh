#!/bin/bash
# set -e

echo 'root:pptpd' | sudo chpasswd
echo 'user:pptpd' | sudo chpasswd
# echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl start ssh

echo "clonezilla-test:EXOdc65249415796c46532f659d:TcxaGSoeUUcBWWVac4Q68q8J3G5ilbREcBg-Gx22VWM" > /root/.passwd-s3fs
chmod 600 /root/.passwd-s3fs

umount /mnt >/dev/null ;

for lvm in $(lvs | grep -iP ".*root" | tr -s ' ' | cut -d ' ' -f 3); do
    lvm_path=$(lvdisplay rhel | grep "LV Path" | tr -s ' ' | cut -d ' ' -f 4) ;
    mount $lvm_path /mnt ;
done

source_hostname=$(cat /mnt/etc/hostname);
echo -e "\e[32mFound hostname $source_hostname\e[0m"

ifcfgs=$(ls /mnt/etc/sysconfig/network-scripts/ifcfg-* | tr ' ' '\n') ; 

for ifcfg in $ifcfgs; do
    echo -e "\e[32mSerching in $ifcfg\e[0m" ;
    if [ -z $(cat $ifcfg | grep "GATEWAY" | cut -d '=' -f 2) ] ; then
        echo -e "\e[32mNo gateway in $ifcfg\n\e[0m";
    else
        echo -e "\e[32mFound gateway in $ifcfg\n\e[0m" ; 
        n_if=$(echo $ifcfg | cut -d '/' -f 6);
        n_gw=$(cat $ifcfg | grep "GATEWAY" | cut -d '=' -f 2) ; 
        n_mask=$(cat $ifcfg | grep NETMASK | cut -d '=' -f 2) ; 
        n_ip=$(cat $ifcfg | grep IPADDR | cut -d '=' -f 2) ;
        n_dns=$(cat /mnt/etc/resolv.conf |grep nameserver |cut -d ' ' -f 2 ) ;
    fi
    echo -e "\e[32mWill add $n_gw as a default gateway with IP $n_ip/$n_mask and DNS $n_dns \n\e[0m"; 
done

echo -e "\e[32mSetting the DNS\e[0m" ;
echo "nameserver $n_dns" > /etc/resolv.conf ; 

test_ip=$n_gw;
# test_ip="sos-at-vie-1.exo.io";


try_me_if=$(ls /sys/class/net/ | grep -iP "eth.*") ; 

for i in $try_me_if ; do
    echo -e "\e[32mTrying interface $i \e[0m";
    
    if [ ! -z "$(ip r | grep default)" ] ; then
        echo -e "\e[32mFound default gw. Removing it.\e[0m" ;
        ip r delete default;
    fi
    

    if [ ! -z "$(ip a show dev $i | grep $n_ip)" ]; then
        ip a delete $n_ip/$n_mask dev $i ;
    fi

    ip addr add $n_ip/$n_mask dev $i ;
    ip link set $i up ;
    ip route add default via $n_gw dev $i ;
    
    if ping -c 1 "$test_ip" -I $i &> /dev/null; then
        echo -e "\e[32mPing successful to $n_gw\e[0m" ; 
        break ;
    else
        echo -e "\e[32mPing failed to $test_ip, retrying...\e[0m"
        ip a delete $n_ip/$n_mask dev $i ;
        # sleep 1  # Optional: wait for 1 second before retrying
    fi
done

ip r delete default
ip r add default via 10.0.2.2 dev eth1

umount /mnt 

# s3fs clonezilla-test:/ /home/partimag -o use_path_request_style -o url=https://sos-at-vie-1.exo.io -o  passwd_file=/root/.passwd-s3fs -o  del_cache -o no_check_certificate  -d

lsblk -d | grep sd | cut -d ' ' -f 1 ;
echo $(date +"%d-%m-%Y-%H-%M-%S") $(lsblk -d | grep sd | cut -d ' ' -f 1 )
/usr/sbin/ocs-sr -q2 -c -j2 -z1p -i 0 -sfsck -scs -senc -p choose savedisk $source_hostname-$(date +"%d-%m-%Y-%H:%M:%S") $(lsblk -d | grep sd | cut -d ' ' -f 1 )

# echo "A1 custum clonezilla";
# echo $(date);

# /bin/bash --
# read -p "Press Enter to continue..." ;

