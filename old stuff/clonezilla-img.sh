This image was saved by Clonezilla at 2024-07-18 14:15:07 UTC.
Saved by clonezilla-live-20230426-lunar-amd64.
The log during saving:
----------------------------------------------------------
Starting /usr/sbin/ocs-sr at 2024-07-18 13:45:05 UTC...
*****************************************************.
Clonezilla image dir: /home/partimag
Shutting down the Logical Volume Manager
  Shutting Down logical volume: /dev/vg_app/lv_opt_hybris 
  Shutting Down logical volume: /dev/vg_app/lv_opt_hydra 
  Shutting Down logical volume: /dev/vg_app/lv_var_opt_hybris 
  Shutting Down logical volume: /dev/vg_sys/home 
  Shutting Down logical volume: /dev/vg_sys/opt 
  Shutting Down logical volume: /dev/vg_sys/root 
  Shutting Down logical volume: /dev/vg_sys/swap 
  Shutting Down logical volume: /dev/vg_sys/tmp 
  Shutting Down logical volume: /dev/vg_sys/var 
  Shutting Down logical volume: /dev/vg_sys/var_log 
  Shutting Down logical volume: /dev/vg_sys/vol_opt_commvault 
  Shutting Down logical volume: /dev/vg_sys/vol_opt_Eracent 
  Shutting Down volume group: vg_app 
  Shutting Down volume group: vg_sys 
Finished Shutting down the Logical Volume Manager
The selected devices: sda sdb
PS. Next time you can run this command directly:
/usr/sbin/ocs-sr -q2 -c -j2 -z1p -i 0 -sfsck -scs -senc -p choose savedisk vlhydak003-2024-07-18-13-img sda sdb
*****************************************************.
The selected devices: sda sdb
Searching for data/swap/extended partition(s)...
Searching for data/swap/extended partition(s)...
The data partition to be saved: sda1 sda2 sda3 sdb
The selected devices: sda1 sda2 sda3 sdb
The following step is to save the hard disk/partition(s) on this machine as an image:
*****************************************************.
Machine: VMware Virtual Platform
sda (42.9GB_Virtual_disk__No_disk_serial_no)
sdb (53.7GB_LVM2_member_Virtual_disk__lvm-pv-uuid-AYdWNR-kONd-cHCe-wAnu-ezBH-L9GE-k2hTE8)
sda1 (512M_ext4(In_Virtual_disk_)_No_disk_serial_no)
sda2 (39.3G_LVM2_member(In_Virtual_disk_)_No_disk_serial_no)
sda3 (200M_vfat(In_Virtual_disk_)_No_disk_serial_no)
sdb (53.7GB_LVM2_member_Virtual_disk__lvm-pv-uuid-AYdWNR-kONd-cHCe-wAnu-ezBH-L9GE-k2hTE8)
*****************************************************.
-> "/home/partimag/vlhydak003-2024-07-18-13-img".
Shutting down the Logical Volume Manager
  Shutting Down logical volume: /dev/vg_sys/home 
  Shutting Down logical volume: /dev/vg_sys/opt 
  Shutting Down logical volume: /dev/vg_sys/root 
  Shutting Down logical volume: /dev/vg_sys/swap 
  Shutting Down logical volume: /dev/vg_sys/tmp 
  Shutting Down logical volume: /dev/vg_sys/var 
  Shutting Down logical volume: /dev/vg_sys/var_log 
  Shutting Down logical volume: /dev/vg_sys/vol_opt_commvault 
  Shutting Down logical volume: /dev/vg_sys/vol_opt_Eracent 
  Shutting Down volume group: vg_app 
  Shutting Down volume group: vg_sys 
Finished Shutting down the Logical Volume Manager
Starting saving /dev/sda1 as /home/partimag/vlhydak003-2024-07-18-13-img/sda1.XXX...
/dev/sda1 filesystem: ext4.
*****************************************************.
*****************************************************.
Use partclone with pigz to save the image.
Image file will not be split.
*****************************************************.
If this action fails or hangs, check:
* Is the disk full ?
*****************************************************.
Running: partclone.ext4 -z 10485760 -N -L /var/log/partclone.log -c -s /dev/sda1 --output - | pigz -c --fast -b 1024 --rsyncable > /home/partimag/vlhydak003-2024-07-18-13-img/sda1.ext4-ptcl-img.gz 2> /tmp/img_out_err.WKJtp0
Partclone v0.3.23 http://partclone.org
Starting to clone device (/dev/sda1) to image (-)
Reading Super Block
memory needed: 20987908 bytes
bitmap 16384 bytes, blocks 2*10485760 bytes, checksum 4 bytes
Calculating bitmap... Please wait... 
done!
File system:  EXTFS
Device size:  536.9 MB = 131072 Blocks
Space in use: 228.2 MB = 55710 Blocks
Free Space:   308.7 MB = 75362 Blocks
Block size:   4096 Byte
Total block 131072
Syncing... OK!
Partclone successfully cloned the device (/dev/sda1) to the image (-)
>>> Time elapsed: 19.88 secs (~ .331 mins)
*****************************************************.
Finished saving /dev/sda1 as /home/partimag/vlhydak003-2024-07-18-13-img/sda1.ext4-ptcl-img.gz
*****************************************************.
Starting saving /dev/sda3 as /home/partimag/vlhydak003-2024-07-18-13-img/sda3.XXX...
/dev/sda3 filesystem: vfat.
*****************************************************.
*****************************************************.
Use partclone with pigz to save the image.
Image file will not be split.
*****************************************************.
If this action fails or hangs, check:
* Is the disk full ?
*****************************************************.
Running: partclone.vfat -z 10485760 -N -L /var/log/partclone.log -c -s /dev/sda3 --output - | pigz -c --fast -b 1024 --rsyncable > /home/partimag/vlhydak003-2024-07-18-13-img/sda3.vfat-ptcl-img.gz 2> /tmp/img_out_err.NmHQsx
Partclone v0.3.23 http://partclone.org
Starting to clone device (/dev/sda3) to image (-)
Reading Super Block
memory needed: 21022724 bytes
bitmap 51200 bytes, blocks 2*10485760 bytes, checksum 4 bytes
Calculating bitmap... Please wait... 
done!
File system:  FAT16
Device size:  209.7 MB = 409600 Blocks
Space in use: 233.5 KB = 456 Blocks
Free Space:   209.5 MB = 409144 Blocks
Block size:   512 Byte
Total block 409600
Syncing... OK!
Partclone successfully cloned the device (/dev/sda3) to the image (-)
>>> Time elapsed: 7.25 secs (~ .120 mins)
*****************************************************.
Finished saving /dev/sda3 as /home/partimag/vlhydak003-2024-07-18-13-img/sda3.vfat-ptcl-img.gz
*****************************************************.
Parsing LVM layout for sda1 sda2 sda3 sdb ...
vg_app /dev/sdb AYdWNR-kONd-cHCe-wAnu-ezBH-L9GE-k2hTE8
vg_sys /dev/sda2 R102cw-q2OA-wEkn-A0IG-QSQe-yDIx-CDDkUt
Parsing logical volumes...
Saving the VG config... 
  Volume group "vg_app" successfully backed up.
  Volume group "vg_sys" successfully backed up.
done.
Checking if the VG config was saved correctly... 
done.
Saving /dev/vg_app/lv_opt_hybris as filename: vg_app-lv_opt_hybris. /dev/vg_app/lv_opt_hybris info: Linux rev 1.0 ext4 filesystem data, UUID=d0b4a7db-0980-4ba3-a54f-1bf238587a8b (extents) (64bit) (large files) (huge files)
Starting saving /dev/vg_app/lv_opt_hybris as /home/partimag/vlhydak003-2024-07-18-13-img/vg_app-lv_opt_hybris.XXX...
/dev/vg_app/lv_opt_hybris filesystem: ext4.
*****************************************************.
*****************************************************.
Use partclone with pigz to save the image.
Image file will not be split.
*****************************************************.
If this action fails or hangs, check:
* Is the disk full ?
*****************************************************.
Running: partclone.ext4 -z 10485760 -N -L /var/log/partclone.log -c -s /dev/vg_app/lv_opt_hybris --output - | pigz -c --fast -b 1024 --rsyncable > /home/partimag/vlhydak003-2024-07-18-13-img/vg_app-lv_opt_hybris.ext4-ptcl-img.gz 2> /tmp/img_out_err.6zu0Ka
Partclone v0.3.23 http://partclone.org
Starting to clone device (/dev/vg_app/lv_opt_hybris) to image (-)
Reading Super Block
memory needed: 21299204 bytes
bitmap 327680 bytes, blocks 2*10485760 bytes, checksum 4 bytes
Calculating bitmap... Please wait... 
done!
File system:  EXTFS
Device size:   10.7 GB = 2621440 Blocks
Space in use:   1.8 GB = 437065 Blocks
Free Space:     8.9 GB = 2184375 Blocks
Block size:   4096 Byte
Total block 2621440
Syncing... OK!
Partclone successfully cloned the device (/dev/vg_app/lv_opt_hybris) to the image (-)
>>> Time elapsed: 66.44 secs (~ 1.107 mins)
*****************************************************.
Finished saving /dev/vg_app/lv_opt_hybris as /home/partimag/vlhydak003-2024-07-18-13-img/vg_app-lv_opt_hybris.ext4-ptcl-img.gz
*****************************************************.
Saving /dev/vg_app/lv_var_opt_hybris as filename: vg_app-lv_var_opt_hybris. /dev/vg_app/lv_var_opt_hybris info: Linux rev 1.0 ext4 filesystem data, UUID=75842d2d-cc0d-4475-bff3-66975dd8d233 (extents) (64bit) (large files) (huge files)
Starting saving /dev/vg_app/lv_var_opt_hybris as /home/partimag/vlhydak003-2024-07-18-13-img/vg_app-lv_var_opt_hybris.XXX...
/dev/vg_app/lv_var_opt_hybris filesystem: ext4.
*****************************************************.
*****************************************************.
Use partclone with pigz to save the image.
Image file will not be split.
*****************************************************.
If this action fails or hangs, check:
* Is the disk full ?
*****************************************************.
Running: partclone.ext4 -z 10485760 -N -L /var/log/partclone.log -c -s /dev/vg_app/lv_var_opt_hybris --output - | pigz -c --fast -b 1024 --rsyncable > /home/partimag/vlhydak003-2024-07-18-13-img/vg_app-lv_var_opt_hybris.ext4-ptcl-img.gz 2> /tmp/img_out_err.Jd0JRb
Partclone v0.3.23 http://partclone.org
Starting to clone device (/dev/vg_app/lv_var_opt_hybris) to image (-)
Reading Super Block
memory needed: 21954564 bytes
bitmap 983040 bytes, blocks 2*10485760 bytes, checksum 4 bytes
Calculating bitmap... Please wait... 
done!
File system:  EXTFS
Device size:   32.2 GB = 7864320 Blocks
Space in use:   2.9 GB = 710960 Blocks
Free Space:    29.3 GB = 7153360 Blocks
Block size:   4096 Byte
Total block 7864320
Syncing... OK!
Partclone successfully cloned the device (/dev/vg_app/lv_var_opt_hybris) to the image (-)
>>> Time elapsed: 127.75 secs (~ 2.129 mins)
*****************************************************.
Finished saving /dev/vg_app/lv_var_opt_hybris as /home/partimag/vlhydak003-2024-07-18-13-img/vg_app-lv_var_opt_hybris.ext4-ptcl-img.gz
*****************************************************.
Saving /dev/vg_app/lv_opt_hydra as filename: vg_app-lv_opt_hydra. /dev/vg_app/lv_opt_hydra info: Linux rev 1.0 ext4 filesystem data, UUID=2d9328d6-e782-4a12-9690-ceecb61186fc (extents) (64bit) (large files) (huge files)
Starting saving /dev/vg_app/lv_opt_hydra as /home/partimag/vlhydak003-2024-07-18-13-img/vg_app-lv_opt_hydra.XXX...
/dev/vg_app/lv_opt_hydra filesystem: ext4.
*****************************************************.
*****************************************************.
Use partclone with pigz to save the image.
Image file will not be split.
*****************************************************.
If this action fails or hangs, check:
* Is the disk full ?
*****************************************************.
Running: partclone.ext4 -z 10485760 -N -L /var/log/partclone.log -c -s /dev/vg_app/lv_opt_hydra --output - | pigz -c --fast -b 1024 --rsyncable > /home/partimag/vlhydak003-2024-07-18-13-img/vg_app-lv_opt_hydra.ext4-ptcl-img.gz 2> /tmp/img_out_err.puzBY8
Partclone v0.3.23 http://partclone.org
Starting to clone device (/dev/vg_app/lv_opt_hydra) to image (-)
Reading Super Block
memory needed: 21266436 bytes
bitmap 294912 bytes, blocks 2*10485760 bytes, checksum 4 bytes
Calculating bitmap... Please wait... 
done!
File system:  EXTFS
Device size:    9.7 GB = 2359296 Blocks
Space in use:   2.8 GB = 694518 Blocks
Free Space:     6.8 GB = 1664778 Blocks
Block size:   4096 Byte
Total block 2359296
Syncing... OK!
Partclone successfully cloned the device (/dev/vg_app/lv_opt_hydra) to the image (-)
>>> Time elapsed: 174.55 secs (~ 2.909 mins)
*****************************************************.
Finished saving /dev/vg_app/lv_opt_hydra as /home/partimag/vlhydak003-2024-07-18-13-img/vg_app-lv_opt_hydra.ext4-ptcl-img.gz
*****************************************************.
Saving /dev/vg_sys/vol_opt_Eracent as filename: vg_sys-vol_opt_Eracent. /dev/vg_sys/vol_opt_Eracent info: Linux rev 1.0 ext4 filesystem data, UUID=fc7799cf-4427-41d7-9e5e-91b3410883c8 (extents) (64bit) (large files) (huge files)
Starting saving /dev/vg_sys/vol_opt_Eracent as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-vol_opt_Eracent.XXX...
/dev/vg_sys/vol_opt_Eracent filesystem: ext4.
*****************************************************.
*****************************************************.
Use partclone with pigz to save the image.
Image file will not be split.
*****************************************************.
If this action fails or hangs, check:
* Is the disk full ?
*****************************************************.
Running: partclone.ext4 -z 10485760 -N -L /var/log/partclone.log -c -s /dev/vg_sys/vol_opt_Eracent --output - | pigz -c --fast -b 1024 --rsyncable > /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-vol_opt_Eracent.ext4-ptcl-img.gz 2> /tmp/img_out_err.i2xKuV
Partclone v0.3.23 http://partclone.org
Starting to clone device (/dev/vg_sys/vol_opt_Eracent) to image (-)
Reading Super Block
memory needed: 21135364 bytes
bitmap 163840 bytes, blocks 2*10485760 bytes, checksum 4 bytes
Calculating bitmap... Please wait... 
done!
File system:  EXTFS
Device size:    5.4 GB = 1310720 Blocks
Space in use: 264.3 MB = 64526 Blocks
Free Space:     5.1 GB = 1246194 Blocks
Block size:   4096 Byte
Total block 1310720
Syncing... OK!
Partclone successfully cloned the device (/dev/vg_sys/vol_opt_Eracent) to the image (-)
>>> Time elapsed: 10.25 secs (~ .170 mins)
*****************************************************.
Finished saving /dev/vg_sys/vol_opt_Eracent as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-vol_opt_Eracent.ext4-ptcl-img.gz
*****************************************************.
Saving /dev/vg_sys/vol_opt_commvault as filename: vg_sys-vol_opt_commvault. /dev/vg_sys/vol_opt_commvault info: Linux rev 1.0 ext4 filesystem data, UUID=3ed8a3fb-b448-4c41-8c84-1280534b064d (extents) (64bit) (large files) (huge files)
Starting saving /dev/vg_sys/vol_opt_commvault as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-vol_opt_commvault.XXX...
/dev/vg_sys/vol_opt_commvault filesystem: ext4.
*****************************************************.
*****************************************************.
Use partclone with pigz to save the image.
Image file will not be split.
*****************************************************.
If this action fails or hangs, check:
* Is the disk full ?
*****************************************************.
Running: partclone.ext4 -z 10485760 -N -L /var/log/partclone.log -c -s /dev/vg_sys/vol_opt_commvault --output - | pigz -c --fast -b 1024 --rsyncable > /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-vol_opt_commvault.ext4-ptcl-img.gz 2> /tmp/img_out_err.o5fCrN
Partclone v0.3.23 http://partclone.org
Starting to clone device (/dev/vg_sys/vol_opt_commvault) to image (-)
Reading Super Block
memory needed: 21135364 bytes
bitmap 163840 bytes, blocks 2*10485760 bytes, checksum 4 bytes
Calculating bitmap... Please wait... 
done!
File system:  EXTFS
Device size:    5.4 GB = 1310720 Blocks
Space in use:   1.7 GB = 412040 Blocks
Free Space:     3.7 GB = 898680 Blocks
Block size:   4096 Byte
Total block 1310720
Syncing... OK!
Partclone successfully cloned the device (/dev/vg_sys/vol_opt_commvault) to the image (-)
>>> Time elapsed: 64.48 secs (~ 1.074 mins)
*****************************************************.
Finished saving /dev/vg_sys/vol_opt_commvault as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-vol_opt_commvault.ext4-ptcl-img.gz
*****************************************************.
Saving /dev/vg_sys/tmp as filename: vg_sys-tmp. /dev/vg_sys/tmp info: Linux rev 1.0 ext4 filesystem data, UUID=68cec856-ca4f-4a76-94c4-1911649855e5 (extents) (64bit) (large files) (huge files)
Starting saving /dev/vg_sys/tmp as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-tmp.XXX...
/dev/vg_sys/tmp filesystem: ext4.
*****************************************************.
*****************************************************.
Use partclone with pigz to save the image.
Image file will not be split.
*****************************************************.
If this action fails or hangs, check:
* Is the disk full ?
*****************************************************.
Running: partclone.ext4 -z 10485760 -N -L /var/log/partclone.log -c -s /dev/vg_sys/tmp --output - | pigz -c --fast -b 1024 --rsyncable > /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-tmp.ext4-ptcl-img.gz 2> /tmp/img_out_err.IWB1Vf
Partclone v0.3.23 http://partclone.org
Starting to clone device (/dev/vg_sys/tmp) to image (-)
Reading Super Block
memory needed: 21037060 bytes
bitmap 65536 bytes, blocks 2*10485760 bytes, checksum 4 bytes
Calculating bitmap... Please wait... 
done!
File system:  EXTFS
Device size:    2.1 GB = 524288 Blocks
Space in use: 164.1 MB = 40063 Blocks
Free Space:     2.0 GB = 484225 Blocks
Block size:   4096 Byte
Total block 524288
Syncing... OK!
Partclone successfully cloned the device (/dev/vg_sys/tmp) to the image (-)
>>> Time elapsed: 11.73 secs (~ .195 mins)
*****************************************************.
Finished saving /dev/vg_sys/tmp as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-tmp.ext4-ptcl-img.gz
*****************************************************.
Saving /dev/vg_sys/home as filename: vg_sys-home. /dev/vg_sys/home info: Linux rev 1.0 ext4 filesystem data, UUID=e8b70cba-1deb-4661-a9a3-515de08f0146 (extents) (64bit) (large files) (huge files)
Starting saving /dev/vg_sys/home as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-home.XXX...
/dev/vg_sys/home filesystem: ext4.
*****************************************************.
*****************************************************.
Use partclone with pigz to save the image.
Image file will not be split.
*****************************************************.
If this action fails or hangs, check:
* Is the disk full ?
*****************************************************.
Running: partclone.ext4 -z 10485760 -N -L /var/log/partclone.log -c -s /dev/vg_sys/home --output - | pigz -c --fast -b 1024 --rsyncable > /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-home.ext4-ptcl-img.gz 2> /tmp/img_out_err.xt9fPq
Partclone v0.3.23 http://partclone.org
Starting to clone device (/dev/vg_sys/home) to image (-)
Reading Super Block
memory needed: 20987908 bytes
bitmap 16384 bytes, blocks 2*10485760 bytes, checksum 4 bytes
Calculating bitmap... Please wait... 
done!
File system:  EXTFS
Device size:  536.9 MB = 131072 Blocks
Space in use: 104.3 MB = 25456 Blocks
Free Space:   432.6 MB = 105616 Blocks
Block size:   4096 Byte
Total block 131072
Syncing... OK!
Partclone successfully cloned the device (/dev/vg_sys/home) to the image (-)
>>> Time elapsed: 10.31 secs (~ .171 mins)
*****************************************************.
Finished saving /dev/vg_sys/home as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-home.ext4-ptcl-img.gz
*****************************************************.
Saving /dev/vg_sys/var as filename: vg_sys-var. /dev/vg_sys/var info: Linux rev 1.0 ext4 filesystem data, UUID=ab3c61da-31c5-4d5f-a02d-0506ce1c1742 (extents) (64bit) (large files) (huge files)
Starting saving /dev/vg_sys/var as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-var.XXX...
/dev/vg_sys/var filesystem: ext4.
*****************************************************.
*****************************************************.
Use partclone with pigz to save the image.
Image file will not be split.
*****************************************************.
If this action fails or hangs, check:
* Is the disk full ?
*****************************************************.
Running: partclone.ext4 -z 10485760 -N -L /var/log/partclone.log -c -s /dev/vg_sys/var --output - | pigz -c --fast -b 1024 --rsyncable > /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-var.ext4-ptcl-img.gz 2> /tmp/img_out_err.8A74xz
Partclone v0.3.23 http://partclone.org
Starting to clone device (/dev/vg_sys/var) to image (-)
Reading Super Block
memory needed: 21108228 bytes
bitmap 136704 bytes, blocks 2*10485760 bytes, checksum 4 bytes
Calculating bitmap... Please wait... 
done!
File system:  EXTFS
Device size:    4.5 GB = 1093632 Blocks
Space in use: 644.7 MB = 157389 Blocks
Free Space:     3.8 GB = 936243 Blocks
Block size:   4096 Byte
Total block 1093632
Syncing... OK!
Partclone successfully cloned the device (/dev/vg_sys/var) to the image (-)
>>> Time elapsed: 21.54 secs (~ .359 mins)
*****************************************************.
Finished saving /dev/vg_sys/var as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-var.ext4-ptcl-img.gz
*****************************************************.
Saving /dev/vg_sys/var_log as filename: vg_sys-var_log. /dev/vg_sys/var_log info: Linux rev 1.0 ext4 filesystem data, UUID=b46eb776-ee99-4bce-b9d8-2a188020b668 (extents) (64bit) (large files) (huge files)
Starting saving /dev/vg_sys/var_log as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-var_log.XXX...
/dev/vg_sys/var_log filesystem: ext4.
*****************************************************.
*****************************************************.
Use partclone with pigz to save the image.
Image file will not be split.
*****************************************************.
If this action fails or hangs, check:
* Is the disk full ?
*****************************************************.
Running: partclone.ext4 -z 10485760 -N -L /var/log/partclone.log -c -s /dev/vg_sys/var_log --output - | pigz -c --fast -b 1024 --rsyncable > /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-var_log.ext4-ptcl-img.gz 2> /tmp/img_out_err.gGE7WY
Partclone v0.3.23 http://partclone.org
Starting to clone device (/dev/vg_sys/var_log) to image (-)
Reading Super Block
memory needed: 21037060 bytes
bitmap 65536 bytes, blocks 2*10485760 bytes, checksum 4 bytes
Calculating bitmap... Please wait... 
done!
File system:  EXTFS
Device size:    2.1 GB = 524288 Blocks
Space in use: 209.7 MB = 51192 Blocks
Free Space:     1.9 GB = 473096 Blocks
Block size:   4096 Byte
Total block 524288
Syncing... OK!
Partclone successfully cloned the device (/dev/vg_sys/var_log) to the image (-)
>>> Time elapsed: 13.34 secs (~ .222 mins)
*****************************************************.
Finished saving /dev/vg_sys/var_log as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-var_log.ext4-ptcl-img.gz
*****************************************************.
Saving /dev/vg_sys/opt as filename: vg_sys-opt. /dev/vg_sys/opt info: Linux rev 1.0 ext4 filesystem data, UUID=80b33af0-bc24-4066-96ff-8e7fd8b324f2 (extents) (64bit) (large files) (huge files)
Starting saving /dev/vg_sys/opt as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-opt.XXX...
/dev/vg_sys/opt filesystem: ext4.
*****************************************************.
*****************************************************.
Use partclone with pigz to save the image.
Image file will not be split.
*****************************************************.
If this action fails or hangs, check:
* Is the disk full ?
*****************************************************.
Running: partclone.ext4 -z 10485760 -N -L /var/log/partclone.log -c -s /dev/vg_sys/opt --output - | pigz -c --fast -b 1024 --rsyncable > /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-opt.ext4-ptcl-img.gz 2> /tmp/img_out_err.QgdFB2
Partclone v0.3.23 http://partclone.org
Starting to clone device (/dev/vg_sys/opt) to image (-)
Reading Super Block
memory needed: 21037060 bytes
bitmap 65536 bytes, blocks 2*10485760 bytes, checksum 4 bytes
Calculating bitmap... Please wait... 
done!
File system:  EXTFS
Device size:    2.1 GB = 524288 Blocks
Space in use:   1.2 GB = 296587 Blocks
Free Space:   932.7 MB = 227701 Blocks
Block size:   4096 Byte
Total block 524288
Syncing... OK!
Partclone successfully cloned the device (/dev/vg_sys/opt) to the image (-)
>>> Time elapsed: 32.60 secs (~ .543 mins)
*****************************************************.
Finished saving /dev/vg_sys/opt as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-opt.ext4-ptcl-img.gz
*****************************************************.
Saving /dev/vg_sys/swap as filename: vg_sys-swap. /dev/vg_sys/swap info: Linux swap file, 4k page size, little endian, version 1, size 1048575 pages, 0 bad pages, no label, UUID=0fc1448b-7519-480a-812d-982983f3f6e7
Saving /dev/vg_sys/root as filename: vg_sys-root. /dev/vg_sys/root info: Linux rev 1.0 ext4 filesystem data, UUID=874955e7-9daf-4554-8ccb-ee85e15c098d (extents) (64bit) (large files) (huge files)
Starting saving /dev/vg_sys/root as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-root.XXX...
/dev/vg_sys/root filesystem: ext4.
*****************************************************.
*****************************************************.
Use partclone with pigz to save the image.
Image file will not be split.
*****************************************************.
If this action fails or hangs, check:
* Is the disk full ?
*****************************************************.
Running: partclone.ext4 -z 10485760 -N -L /var/log/partclone.log -c -s /dev/vg_sys/root --output - | pigz -c --fast -b 1024 --rsyncable > /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-root.ext4-ptcl-img.gz 2> /tmp/img_out_err.2ViGyy
Partclone v0.3.23 http://partclone.org
Starting to clone device (/dev/vg_sys/root) to image (-)
Reading Super Block
memory needed: 21135364 bytes
bitmap 163840 bytes, blocks 2*10485760 bytes, checksum 4 bytes
Calculating bitmap... Please wait... 
done!
File system:  EXTFS
Device size:    5.4 GB = 1310720 Blocks
Space in use:   3.3 GB = 811589 Blocks
Free Space:     2.0 GB = 499131 Blocks
Block size:   4096 Byte
Total block 1310720
Syncing... OK!
Partclone successfully cloned the device (/dev/vg_sys/root) to the image (-)
>>> Time elapsed: 102.74 secs (~ 1.712 mins)
*****************************************************.
Finished saving /dev/vg_sys/root as /home/partimag/vlhydak003-2024-07-18-13-img/vg_sys-root.ext4-ptcl-img.gz
*****************************************************.
Dumping the device mapper table in /home/partimag/vlhydak003-2024-07-18-13-img/dmraid.table...
Saving block devices info in /home/partimag/vlhydak003-2024-07-18-13-img/blkdev.list...
Saving block devices attributes in /home/partimag/vlhydak003-2024-07-18-13-img/blkid.list...
Checking the integrity of partition table in the disk /dev/sda... 
Reading the partition table for /dev/sda...RETVAL=0
*****************************************************.
The first partition of disk /dev/sda starts at 2048.
Saving the hidden data between MBR (1st sector, i.e. 512 bytes) and 1st partition, which might be useful for some recovery tool, by:
dd if=/dev/sda of=/home/partimag/vlhydak003-2024-07-18-13-img/sda-hidden-data-after-mbr skip=1 bs=512 count=2047
2047+0 records in
2047+0 records out
1048064 bytes (1.0 MB, 1.0 MiB) copied, 0.684766 s, 1.5 MB/s
*****************************************************.
Checking the integrity of partition table in the disk /dev/sdb... 
Reading the partition table for /dev/sdb...RETVAL=1
Saving the MBR data for sda...
1+0 records in
1+0 records out
512 bytes copied, 0.275576 s, 1.9 kB/s
Saving the MBR data for sdb...
1+0 records in
1+0 records out
512 bytes copied, 0.275746 s, 1.9 kB/s
End of saveparts job for image /home/partimag/vlhydak003-2024-07-18-13-img.
*****************************************************.
*****************************************************.
End of savedisk job for image vlhydak003-2024-07-18-13-img.
Checking if udevd rules have to be restored...
This program is not started by Clonezilla server, so skip notifying it the job is done.
This program is not started by Clonezilla server, so skip notifying it the job is done.
Finished!
Finished!
### End of log ###
### Image created time: 2024-0718-1415
