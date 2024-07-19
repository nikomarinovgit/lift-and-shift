#############################################################################################3
# home_folder=/home/partimag
# source_folder=to_restore

cnvt-ocs-dev -d /home/partimag to_restore sda vda

# cnvt-ocs-dev -d /home/partimag to_restore sdb vda4

vgremove vg_sys -f
wipefs -a /dev/vda
sfdisk /dev/vda < vda-pt.sf

gunzip -c $(ls vda1*) | partclone.$(ls vda1* | cut -d '.' -f 2 | cut -d '-' -f 1) -s - -O /dev/vda1 -W -r -F

for lvm in $(ls lvm_vg_*.conf); do
    dev_uuid=$(cat $lvm | grep -m 1 -B 1 "device" | grep id | cut -d '"' -f 2) ;
    dev_name=$(cat $lvm | grep -m 1 "device" | cut -d '"' -f 2) ;
    vg_name=$(echo $lvm | cut -d '.' -f 1 | cut -c 5-) ;

    [ -e "$lvm.bak" ] && echo -e "\e[32mBackup exists $lvm.bak\e[0m " || echo -e "\e[31mBackup does not exist. Creating...\e[0m" ; cp $lvm $lvm.bak ;

    if [[ "$dev_name" =~ /dev/vda* ]]; then
        echo -e "\e[32m VG device is $dev_name so we continue ...\e[0m ";
    else
        echo -e "\e[31m VG device is $dev_name so i'm fixing that to .\e[0m " ;
        # sed -i 's|$dev_name|/dev/vda3|g' vg_sys-backup.vg

    fi
    


    if [[ "$dev_name" =~ /dev/vda* ]]; then
        echo Then becouse $dev_name ;
        cat $lvm | grep -m 1 -B 1 "device" | grep id | cut -d '"' -f 2 ;
        cat $lvm | grep -m 1 "device" | cut -d '"' -f 2 ;
        pvcreate -u $dev_uuid $dev_name --restorefile $lvm ;
        echo file to restore $lvm and the vg name is $vg_name ;
        vgcfgrestore -f $lvm $vg_name ;
        vgchange -ay $vg_name ;
    else
        echo -e "\e[32m Doing nothing becouse $dev_name \e[0m ";
    fi
done

for vg in $(ls -h vg_sys-*.gz); do 
    echo -e "\e[32m Processing \e[31m $vg \e[32m into \e[31m $( ls -h $vg* | cut -d '.' -f 1) \e[32m \e[0m "; 
    gunzip -c $vg | partclone.ext4 -s - -O $( ls -h $vg* | cut -d '.' -f 1) -W -r -F ;
done

gunzip -c vda3.vfat-ptcl-img.gz | partclone.vfat -s - -O /dev/vda3 -W -r -F
