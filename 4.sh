#!/bin/bash
set -e
#
#   GENERAL FUNCTIONS
#
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
# echo 'root:Lxu_if9`94;2Kd<6UQ#2,:t50e*ASRt="fGR8tWV,zvVjcfK@p' | sudo chpasswd 2> /dev/null || true
# echo 'user:Lxu_if9`94;2Kd<6UQ#2,:t50e*ASRt="fGR8tWV,zvVjcfK@p' | sudo chpasswd 2> /dev/null || true
echo 'root:pptpd' | sudo chpasswd
echo 'user:pptpd' | sudo chpasswd

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

# Check for Windows partitions using fdisk and grep
if [ -z "$(fdisk -l | grep -E "Microsoft|Windows|NTFS")" ]; then
  echo -e "\e[32mNo Windows partition found.\e[0m"
  
  # Check for LVM volumes
  if [ -n "$(lvs)" ]; then
    echo -e "\e[32mLVM volumes found.\e[0m"
    OS_TYPE="Linux"
  else
    echo -e "\e[32mNo LVM volumes found.\e[0m"
    OS_TYPE="Unknown"
  fi
else
  echo -e "\e[32mWindows partition found.\e[0m"
  OS_TYPE="Windows"
fi

echo -e "\e[32mOS TYPE is \e[0m$OS_TYPE"

# Function to configure network interfaces
configure_network_interfaces() {
  local n_ip=$1
  local n_mask=$2
  local n_gw=$3
  local n_dns=$4
  local bucket_url=$5
  local n_hostname=$6

  # Set the hostname
  echo -e "\e[32mSetting hostname to $n_hostname\e[0m"
  hostnamectl set-hostname $n_hostname

  # Add hostname to /etc/hosts
  if ! grep -q "$n_hostname" /etc/hosts; then
    echo -e "\e[32mAdding $n_hostname to /etc/hosts\e[0m"
    echo "127.0.0.1 $n_hostname" >> /etc/hosts
  fi

  # Set DNS
  echo -e "\e[32mSetting the DNS\e[0m"
  echo "nameserver $n_dns" > /etc/resolv.conf

  try_me_if=$(ls /sys/class/net/ | grep -iP "eth.*")

  # Configure network interfaces
  for i in $try_me_if; do
      echo -e "\e[32mTrying interface $i \e[0m"
      echo "ip r delete default";
      ip r delete default 2> /dev/null || true
      echo "ip a delete $n_ip/$n_mask dev $i"
      ip a delete $n_ip/$n_mask dev $i 2> /dev/null || true
      echo "ip addr add $n_ip/$n_mask dev $i"
      ip addr add $n_ip/$n_mask dev $i # 2> /dev/null
      echo "ip link set $i up"
      ip link set $i up # 2> /dev/null 
      echo "ip route add default via $n_gw dev $i"
      ip route add default via $n_gw dev $i # 2> /dev/null
      if [ "$(curl -s -o /dev/null -w "%{http_code}" "$bucket_url")" -eq 403 ]; then
          echo -e "\e[32mcurl test successful to $bucket_url\e[0m"
          break
      else
          echo -e "\e[32mcurl test failed to $bucket_url, next please...\e[0m"
          # echo "ip a delete $n_ip/$n_mask dev $i"
          # ip a delete $n_ip/$n_mask dev $i 2> /dev/null || true
          # echo "ip r delete default"
          # ip r delete default 2> /dev/null || true
      fi
  done

export http_proxy=http://zproxy.a1.inside:443
export https_proxy=http://zproxy.a1.inside:443
export HTTP_PROXY=http://zproxy.a1.inside:443
export HTTPS_PROXY=http://zproxy.a1.inside:443

}

# Function to check and mount S3 bucket
check_and_mount_s3_bucket() {
  local bucket_url=$1

  # Unmount /mnt
  umount /mnt 2> /dev/null || true

  # Check if /root/.passwd-s3fs exists
  if [ ! -f /root/.passwd-s3fs ]; then
    echo -e "\e[31mError: /root/.passwd-s3fs file does not exist. Please create it with the necessary credentials.\e[0m"
    exit 1
  fi

  # Check if S3 bucket is mounted
  if df -H | grep -q s3fs; then
      echo -e "\e[32mS3 bucket is here.\e[0m"
  else
      echo -e "\e[32mS3 bucket is missing. Trying to attach...\e[0m"
      echo -e "s3fs clonezilla-test:/ /home/partimag -o use_path_request_style -o url=https://$bucket_url -o passwd_file=/root/.passwd-s3fs -o del_cache -o no_check_certificate -d"
      s3fs clonezilla-test:/ /home/partimag -o use_path_request_style -o url=https://$bucket_url -o passwd_file=/root/.passwd-s3fs -o del_cache -o no_check_certificate -d
      echo "sleep 5"
      sleep 5;
      df -H | grep s3fs
  fi

}

create_backup() {
  local source_hostname=$1

  # Run Clonezilla
  /usr/sbin/ocs-sr -q2 -nogui -j2 -z1p -i 0 -sfsck -scs -senc -p choose savedisk $source_hostname-$(date +"%d-%m-%Y-%H-%M-%S") $(lsblk -d | grep sd | cut -d ' ' -f 1)

}

prompt_for_settings() {
  # Prompt user to input network variables
  read -p "Enter IP address: (default: $n_ip): " temp_ip  
  n_ip=${n_ip:-$temp_ip}
  read -p "Enter Network mask: (default: $n_mask): " temp_mask
  n_mask=${n_mask:-$temp_mask}
  read -p "Enter Gateway: (default: $n_gw): " temp_gw
  n_gw=${n_gw:-$temp_gw}
  read -p "Enter DNS: (default: $n_dns): " temp_dns
  n_dns=${n_dns:-$temp_dns}
  read -p "Enter Hostname (default: $n_hostname): " temp_hostname
  n_hostname=${n_hostname:-$temp_hostname}
  read -p "Enter Bucket URL (default: sos-at-vie-1.exo.io): " BUCKET_URL
  BUCKET_URL=${BUCKET_URL:-sos-at-vie-1.exo.io}
  echo -e "\e[32mSettings : \n \e[0mIP address: $n_ip \n Network mask: $n_mask \n Gateway: $n_gw \n DNS: $n_dns \n Hostname: $n_hostname \n BUCKET_URL: $BUCKET_URL"

  read -p "Press Enter to continue ... "
}

#
#  OS-SPECIFIC FUNCTIONS add 
#

# Function for handling Windows OS
handle_windows() {
  echo -e "\e[32mHandling Windows OS...\e[0m"
  prompt_for_settings "$n_ip" "$n_mask" "$n_gw" "$n_dns" "$BUCKET_URL" "$n_hostname"
  configure_network_interfaces "$n_ip" "$n_mask" "$n_gw" "$n_dns" "$BUCKET_URL" "$n_hostname"
  check_and_mount_s3_bucket "$BUCKET_URL"
  create_backup "$n_hostname"
}

# Function for handling Linux OS
handle_linux() {
  echo -e "\e[32mHandling Linux OS...\e[0m"
  # find root lvm
  root_lvm=$(lvs | grep -iP ".*root|.*ubuntu*|.*rhel*" | tr -s ' ' | cut -d ' ' -f 3)
  echo -e "\e[32mFound root VG \e[0m$root_lvm"

  # Mount LVM volumes
  for lvm in $root_lvm; do
      lvm_path=$(lvdisplay $root_lvm | grep -iP ".*root|.*ubuntu" | grep "LV Path" | tr -s ' ' | cut -d ' ' -f 4)
      echo -e "\e[32mmount LV\e[0m $lvm_path\e[32m from VG\e[0m $lvm\e[32m to /mnt\e[0m"
      mount $lvm_path /mnt
  done

  n_hostname=$(cat /mnt/etc/hostname)
  echo -e "\e[32mFound hostname \e[0m $n_hostname"

    # if ls /mnt/etc/sysconfig/network-scripts/ifcfg-* | tr ' ' '\n' > /dev/null 2>&1 || ls /mnt/etc/NetworkManager/system-connections/ | tr ' ' '\n' > /dev/null 2>&1; then
    #     # Network configuration found
    #     echo -e "\e[32mNetwork configuration found\e[0m"

    #     # Find network configuration
    #     if ls /mnt/etc/sysconfig/network-scripts/ifcfg-* ; then
    #         ifcfgs=$(ls /mnt/etc/sysconfig/network-scripts/ifcfg-* | tr ' ' '\n')
    #         for ifcfg in $ifcfgs; do
    #             echo -e "\e[32mSearching in \e[0m $ifcfg"
    #             if [ -z "$(grep 'GATEWAY' $ifcfg | cut -d '=' -f 2)" ]; then
    #                 echo -e "\e[32mNo gateway in \e[0m $ifcfg\n"
    #             else
    #                 echo -e "\e[32mFound gateway in \e[0m $ifcfg\n"
    #                 n_if=$(basename $ifcfg)
    #                 n_gw=$(grep 'GATEWAY' $ifcfg | cut -d '=' -f 2)
    #                 n_mask=$(grep 'NETMASK' $ifcfg | cut -d '=' -f 2)
    #                 n_ip=$(grep 'IPADDR' $ifcfg | cut -d '=' -f 2)
    #                 n_dns=$(grep 'nameserver' /mnt/etc/resolv.conf | cut -d ' ' -f 2)
    #             fi
    #         done
    #     else
    #         if ls /mnt/etc/NetworkManager/system-connections/* > /dev/null 2>&1; then
    #             files=$(ls /mnt/etc/NetworkManager/system-connections/*.nmconnection | tr ' ' '\n')
    #             for file in $files; do
    #                 echo -e "\e[32mSearching in \e[0m $file"
    #                 gateway_line=$(grep 'gateway' $file | cut -d '=' -f 2)
    #                 if [ -z "$gateway_line" ]; then
    #                     echo -e "\e[32mNo gateway in \e[0m $file\n"
    #                 else
    #                     echo -e "\e[32mFound gateway in \e[0m $file\n"
    #                     n_if=$(basename $file)
    #                     n_gw=$(echo $gateway_line | cut -d ',' -f 2)
    #                     n_ip_mask=$(echo $gateway_line | cut -d ',' -f 1)
    #                     n_ip=$(echo $n_ip_mask | cut -d '/' -f 1)
    #                     n_mask=$(echo $n_ip_mask | cut -d '/' -f 2)
    #                     n_dns=$(grep 'dns' $file | cut -d '=' -f 2)
    #                 fi
    #             done
    #         fi
    #     fi
    # fi
  linux_auto_network
  # Prompt user to input network variables
  echo -e "\e[32mStarting prompt_for_settings $n_ip $n_mask $n_gw $n_dns $BUCKET_URL $n_hostname \e[0m"
  # read -p "Press Enter to continue ... "
  prompt_for_settings "$n_ip" "$n_mask" "$n_gw" "$n_dns" "$BUCKET_URL" "$n_hostname"
  configure_network_interfaces "$n_ip" "$n_mask" "$n_gw" "$n_dns" "$BUCKET_URL" "$n_hostname"
  check_and_mount_s3_bucket "$BUCKET_URL"
  create_backup "$n_hostname"

}

linux_auto_network () {

    if ls /mnt/etc/sysconfig/network-scripts/ifcfg-* | tr ' ' '\n' > /dev/null 2>&1 || ls /mnt/etc/NetworkManager/system-connections/ | tr ' ' '\n' > /dev/null 2>&1; then
        # Network configuration found
        echo -e "\e[32mNetwork configuration found\e[0m"

        # Find network configuration
        if ls /mnt/etc/sysconfig/network-scripts/ifcfg-* ; then
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
        else
            if ls /mnt/etc/NetworkManager/system-connections/* > /dev/null 2>&1; then
                files=$(ls /mnt/etc/NetworkManager/system-connections/*.nmconnection | tr ' ' '\n')
                for file in $files; do
                    echo -e "\e[32mSearching in \e[0m $file"
                    gateway_line=$(grep 'gateway' $file | cut -d '=' -f 2)
                    if [ -z "$gateway_line" ]; then
                        echo -e "\e[32mNo gateway in \e[0m $file\n"
                    else
                        echo -e "\e[32mFound gateway in \e[0m $file\n"
                        n_if=$(basename $file)
                        n_gw=$(echo $gateway_line | cut -d ',' -f 2)
                        n_ip_mask=$(echo $gateway_line | cut -d ',' -f 1)
                        n_ip=$(echo $n_ip_mask | cut -d '/' -f 1)
                        n_mask=$(echo $n_ip_mask | cut -d '/' -f 2)
                        n_dns=$(grep 'dns' $file | cut -d '=' -f 2)
                    fi
                done
            fi
        fi
    fi


  
}

# Function for handling Unknown OS
handle_unknown() {
  echo -e "\e[32mHandling Unknown OS...\e[0m"
  # Add logic for unknown OS here
  echo -e "\e[31mUnknown OS type detected. Exiting script.\e[0m"
  exit 1
}


# Call the appropriate function based on OS_TYPE
case "$OS_TYPE" in
  "Windows")
    read -p "Confirm handling Windows OS (Y/n): " confirm
    confirm=${confirm:-Y}
    if [ "$confirm" = "Y" ] || [ "$confirm" = "y" ]; then
      handle_windows
    else
      echo -e "\e[31mOperation cancelled. Exiting script.\e[0m"
      exit 1
    fi
    ;;
  "Linux")
    read -p "Confirm handling Linux OS (Y/n): " confirm
    confirm=${confirm:-Y}
    if [ "$confirm" = "Y" ] || [ "$confirm" = "y" ]; then
      handle_linux
    else
      echo -e "\e[31mOperation cancelled. Exiting script.\e[0m"
      exit 1
    fi
    ;;
  "Unknown")
    read -p "Confirm handling Unknown OS (Y/n): " confirm
    confirm=${confirm:-Y}
    if [ "$confirm" = "Y" ] || [ "$confirm" = "y" ]; then
      handle_unknown
    else
      echo -e "\e[31mOperation cancelled. Exiting script.\e[0m"
      exit 1
    fi
    ;;
  *)
    echo -e "\e[31mInvalid OS type detected. Exiting script.\e[0m"
    exit 1
    ;;
esac

