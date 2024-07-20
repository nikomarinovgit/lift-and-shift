#!/bin/bash

echo -e "\e[32mWiping /dev/vda with force\e[m";
vgchange -an ;
vgremove -f $(vgdisplay -c | cut -d: -f1)
wipefs -a /dev/vda -f ;
# lsblk;
# read -p "Press Enter to continue..." ;
# cnvt-ocs-dev -b -d /home/partimag to_restore sda vda
sfdisk /dev/vda < vda-pt.sf
echo -e "\e[32mFirst we do partitions:\e[0m"
parts=$(cat parts | tr ' ' '\n' |  grep -E "^sd.{1}$" )
# lsblk;
# read -p "Press Enter to continue..." ;

for p in $parts; do
    next_vda=$(($(lsblk -l /dev/vda | grep -v 'lvm' | wc -l) - 1 ));
    next_vda_size=$(cat blkdev.list | grep "$p" | tr -s ' ' | uniq | head -n 1 | cut -d ' ' -f 3) ;
    echo -e "\e[32mCreating $p as vda$next_vda with size $next_vda_size\e[m";
    sed -i "s|$p|vda$next_vda|g" blkdev.list ;
    sed -i "s|$p|vda$next_vda|g" parts ;
    # echo -e "n\ne\n\n\n+$next_vda_size\nw" | sudo fdisk /dev/vda ;
    echo -e ",,,\n,,,$next_vda_size\n" | sudo sfdisk /dev/vda
    # echo -e "n\ne\n\n\n+50G\nw" | sudo fdisk /dev/sdX
done

existing_vda=$(lsblk -l | tr ' ' '\n' | grep -E "^vda.{1}$" | cut -d ' ' -f 1)
echo -e "\e[32mNow to populate partitions:\e[0m" ;
# echo $existing_vda ;
# read -p "Press Enter to continue..." ;

for vdas in $existing_vda; do
    echo Doing $vdas;
    # read -p "Press Enter to continue..." ;
    if [ -f $vdas* ]; then
        echo -e "\e[32m$(ls $vdas*) exist\e[0m" ;
        gunzip -c $(ls $vdas*) | partclone.$(ls $vdas* | cut -d '.' -f 2 | cut -d '-' -f 1) -s - -O /dev/$vdas -W -r -F ;
    else
        echo -e "\e[33m$vdas no file. Must be LVM.\e[0m";
    fi
done



echo -e "\e[32mNow to populate LVMs:\e[0m"
# lsblk;
vgchange -an
vgremove -f $(vgdisplay -c | cut -d: -f1)

for lvm in $(ls lvm_vg_*.conf); do
    dev_uuid=$(cat $lvm | grep -m 1 -B 1 "device" | grep id | cut -d '"' -f 2) ;
    dev_name=$(cat $lvm | grep -m 1 "device" | cut -d '"' -f 2) ;
    vg_name=$(echo $lvm | cut -d '.' -f 1 | cut -c 5-) ;

    [ -e "$lvm.bak" ] && echo -e "\e[32mBackup exists $lvm.bak\e[0m " || echo -e "\e[31mBackup does not exist. Creating...\e[0m" ; cp $lvm $lvm.bak ;

    echo Device with name $dev_name with UUID $dev_uuid and VG $vg_name

    read -p "Press Enter to continue..."

    if [[ "$dev_name" =~ /dev/vda* ]]; then
        echo -e "\e[32m VG device is $dev_name so we continue ...\e[0m ";
    else
        brake;
        # dev_to_replace=$(echo $dev_name | cut -d "/" -f 3);
        # new_dev_name=$(cat blkdev.list | grep -m 1 -B 1 "$vg_name"| grep vd | cut -d ' ' -f 1);
        # # dev_name=$(cat blkdev.list | grep -m 1 -B 1 "$vg_name"| grep vd | cut -d ' ' -f 1);
        # echo -e "\e[31m VG device is $dev_name so i'm fixing that to $new_dev_name for $vg_name.\e[0m " ;
        # echo $dev_to_replace will become $new_dev_name in $lvm ;
        # sed -i "s|$dev_to_replace|$new_dev_name|g" $lvm ;
    fi


    pvcreate -u $dev_uuid $dev_name --restorefile $lvm -ff;
    vgcfgrestore -f $lvm $vg_name --force ;
    vgchange -ay $vg_name ;


    # for vg in $(ls -h $vg_name-*.gz); do
    #     echo -e "\e[32m Processing \e[31m $vg \e[32m into \e[31m $( ls -h $vg* | cut -d '.' -f 1) \e[32m \e[0m ";
    #     gunzip -c $vg | partclone.$(echo $vg | cut -d '.' -f 2 | cut -d '-' -f 1) -s - -O $( ls -h $vg* | cut -d '.' -f 1) -W -r -F ;
    # done


done








# for vdas in $existing_vda; do
#     echo Doing $vdas;

#     if [ -f $vdas* ]; then
#         echo -e "\e[32m$(ls $vdas*) exist\e[0m" ;
#         gunzip -c $(ls $vdas*) | partclone.$(ls $vdas* | cut -d '.' -f 2 | cut -d '-' -f 1) -s - -O /dev/$vdas -W -r -F ;
#     else
#         echo -e "\e[33m$vdas no file. Must be LVM\e[0m";

#         for lvm in $(ls lvm_vg_*.conf); do
#             dev_uuid=$(cat $lvm | grep -m 1 -B 1 "device" | grep id | cut -d '"' -f 2) ;
#             dev_name=$(cat $lvm | grep -m 1 "device" | cut -d '"' -f 2) ;
#             vg_name=$(echo $lvm | cut -d '.' -f 1 | cut -c 5-) ;

#             [ -e "$lvm.bak" ] && echo -e "\e[32mBackup exists $lvm.bak\e[0m " || echo -e "\e[31mBackup does not exist. Creating...\e[0m" ; cp $lvm $lvm.bak ;

#             echo Device with name $dev_name with UUID $dev_uuid and VG $vg_name

#             if [[ "$dev_name" =~ /dev/vda* ]]; then
#                 echo -e "\e[32m VG device is $dev_name so we continue ...\e[0m ";
#             else
#                 dev_to_replace=$(echo $dev_name | cut -d "/" -f 3);
#                 new_dev_name=$(cat blkdev.list | grep -m 1 -B 1 "$vg_name"| grep vd | cut -d ' ' -f 1);
#                 echo -e "\e[31m VG device is $dev_name so i'm fixing that to $new_dev_name for $vg_name.\e[0m " ;
#                 echo $dev_to_replace will become $new_dev_name in $lvm ;
#                 sed -i "s|$dev_to_replace|$new_dev_name|g" $lvm ;
#             fi


#             pvcreate -u $dev_uuid $new_dev_name --restorefile $lvm ;
#             vgcfgrestore -f $lvm $vg_name ;
#             vgchange -ay $vg_name ;


#             for vg in $(ls -h $vg_name-*.gz); do
#                 echo -e "\e[32m Processing \e[31m $vg \e[32m into \e[31m $( ls -h $vg* | cut -d '.' -f 1) \e[32m \e[0m ";
#                 gunzip -c $vg | partclone.$(echo $vg | cut -d '.' -f 2 | cut -d '-' -f 1) -s - -O $( ls -h $vg* | cut -d '.' -f 1) -W -r -F ;
#             done


#         done


#     fi

# done