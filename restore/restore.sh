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

# Unmount /mnt if mounted
umount /mnt 2> /dev/null || true

#
#   GENERAL FUNCTIONS
#

usage() {
    echo "Usage: $0 <backup_folder>"
    echo "  <backup_folder>  The directory containing the backup to restore"
    exit 1
}

# Check if the first parameter is provided
if [ -z "$1" ]; then
    usage
fi

echo -e "\e[32mRestoring $1\e[m" ;

if [ ! -d "/home/partimag/$1" ]; then
    echo -e "\e[31mError: Backup folder /home/partimag/$1 does not exist.\e[0m"
    exit 1
fi

read -p "Are you sure you want to restore /home/partimag/$1? (Y/n) " -n 1 -r
echo    # move to a new line
REPLY=${REPLY:-Y}  # default to 'Y' if no input

if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi


wipe_vda() {
    echo -e "\e[32mWiping /dev/vda with force\e[m"
    umount /mnt/root/boot/ > /dev/null || true
    umount /mnt/root/ > /dev/null || true
    vgchange -an > /dev/null || true
    vgremove -f $(vgdisplay -c | cut -d: -f1) > /dev/null || true
    wipefs -a /dev/vda -f > /dev/null || true
    sleep 1 > /dev/null || true
    lsblk
    echo -e "\e[32mvda should be clean here\e[m"
    rm *.tmp *.bak > /dev/null || true
}

sda_to_vda() {
    local backup_dir="/home/partimag/$1"

    if [ -e "$backup_dir/vda-pt.sf" ]; then
        echo -e "\e[32mClonezilla backup is vda so we continue...\e[m"
    else
        echo -e "\e[32mChanging volume in Clonezilla backup from sda to vda\e[m"
        cnvt-ocs-dev -b -d /home/partimag $1 sda vda
    fi

    if [ -e "$backup_dir/blkdev.list.tmp" ]; then
        echo -e "\e[32mblkdev.list.tmp exists.\e[0m"
    else
        echo -e "\e[31mblkdev.list.tmp does not exist. Creating it...\e[0m"
        cp "$backup_dir/blkdev.list" "$backup_dir/blkdev.list.tmp"
    fi

    if [ -e "$backup_dir/parts.tmp" ]; then
        echo -e "\e[32mparts.tmp exists\e[0m"
    else
        echo -e "\e[31mparts.tmp does not exist. Creating it ...\e[0m"
        cp "$backup_dir/parts" "$backup_dir/parts.tmp"
    fi

    echo -e "\e[32mRestoring vda partitions from vda-pt.sf\e[m"
}

initialize_vda () {

    local backup_dir="/home/partimag/$1"
    local hidden_data_file="$backup_dir/vda-hidden-data-after-mbr"
    echo -e "\e[32mStarting partitioning of /dev/vda\e[m"

    # Zero out the end of the disk to clear any old partition table data
    dd if=/dev/zero of=/dev/vda bs=512 seek=209714176 count=1024

    # Create a new partition table
    parted -s /dev/vda mklabel msdos

    # Restore the partition table from the backup
    sfdisk --force /dev/vda < "$backup_dir/vda-pt.sf"

    # Restore the MBR
    ocs-restore-mbr --ocsroot /home/partimag "$1" vda

    # Restore hidden data after MBR
    # dd if="$backup_dir/vda-hidden-data-after-mbr" of=/dev/vda seek=1 bs=512 count=2047

    if [ -e "$hidden_data_file" ]; then
        echo -e "\e[32mRestoring hidden data from $hidden_data_file\e[m"
        dd if="$hidden_data_file" of=/dev/vda seek=1 bs=512 count=2047
    else
        echo -e "\e[31mError: File $hidden_data_file does not exist.\e[m"
        # exit 1
    fi

    # Force sync the disk layout
    sync
    partprobe /dev/vda
    echo -e "\e[32mPartitioning of /dev/vda complete\e[m"

}

partition_vda() {

    # Create a new partition
    echo -e "\e[32mCreate partition:\e[0m"
    echo -e "n\np\n\n\n\nw" | fdisk /dev/vda

    # Force sync the disk layout
    sync
    partprobe /dev/vda
    sleep 5

    # Display the updated partition layout
    echo -e "\e[32mUpdated partition layout:\e[m"

}

restore_vdas () {
    local backup_dir="/home/partimag/$1"
    
    for p in $(cat "$backup_dir/parts" | tr ' ' '\n' | grep -E "^sd.{1}$"); do
        sed -i "s|$p|vda$(($(lsblk -l /dev/vda | grep -v 'lvm' | wc -l) -2 ))|g" "$backup_dir/blkdev.list.tmp"
        sed -i "s|$p|vda$(($(lsblk -l /dev/vda | grep -v 'lvm' | wc -l) -2 ))|g" "$backup_dir/parts.tmp"
    done

}

extract_all_acrchive_files() {

    zst_files_to_extract=$(ls /home/partimag/$1/*.a[a-z] 2> /dev/null || true )
    gz_files_to_extract=$(ls /home/partimag/$1/*.a[a-z][a-z]  2> /dev/null || true )

    if [ ! -z "$zst_files_to_extract" ]; then
        for files in "$zst_files_to_extract" ; do
            extract_zst_files "$1"
        done
    else
        echo -e "\e[33mNo zst multi-files archive found\e[m"
    fi

    if [ ! -z "$gz_files_to_extract" ]; then
        for files in "$gz_files_to_extract" ; do
            extract_gz_files "$1"
        done
    else
        echo -e "\e[33mNo gz multi-files archive found\e[m"
    fi

}

extract_gz_files() {
    local backup_dir="/home/partimag/$1"
    for file in $(ls $backup_dir/*.gz.a[a-z][a-z] | cut -d '.' -f -3 | uniq ); do
        echo -e "\e[32mExtracting\e[0  $( ls $file.a[a-z][a-z] | tr '\n' ' ') | zcat > $file"
        cat $( ls $file.a[a-z][a-z] | tr '\n' ' ') | zcat > $file 
    done
}

extract_zst_files() {
    local backup_dir="/home/partimag/$1"
    for file in $(ls $backup_dir/*.zst.a[a-z] | cut -d '.' -f -3 | uniq ); do
        echo -e "\e[32mExtracting\e[0 $( ls $file.a[a-z] | tr '\n' ' ') | zstdcat > $file"
        cat $( ls $file.a[a-z] | tr '\n' ' ') | zstdcat > $file 
    done
}


restore_vdas() {
    local backup_dir="/home/partimag/$1"

    for vdas in $(lsblk -l | tr ' ' '\n' | grep -E "^vda.{1}$" | cut -d ' ' -f 1); do
        echo -e "\e[32mProcessing $vdas\e[0m"
        echo -e "\e[32mChecking for$backup_dir/$vdas*.zst \e[0m"
        read -p "Enter to continue..." -n 1 -r
        if [ -f "$backup_dir/$vdas*.zst" ]; then
            echo -e "\e[32mDoing $vdas with existing $(ls $backup_dir/$vdas*.zst) exist\e[0m"
            # ocs-resize-part  --batch /dev/$vdas ;
            # gunzip -c $(ls $backup_dir/$vdas*) | partclone.$(ls $backup_dir/$vdas* | cut -d '.' -f 2 | cut -d '-' -f 1) -s - -O /dev/$vdas -r -F ;

            gunzip -c $(ls $backup_dir/$vdas*.zst) | partclone.restore -d3 -s - -O /dev/$vdas
            # pigz -d -c $(ls $backup_dir/$vdas*) | LC_ALL=C partclone.$(ls $backup_dir/$vdas* | cut -d '.' -f 2 | cut -d '-' -f 1) -z 10485760 -s - -r -o /dev/$vdas ;
        else
            echo -e "\e[33m$vdas no file. Must be LVM. See you later alligator! \e[0m"
        fi
    done
}

# wipe_vda
# sda_to_vda "$1"
# initialize_vda "$1"
# partition_vda "$1"
# extract_all_zst_files "$1"
extract_all_acrchive_files "$1"
# restore_vdas "$1"

read -p "Enter to continue to FINAL..." -n 1 -r










# [ -e "vda-pt.sf" ] && echo -e "\e[32mClonezilla backup is vda so we continue...\e[m" || ( echo -e "\e[32mChanging volume in Clonezilla backup from sda to vda\e[m" ; cnvt-ocs-dev -b -d /home/partimag $1 sda vda ; )
# [ -e "blkdev.list.tmp" ] && echo -e "\e[32mblkdev.list.tmp exists.\e[0m " || ( echo -e "\e[31mblkdev.list.tmp does not exist. Creating it...\e[0m" ; cp blkdev.list blkdev.list.tmp ; )
# [ -e "parts.tmp" ] && echo -e "\e[32mparts.tmp exists\e[0m " || ( echo -e "\e[31mparts.tmp does not exist. Creating it ...\e[0m" ; cp parts parts.tmp ; )
# echo -e "\e[32mRestoring vda partitions from vda-pt.sf\e[m" ; 

# dd if=/dev/zero of=/dev/vda bs=512 seek=209714176 count=1024 ;
# parted -s /dev/vda mklabel msdos ;
# sfdisk --force /dev/vda < vda-pt.sf ;
# ocs-restore-mbr --ocsroot /home/partimag $dir_to_restore vda ;
# dd if=vda-hidden-data-after-mbr of=/dev/vda seek=1 bs=512 count=2047 ;

# lsblk ; echo -e "\e[32mvda should be partitioned vith vda-pt.sf\e[m" ;


# echo -e "\e[32mCreate partition:\e[0m" ; echo -e "n\np\n\n\nw" | sudo fdisk /dev/vda ; 
# lsblk;

# for p in $(cat parts | tr ' ' '\n' |  grep -E "^sd.{1}$" ); do
#     sed -i "s|$p|vda$(($(lsblk -l /dev/vda | grep -v 'lvm' | wc -l) -2 ))|g" blkdev.list.tmp ;
#     sed -i "s|$p|vda$(($(lsblk -l /dev/vda | grep -v 'lvm' | wc -l) -2 ))|g" parts.tmp ;
# done

# for vdas in $(lsblk -l | tr ' ' '\n' | grep -E "^vda.{1}$" | cut -d ' ' -f 1); do
#     if [ -f $vdas*.gz* ]; then
#         echo -e "\e[32mDoing $vdas with existing $(ls $vdas*.gz*) exist\e[0m" ;
#         # ocs-resize-part  --batch /dev/$vdas ;
#         # gunzip -c $(ls $vdas*) | partclone.$(ls $vdas* | cut -d '.' -f 2 | cut -d '-' -f 1) -s - -O /dev/$vdas -r -F ;
#         gunzip -c $(ls $vdas*) | partclone.restore -d3 -s - -O /dev/$vdas ;
#         # pigz -d -c $(ls $vdas*) | LC_ALL=C partclone.$(ls $vdas* | cut -d '.' -f 2 | cut -d '-' -f 1) -z 10485760 -s - -r -o /dev/$vdas ;
#     else
#         echo -e "\e[33m$vdas no file. Must be LVM. See you later aligator! \e[0m";
#     fi
# done

# for lvm in $(ls lvm_vg_*.conf); do
#     [ -e "$lvm.bak" ] && echo -e "\e[32m$lvm.bak exists\e[0m " || ( echo -e "\e[31m$lvm.bak does not exist. Creating it...\e[0m" ; cp $lvm $lvm.bak ; )
#     dev_uuid=$(cat $lvm.bak | grep -m 1 -B 1 "device" | grep id | cut -d '"' -f 2) ;
#     dev_name=$(cat $lvm.bak | grep -m 1 "device" | cut -d '"' -f 2) ;
#     vg_name=$(echo $lvm.bak | cut -d '.' -f 1 | cut -c 5-) ;

#     if [[ "$dev_name" =~ /dev/vda* ]]; then
#         echo -e "\e[32m VG device is $dev_name so we continue ...\e[0m ";
#     else
#         new_dev_name=$(cat blkdev.list.tmp | grep -m 1 -B 1 "$vg_name"| grep vd | cut -d ' ' -f 1);
#         echo -e "\e[31m VG device is $dev_name so i'm fixing that to $new_dev_name for $vg_name.\e[0m " ;
#         sed -i "s|$dev_name|$new_dev_name|g" $lvm.bak ;
#         dev_to_replace=$(echo $dev_name | cut -d "/" -f 3);
#         echo $dev_to_replace will become $new_dev_name in $lvm.bak ;
#         sed -i "s|$dev_to_replace|$new_dev_name|g" $lvm.bak ;
#     fi

#     echo -e "\e[97mpvcreate -u $dev_uuid /dev/$new_dev_name --restorefile $lvm.bak -f \e[0m ";
#     pvcreate -u $dev_uuid /dev/$new_dev_name --restorefile $lvm.bak -f ;

#     echo -e "\e[97mvgcfgrestore -f $lvm.bak $vg_name --force \e[0m ";
#     vgcfgrestore -f $lvm.bak $vg_name --force ;

#     echo -e "\e[97mpvresize /dev/$new_dev_name \e[0m ";
#     pvresize /dev/$new_dev_name ;

#     echo -e "\e[97mvgchange -ay $vg_name ; \e[0m ";
#     vgchange -ay $vg_name ;
#     pvscan ; vgscan ; lvscan ;

#     for vg in $(ls -h $vg_name-*.gz); do
#         echo -e "\e[32m Processing\e[31m $vg\e[32m into\e[31m $( ls -h $vg* | cut -d '.' -f 1)\e[0m ";

#         # lvresize -L +1918m /dev/vg_sys/vol_opt_Eracent
#         # e2fsck -f -y /dev/$vg_name/vol_opt_Eracent; resize2fs -p -f /dev/vg_sys/vol_opt_Eracent
#         # e2fsck -f -y $( ls -h $vg* | cut -d '.' -f 1) ;
#         # resize2fs -p -f $( ls -h $vg* | cut -d '.' -f 1) ;
#         # gunzip -c $vg | partclone.$(echo $vg | cut -d '.' -f 2 | cut -d '-' -f 1) -s - -O $( ls -h $vg* | cut -d '.' -f 1) -W -r -F ;

#         # echo -e "\e[97m gunzip -c $vg | partclone.restore -d3 -s - -O /dev/$( ls -h $vg* | cut -d '.' -f 1 | cut -d '-' -f 1)/$(ls -h $vg* | cut -d '.' -f 1 | cut -d '-' -f 2) -W -F -C; \e[0m"  ;
#         # gunzip -c $vg | partclone.restore -d3 -s - -O /dev/$( ls -h $vg* | cut -d '.' -f 1 | cut -d '-' -f 1)/$(ls -h $vg* | cut -d '.' -f 1 | cut -d '-' -f 2) -W -F -C;
        
#         # gunzip -c $vg | partclone.info -L tmp.info -s - ;
#         # echo "$(($(cat tmp.info | grep "Device size" | cut -d '=' -f 2 | cut -d ' ' -f 2) * 4096 / 1024 / 1024 / 1024))" ;
#         # # lvs  --units b $vg_name/$(echo $vg | cut -d '.' -f 1 | cut -d '-' -f 2) ;
#         # echo "$(($(lvs -o lv_size --units b $vg_name/$(echo $vg | cut -d '.' -f 1 | cut -d '-' -f 2) | grep -v 'LSize' | cut -d 'B' -f 1 ) / 1024 / 1024 / 1024))"; 

#         # rm tmp.info ;
        
        
#         # gunzip -c $vg | partclone.restore -d3 -s - -O /dev/$( ls -h $vg* | cut -d '.' -f 1 | cut -d '-' -f 1)/$(ls -h $vg* | cut -d '.' -f 1 | cut -d '-' -f 2) -W -F;
        
#         # gunzip -c $vg | partclone.restore -d3 -s - -O /dev/mapper/$( ls -h $vg* | cut -d '.' -f 1) ;
#         echo -e "\e[97m gunzip -c $vg | partclone.$(echo $vg | cut -d '.' -f 2 | cut -d '-' -f 1) -s - -O /dev/mapper/$( ls -h $vg* | cut -d '.' -f 1) -W -r -F  \e[0m"  ;
#         # dd if=/dev/zero of=/dev/mapper/$( ls -h $vg* | cut -d '.' -f 1) bs=1025M status=progress ;
#         gunzip -c $vg | partclone.$(echo $vg | cut -d '.' -f 2 | cut -d '-' -f 1) -s - -O /dev/mapper/$( ls -h $vg* | cut -d '.' -f 1) -W -r -F ;
#         # echo -e "\e[97m pigz -d -c $vg | LC_ALL=C partclone.$(echo $vg | cut -d '.' -f 2 | cut -d '-' -f 1) -z 10485760  -s - -r -o $( ls -h $vg* | cut -d '.' -f 1) \e[0m" ;
#         # pigz -d -c $vg | LC_ALL=C partclone.$(echo $vg | cut -d '.' -f 2 | cut -d '-' -f 1) -z 10485760  -s - -r -o $( ls -h $vg* | cut -d '.' -f 1) ;
#     done
# done



# [ -e "/mnt/root" ] && echo -e "\e[32mExists\e[m" || ( echo -e "\e[32mDon't exist\e[0m" ; mkdir /mnt/root ; ) ;

# if mount | grep "^/dev/mapper/vg_sys-root on /mnt/root*" ; then
#   echo "/dev/mapper/vg_sys-root is mounted on /mnt/root"
# else
#   echo "/dev/mapper/vg_sys-root is not mounted on /mnt/root"
#   mount /dev/mapper/vg_sys-root /mnt/root/
# fi

# if mount | grep "^/dev/vda1 on /mnt/root/boot*" ; then
#   echo "/dev/vda1 is mounted on /mnt/root/boot/"
# else
#   echo "/dev/vda1 is not mounted on /mnt/root/boot" ;
#   mount /dev/vda1 /mnt/root/boot/ ;
# fi

# cat << EOF | chroot /mnt/root /bin/bash
# version=\$(grubby --default-kernel 2>/dev/null | cut -c15- ) ;
# echo grub load as default kernel version - \$version ;

# [ -e /boot/initramfs-\$version.img.bak ] && echo Backup exists || ( echo Backup don\'t exist ; cp /boot/initramfs-\$version.img /boot/initramfs-\$version.img.bak ; ) ;
# [ -e /etc/dracut.conf.d/virtio.conf ] && echo virtio.conf exists || ( echo virtio.conf don\'t exist ; echo 'add_drivers+=" virtio_scsi virtio_blk "' > /etc/dracut.conf.d/virtio.conf ;) ;
# [ -e /var/tmp ] && echo /var/tmp exists || ( echo /var/tmp don\'t exist ; mkdir /var/tmp ;) ;

# if lsinitrd /boot/initramfs-\$version.img | grep -i virtio ; then 
# echo Modules virtio_scsi virtio_blk found in kernel \$version ; 
# else 
# dracut -f --add-drivers "virtio_scsi virtio_blk" /boot/initramfs-\$version.img \$version ;
# fi

# sed -i 's/^root:x:/root::/' /etc/passwd

# EOF