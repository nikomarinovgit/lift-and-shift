#!/bin/bash


# echo "nm-bucket:EXO6e9a69c5809e487b0df721fe:tCQmWdEHtZZWSKbfupP4Qe69c4pFENfRgE9AiXW8xgY" > /root/.passwd-s3fs
# chmod 600 /root/.passwd-s3fs
# s3fs nm-bucket:/ /home/partimag -o url=https://sos-at-vie-1.exo.io -o  passwd_file=/root/.passwd-s3fs

echo 'root:Lxu_if9`94;2Kd<6UQ#2,:t50e*ASRt="fGR8tWV,zvVjcfK@p' | sudo chpasswd
echo 'user:Lxu_if9`94;2Kd<6UQ#2,:t50e*ASRt="fGR8tWV,zvVjcfK@p' | sudo chpasswd
systemctl start ssh


echo "clonezilla-test:EXOdc65249415796c46532f659d:TcxaGSoeUUcBWWVac4Q68q8J3G5ilbREcBg-Gx22VWM" > /root/.passwd-s3fs
chmod 600 /root/.passwd-s3fs
# s3fs clonezilla-test:/ /home/partimag -o url=https://sos-at-vie-1.exo.io -o  passwd_file=/root/.passwd-s3fs
s3fs clonezilla-test:/ /home/partimag -o use_path_request_style -o url=https://sos-at-vie-1.exo.io -o  passwd_file=/root/.passwd-s3fs -o  del_cache -o no_check_certificate  -d




echo "A1 custum clonezilla";
echo $(date);

/bin/bash --

for b in $(lsblk -d | grep sd | cut -d ' ' -f 1); do

        if [[ $(dd if=/dev/$b bs=512 count=2 | hexdump -C | grep "EFI PART") ]]; then
                echo -e "\e[32m$b is EFI\e[0m" ;
        else
                if [[ $(dd if=/dev/$b bs=512 count=2 | hexdump -C | grep "0x55AA") ]]; then
                        echo -e "\e[32m$b is BIOS boot\e[0m" ;
                else
                        echo -e "\e[32m$b is not a boot drive\e[0m" ;
                fi
        fi

done


# /usr/sbin/ocs-sr -q2 -c -j2 -z1p -i 0 -sfsck -scs -senc -p choose savedisk vlhydak003-2024-07-18-13-img sda sdb


read -p "Press Enter to continue..." ;

