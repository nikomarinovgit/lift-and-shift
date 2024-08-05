#!/bin/bash
disks=$(lsblk -d | grep sd | cut -d ' ' -f 1);
for b in $disks; do
    if [ -z "$(dd if=/dev/$b bs=512 count=1 2>/dev/null | hexdump -C | grep "EFI PART")" ] ; then
        echo $b is not EFI ;
    else
        boot_vol="$b" ;
        boot_method="EFI" ;
    fi
    if [ -z "$(dd if=/dev/$b bs=512 count=1 2>/dev/null | hexdump -C | grep '55 aa')" ] ; then
            echo $b is not BIOS ;
    else
        boot_vol="$b" ; 
        boot_method="BIOS" ;
    fi
done

echo -e "boot is $boot_vol and method is $boot_method\n";

if [ "$(pvdisplay | grep "$boot_vol")" ] ; then

    for p in $( pvs | tail -n +2| tr -s ' ' | cut -d ' ' -f 2); do
        echo Using PV $p ;

            for v in $(pvs $p | tail -n +2| tr -s ' ' | cut -d ' ' -f 3); do
                echo Using VG $v ;
                #lv_path=$(lvdisplay $v | grep "LV Path" | tr -s ' ' | cut -d ' ' -f 4);
                #echo -e "Path to LV $lv_path";

                # for lv in $(lvs $v | tail -n +2| tr -s ' ' | cut -d ' ' -f 2); do
                # echo Using LV $lv ;
                # lv_path=$(lvdisplay $v | grep "LV Path" | tr -s ' ' | cut -d ' ' -f 4);
                # echo -e "Path to LV $lv_path";


                # done
            done
        # lv_path=$(lvdisplay $v | grep "LV Path" | tr -s ' ' | cut -d ' ' -f 4);
        # echo -e "Path to LV $lv_path";

    done


    # pv_name=$(pvdisplay | grep "$boot_vol" | tr -s ' ' | cut -d ' ' -f 4);
    # echo -e "$boot_vol has these PVs \n $pv_name\n" ;

    # vgs=$(pvs | tail -n +2| tr -s ' ' | cut -d ' ' -f 3);
    # echo -e "$pv_name hase these VGs \n $vgs\n" ;

    # lvms=$(lvs | tail -n +2| tr -s ' ' | cut -d ' ' -f 2);
    # echo -e "$pv_name hase these VGs \n $vgs\n" ;

    # for v in $lvms; do
    #     echo Using LV $v ;
    #     lv_path=$(lvdisplay $v | grep "LV Path" | tr -s ' ' | cut -d ' ' -f 4);
    #     echo -e "Path to LV $lv_path";

    # done

else
    echo $boot_vol has no PV ; 
fi

# echo $boot_vol has PV $pv_name ;
# echo $boot_vol has VG $vg_name ;




# echo boot disk is $boot ;

# echo "/usr/sbin/ocs-sr -q2 -c -j2 -z1p -i 0 -sfsck -scs -senc -p choose savedisk vlhydak003-2024-07-18-13-img $(echo $disks | tr '\n' ' ') "

echo "A1 custum clonezilla";
echo $(date);

# /bin/bash --




# /usr/sbin/ocs-sr -q2 -c -j2 -z1p -i 0 -sfsck -scs -senc -p choose savedisk vlhydak003-2024-07-18-13-img sda sdb


# read -p "Press Enter to continue..." ;
