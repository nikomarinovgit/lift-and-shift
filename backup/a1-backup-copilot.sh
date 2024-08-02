#!/bin/bash
set -e

# Function to handle errors
error_handler() {
    echo -e "\e[31mError occurred in script at line: $1\e[0m"
    exit 1
}

# Trap errors and call error_handler
trap 'error_handler $LINENO' ERR

echo "A1 clonezilla"
echo $(date)

# Change passwords
echo 'root:Lxu_if9`94;2Kd<6UQ#2,:t50e*ASRt="fGR8tWV,zvVjcfK@p' | sudo chpasswd
echo 'user:Lxu_if9`94;2Kd<6UQ#2,:t50e*ASRt="fGR8tWV,zvVjcfK@p' | sudo chpasswd

# echo 'root:pptpd' | sudo chpasswd
# echo 'user:pptpd' | sudo chpasswd

# Allow root login via SSH if not already allowed
if ! grep -q 'PermitRootLogin yes' /etc/ssh/sshd_config; then
    echo -e "\e[32mAllowing sshd for root.\e[0m"
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
else
    echo -e "\e[32mRoot already allowed for ssh.\e[0m"
fi

# Start SSH service
systemctl start ssh

# Set up S3FS password file
echo "clonezilla-test:EXOdc65249415796c46532f659d:TcxaGSoeUUcBWWVac4Q68q8J3G5ilbREcBg-Gx22VWM" > /root/.passwd-s3fs
chmod 600 /root/.passwd-s3fs

# Unmount /mnt if mounted
umount /mnt 2> /dev/null || true

# Mount LVM volumes
for lvm in $(lvs | grep -iP ".*root" | tr -s ' ' | cut -d ' ' -f 3); do
    lvm_path=$(lvdisplay rhel | grep "LV Path" | tr -s ' ' | cut -d ' ' -f 4)
    mount $lvm_path /mnt
done

source_hostname=$(cat /mnt/etc/hostname)
echo -e "\e[32mFound hostname \e[0m $source_hostname"

# Find network configuration
ifcfgs=$(ls /mnt/etc/sysconfig/network-scripts/ifcfg-* | tr ' ' '\n')
for ifcfg in $ifcfgs; do
    echo -e "\e[32mSearching in \e[0m $ifcfg"
    if [ -z "$(grep 'GATEWAY' $ifcfg | cut -d '=' -f 2)" ]; then
        echo -e "\e[32mNo gateway in \e[0m $ifcfg\n"
    else
        echo -e "\e[32mFound gateway in \e[0m $ifcfg\n"
        n_if=$(basename $ifcfg)
        n_gw=$(grep 'GATEWAY' $ifcfg | cut -d '=' -f 2)
        n_mask=$(grep 'NETMASK' $ifcfg | cut -d '=' -f 2)
        n_ip=$(grep 'IPADDR' $ifcfg | cut -d '=' -f 2)
        n_dns=$(grep 'nameserver' /mnt/etc/resolv.conf | cut -d ' ' -f 2)
    fi
done

echo -e "\e[32mI found : \n \e[0mfrom interface: $n_if \n IP address: $n_ip \n Network mask: $n_mask \n Gateway: $n_gw \n DNS: $n_dns \n"

read -p "Press Enter to continue..."

# Set DNS
echo -e "\e[32mSetting the DNS\e[0m"
echo "nameserver $n_dns" > /etc/resolv.conf

BUCKET_URL="sos-at-vie-1.exo.io"
try_me_if=$(ls /sys/class/net/ | grep -iP "eth.*")

# Configure network interfaces
for i in $try_me_if; do
    echo -e "\e[32mTrying interface $i \e[0m"
    ip r delete default 2> /dev/null || true
    ip a delete $n_ip/$n_mask dev $i 2> /dev/null || true
    ip addr add $n_ip/$n_mask dev $i 2> /dev/null
    ip link set $i up 2> /dev/null 
    ip route add default via $n_gw dev $i 2> /dev/null
    if [ "$(curl -s -o /dev/null -w "%{http_code}" "$BUCKET_URL")" -eq 403 ]; then
        echo -e "\e[32mcurl test successful to $n_gw\e[0m"
        break
    else
        echo -e "\e[32mcurl test failed to $BUCKET_URL, next please...\e[0m"
        ip a delete $n_ip/$n_mask dev $i 2> /dev/null || true
        ip r delete default 2> /dev/null || true
    fi
done

# Unmount /mnt
umount /mnt

# Check if S3 bucket is mounted
if df -H | grep -q s3fs; then
    echo -e "\e[32mS3 bucket is here.\e[0m"
else
    echo -e "\e[32mS3 bucket is missing. Trying to attach...\e[0m"
    s3fs clonezilla-test:/ /home/partimag -o use_path_request_style -o url=https://sos-at-vie-1.exo.io -o passwd_file=/root/.passwd-s3fs -o del_cache -o no_check_certificate -d
    df -H | grep s3fs
fi

read -p "Press Enter to continue..."

# Run Clonezilla
/usr/sbin/ocs-sr -q2 -nogui -j2 -z1p -i 0 -sfsck -scs -senc -p choose savedisk $source_hostname-$(date +"%d-%m-%Y-%H-%M-%S") $(lsblk -d | grep sd | cut -d ' ' -f 1)


