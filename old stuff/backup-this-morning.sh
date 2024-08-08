# backup-this-morning.sh

#!/bin/bash
set -e

echo "A1 clonezilla";
echo $(date);
# read -p "Press Enter to continue..." ;

echo 'root:pptpd' | sudo chpasswd
echo 'user:pptpd' | sudo chpasswd
[ -z "$(cat /etc/ssh/sshd_config | grep 'PermitRootLogin yes')" ] && ( echo -e "\e[32mAllowing sshd for root.\e[0m" ; echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config ) || echo -e "\e[32mRoot already allowed for ssh.\e[0m"
systemctl start ssh

read -p "Press Enter to continue..." ;

echo "clonezilla-test:EXOdc65249415796c46532f659d:TcxaGSoeUUcBWWVac4Q68q8J3G5ilbREcBg-Gx22VWM" > /root/.passwd-s3fs
chmod 600 /root/.passwd-s3fs

umount /mnt 2> /dev/null ;

read -p "Press Enter to continue..." ;


for lvm in $(lvs | grep -iP ".*root" | tr -s ' ' | cut -d ' ' -f 3); do
    lvm_path=$(lvdisplay rhel | grep "LV Path" | tr -s ' ' | cut -d ' ' -f 4) ;
    mount $lvm_path /mnt ;
done

source_hostname=$(cat /mnt/etc/hostname);
echo -e "\e[32mFound hostname \e[0m $source_hostname"

ifcfgs=$(ls /mnt/etc/sysconfig/network-scripts/ifcfg-* | tr ' ' '\n') ; 

for ifcfg in $ifcfgs; do
    echo -e "\e[32mSerching in \e[0m $ifcfg" ;
    if [ -z $(cat $ifcfg | grep "GATEWAY" | cut -d '=' -f 2) ] ; then
        echo -e "\e[32mNo gateway in \e[0m $ifcfg\n";
    else
        echo -e "\e[32mFound gateway in \e[0m $ifcfg\n" ; 
        n_if=$(echo $ifcfg | cut -d '/' -f 6);
        n_gw=$(cat $ifcfg | grep "GATEWAY" | cut -d '=' -f 2) ; 
        n_mask=$(cat $ifcfg | grep NETMASK | cut -d '=' -f 2) ; 
        n_ip=$(cat $ifcfg | grep IPADDR | cut -d '=' -f 2) ;
        n_dns=$(cat /mnt/etc/resolv.conf |grep nameserver |cut -d ' ' -f 2 ) ;
    fi
    
done

echo -e "\e[32mI found : \n \e[0mFrom interface: $n_if \n IP address: $n_ip \n Network mask: $n_mask \n Gateway: $n_gw \n DNS: $n_dns \n" ;

read -p "Press Enter to continue..." ;

echo -e "\e[32mSetting the DNS\e[0m" ;
echo "nameserver $n_dns" > /etc/resolv.conf ; 

BUCKET_URL="sos-at-vie-1.exo.io";

try_me_if=$(ls /sys/class/net/ | grep -iP "eth.*") ; 

for i in $try_me_if ; do
    echo -e "\e[32mTrying interface $i \e[0m";

    if [ ! -z "$(ip r | grep default)" ] ; then
        ip r delete default;
    fi
    
    if [ ! -z "$(ip a show dev $i | grep $n_ip)" ]; then
        ip a delete $n_ip/$n_mask dev $i ;
    fi

    ip addr add $n_ip/$n_mask dev $i ;
    ip link set $i up ;
    ip route add default via $n_gw dev $i ;

    if [ $(curl -s -o /dev/null -w "%{http_code}" "$BUCKET_URL") -eq 403 ]; then
        echo -e "\e[32mcurl test successful to $n_gw\e[0m" ; 
        break ;
    else
        echo -e "\e[32mcurl test failed to $BUCKET_URL, next please...\e[0m"
        ip a delete $n_ip/$n_mask dev $i ;
        ip r delete default ;
    fi
done

umount /mnt 

if [ ! -z "$(df -H | grep s3fs)" ]; then
    echo -e "\e[32mS3 bucket is here.\e[0m"
else
    echo -e "\e[32mS3 bucket is missing. Trying to attach...\e[0m" ;
    s3fs clonezilla-test:/ /home/partimag -o use_path_request_style -o url=https://sos-at-vie-1.exo.io -o  passwd_file=/root/.passwd-s3fs -o  del_cache -o no_check_certificate  -d ;
    df -H | grep s3fs ;
fi

read -p "Press Enter to continue..." ;

/usr/sbin/ocs-sr -q2 -nogui -j2 -z1p -i 0 -sfsck -scs -senc -p choose savedisk $source_hostname-$(date +"%d-%m-%Y-%H:%M:%S") $(lsblk -d | grep sd | cut -d ' ' -f 1 )

# /bin/bash --


