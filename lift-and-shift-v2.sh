#   VMware -> Exo

# Create Exo VM (minimum 2 CPU or clonezilla won't start) with init disk as big as possible the soruce (10Gi). Attache " nm-rescue-10GB" bs and security group nm-sg to allow ssh 
exo c i add nm-test-vm02 --disk-size 100 --instance-type Extra-Large  --template "Linux Ubuntu 24.04 LTS 64-bit" --security-group nm-sg -z AT-VIE-1 -Q
exo c bs a " nm-rescue-10GB" nm-test-vm02 -z at-vie-1
echo y | exo c bs d " nm-rescue-10GB" -z at-vie-1
# Create and attache block starage to restore every coresponding disk from source VM.
exo c bs add nm-bs-vm02-60GB --size 60 -z at-vie-1 -Q
exo c bs add nm-bs-vm02-110GB --size 110 -z at-vie-1 -Q
exo c bs a nm-bs-vm02-60GB nm-test-vm02 -z at-vie-1
exo c bs a nm-bs-vm02-110GB nm-test-vm02 -z at-vie-1
# Create TMP block storage bigger than all the gunziped backups.
exo c bs add nm-bs-tmp-160GB --size 160 -z at-vie-1 -Q
exo c bs a nm-bs-tmp-160GB nm-test-vm02 -z at-vie-1 -Q
echo y | exo c bs d nm-bs-tmp-160GB -z at-vie-1
echo y | exo c i stop nm-test-vm02 -Q

# Resize the VM init disk to size as big as all the volumes in the source VM. (Web UI)
echo y | exo c i start --rescue-profile=netboot-efi nm-test-vm02 -Q

# Exo maybe can fix the path in the rescue console...
# iPXE shell
# >dhcp
# >show net0/ip
# 185.150.10.120
sanboot https://boot.netboot.xyz/ipxe/netboot.xyz.iso

# Enter in clonezilla bash shell.
# clonezilla.sh to attache the s3-bucket (( sudo passwd root, sudo passwd... ) & maybe ssh user@REAL-IP)
# Check the Exo VM dev names and size (lsblk)
# Map source VM dev to Exo VM dev.
# Tip: 1. blkdev.list and parts files are in the backup folder).
#      2. The example cnvt-ocs-dev underneath is using to_restore as name of the backup folder.
# cnvt-ocs-dev -d [subdir where backup folder {to_restore} is] [the name of the backup folder {to_restore}] [Source drive] [Destination drive]
# sda -> vda
# sdb -> vdc
# sdc -> vdd
cnvt-ocs-dev -d /home/partimag to_restore sda vda 
cnvt-ocs-dev -d /home/partimag to_restore sdb vdc
cnvt-ocs-dev -d /home/partimag to_restore sdc vdd

# Restore with Clonezilla tui.
sudo clonezilla

# /usr/sbin/ocs-sr -g auto -e1 auto -e2 -c -r -j2 -k0 -scr -p choose restoredisk to_restore vda vdd vde

# Create new parts and PVs on vda
echo -e "n\np\n3\n\n+50G\nw" | sudo fdisk /dev/vda
echo -e "n\np\n4\n\n+100G\nw" | sudo fdisk /dev/vda
pvcreate /dev/vda3
pvcreate /dev/vda4

# Export the VGs and restore them back on the new partitions. 
# blkid to macth :
vgchange -an vg_app
vgchange -an vg_sys

vgcfgbackup -f vg_sys-backup.vg vg_sys
vgcfgbackup -f vg_app-backup.vg vg_app

sed -i 's|/dev/vdd|/dev/vda3|g' vg_sys-backup.vg
sed -i 's|/dev/vde|/dev/vda4|g' vg_app-backup.vg

sed -i "s|"$(blkid -s UUID -o value /dev/vdd)"|"$(blkid -s UUID -o value /dev/vda3)"|g" vg_sys-backup.vg
sed -i "s|"$(blkid -s UUID -o value /dev/vde)"|"$(blkid -s UUID -o value /dev/vda4)"|g" vg_app-backup.vg

vgcfgrestore -f vg_sys-backup.vg  vg_sys
vgcfgrestore -f vg_app-backup.vg  vg_app 

# Detach the matched drives
vgchange -ay vg_app
vgchange -ay vg_sys

# Extract the image if it is compresed (done on the tmp block storage drive)
gunzip -c /home/partimag/1/vg_app-data.xfs-ptcl-img.gz.aaa | partclone.xfs -s - -O /dev/mapper/vg_app-data -W -r -F
gunzip -c /home/partimag/1/vg_sys-audit.xfs-ptcl-img.gz.aaa | partclone.xfs -s - -O /dev/mapper/vg_sys-audit -W -r -F
gunzip -c /home/partimag/1/vg_sys-home.xfs-ptcl-img.gz.aaa | partclone.xfs -s - -O /dev/mapper/vg_sys-home -W -r -F
gunzip -c /home/partimag/1/vg_sys-log.xfs-ptcl-img.gz.aaa | partclone.xfs -s - -O /dev/mapper/vg_sys-log -W -r -F
gunzip -c /home/partimag/1/vg_sys-opt.xfs-ptcl-img.gz.aaa | partclone.xfs -s - -O /dev/mapper/vg_sys-opt -W -r -F
gunzip -c /home/partimag/1/vg_sys-root.xfs-ptcl-img.gz.aaa | partclone.xfs -s - -O /dev/mapper/vg_sys-root -W -r -F
gunzip -c /home/partimag/1/vg_sys-tmp.xfs-ptcl-img.gz.aaa | partclone.xfs -s - -O /dev/mapper/vg_sys-tmp -W -r -F
### merge multiple gzips
# cat file1 file2 file3 > combined-file
cat vg_sys-var.xfs-ptcl-img.gz.aaa vg_sys-var.xfs-ptcl-img.gz.aab > vg_sys-var.xfs-ptcl-img.gz
gunzip -c /home/partimag/1/vg_sys-var.xfs-ptcl-img.gz | partclone.xfs -s - -O /dev/mapper/vg_sys-var -W -r -F

### mount -o loop,rw -t xfs vg.app.partcloned.img /mnt/vde1/vg_app
# mount VG root and do post-clone
mount /dev/mapper/vg_sys-root /mnt/add/

# Edit fstab,remove password for root, change network...
# Stop the Exo VM.
exo c i stop nm-test-vm01 force

# Start Exo VM normaly and enter in grub RHEL - rescue mode
exo c i start nm-test-vm01

# Markdown the desiered kernel version in grub ($version)
version="3.10.0-123.el7.x86_64"
# Dracut virtio_scsi, virtio_blk... modules inject in initramfs 
# Backup the initramfs file you want to pach.
cp /boot/initramfs-$version.img /boot/initramfs-$version.img.bak

# Make sure the modules are missing in that initramfs.
lsinitrd /boot/initramfs-$version.img | grep -i virtio

# Create virtio.conf file for dracut.
echo 'add_drivers+=" virtio_scsi virtio_blk "' > /etc/dracut.conf.d/virtio.conf 

# Some add dracut drivers: "virtio_balloon virtio_ring virtio_input virtio_pci virtio virtio_net"
# Inject the modules.
dracut -f --add-drivers "virtio_scsi virtio_blk" /boot/initramfs-$version.img $version 

# Check the module is there.
lsinitrd /boot/initramfs-$version.img | grep virtio

# reboot the VM and use the $version kerenel.
# THE END

losetup /dev/loop1 /mnt/vdc1/vg_app-data
mount /dev/loop1 /tmp/fstransform.mount.6127


fstransform --opts-mkfs='-b size=4096' /dev/loop1 xfs
dd if=/dev/loop1 of=/dev/mapper/vg_app-data bs=1G status=progress



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



