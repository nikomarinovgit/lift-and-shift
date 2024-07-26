#!/bin/bash
dir_to_restore="to_restore" ;
echo -e "\e[32mWiping /dev/vda with force\e[m" ; vgchange -an ; vgremove -f $(vgdisplay -c | cut -d: -f1) ; wipefs -a /dev/vda -f ; lsblk; echo -e "\e[32mvda should be clean here\e[m" ; rm *.tmp *.bak ;
[ -e "vda-pt.sf" ] && echo -e "\e[32mClonezilla backup is vda so we continue...\e[m" || ( echo -e "\e[32mChanging volume in Clonezilla backup from sda to vda\e[m" ; cnvt-ocs-dev -b -d /home/partimag $dir_to_restore sda vda ; )
[ -e "blkdev.list.tmp" ] && echo -e "\e[32mblkdev.list.tmp exists.\e[0m " || ( echo -e "\e[31mtep does not exist. Creating it...\e[0m" ; cp blkdev.list blkdev.list.tmp ; )
[ -e "parts.tmp" ] && echo -e "\e[32mparts.tmp exists\e[0m " || ( echo -e "\e[31mparts.tmp does not exist. Creating it ...\e[0m" ; cp parts parts.tmp ; )
echo -e "\e[32mRestoring vda partitions from vda-pt.sf\e[m" ; 

dd if=/dev/zero of=/dev/vda bs=512 seek=209714176 count=1024
parted -s /dev/vda mklabel msdos
LC_ALL=C sfdisk --force /dev/vda < /home/partimag/to_restore/vda-pt.sf 2>&1 | tee -a /var/log/clonezilla.log
dd if=/home/partimag/to_restore/vda-hidden-data-after-mbr of=/dev/vda seek=1 bs=512 count=2047

pigz -d -c /home/partimag/to_restore/vda1.ext4-ptcl-img.gz | LC_ALL=C partclone.ext4 -z 10485760  -L /var/log/partclone.log -s - -r -o /dev/vda1
pigz -d -c /home/partimag/to_restore/vda3.vfat-ptcl-img.gz | LC_ALL=C partclone.vfat -z 10485760  -L /var/log/partclone.log -s - -r -o /dev/vda3


lsblk ; 
echo -e "\e[32mvda should be partitioned vith vda-pt.sf\e[m" ;


# echo -e "\e[32mCreate partition:\e[0m" ; echo -e "n\np\n\n\nw" | sudo fdisk /dev/vda ; lsblk;

for p in $(cat parts | tr ' ' '\n' |  grep -E "^sd.{1}$" ); do
    sed -i "s|$p|vda$(($(lsblk -l /dev/vda | grep -v 'lvm' | wc -l) -2 ))|g" blkdev.list.tmp ;
    sed -i "s|$p|vda$(($(lsblk -l /dev/vda | grep -v 'lvm' | wc -l) -2 ))|g" parts.tmp ;
done

for vdas in $(lsblk -l | tr ' ' '\n' | grep -E "^vda.{1}$" | cut -d ' ' -f 1); do
    if [ -f $vdas*.gz* ]; then
        echo -e "\e[32mDoing $vdas with existing $(ls $vdas*.gz*) exist\e[0m" ;
        gunzip -c $(ls $vdas*) | partclone.$(ls $vdas* | cut -d '.' -f 2 | cut -d '-' -f 1) -s - -O /dev/$vdas -r -F ;
    else
        echo -e "\e[33m$vdas no file. Must be LVM. See you later aligator! \e[0m";
    fi
done

for lvm in $(ls lvm_vg_*.conf); do
    [ -e "$lvm.bak" ] && echo -e "\e[32m$lvm.bak exists\e[0m " || ( echo -e "\e[31m$lvm.bak does not exist. Creating it...\e[0m" ; cp $lvm $lvm.bak ; )
    dev_uuid=$(cat $lvm.bak | grep -m 1 -B 1 "device" | grep id | cut -d '"' -f 2) ;
    dev_name=$(cat $lvm.bak | grep -m 1 "device" | cut -d '"' -f 2) ;
    vg_name=$(echo $lvm.bak | cut -d '.' -f 1 | cut -c 5-) ;

    if [[ "$dev_name" =~ /dev/vda* ]]; then
        echo -e "\e[32m VG device is $dev_name so we continue ...\e[0m ";
    else
        new_dev_name=$(cat blkdev.list.tmp | grep -m 1 -B 1 "$vg_name"| grep vd | cut -d ' ' -f 1);
        echo -e "\e[31m VG device is $dev_name so i'm fixing that to $new_dev_name for $vg_name.\e[0m " ;
        sed -i "s|$dev_name|$new_dev_name|g" $lvm.bak ;
        dev_to_replace=$(echo $dev_name | cut -d "/" -f 3);
        echo $dev_to_replace will become $new_dev_name in $lvm.bak ;
        sed -i "s|$dev_to_replace|$new_dev_name|g" $lvm.bak ;
    fi

    pvcreate -u $dev_uuid $new_dev_name --restorefile $lvm.bak -f ;
    vgcfgrestore -f $lvm.bak $vg_name --force ;
    vgchange -ay $vg_name ;

    for vg in $(ls -h $vg_name-*.gz); do
        echo -e "\e[32m Processing\e[31m $vg\e[32m into\e[31m $( ls -h $vg* | cut -d '.' -f 1)\e[0m ";
        gunzip -c $vg | partclone.$(echo $vg | cut -d '.' -f 2 | cut -d '-' -f 1) -s - -O $( ls -h $vg* | cut -d '.' -f 1) -W -r -F ;
    done
done