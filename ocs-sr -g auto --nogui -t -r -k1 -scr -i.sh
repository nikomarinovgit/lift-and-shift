ocs-sr -g auto --nogui -t -r -k1 -scr -icds -c -f sda1 -d /home/partimag -p choose restorepartrs to_restore vda1

cnvt-ocs-dev -b -d /home/partimag to_restore sda vda

root@debian:/home/partimag/to_restore# cnvt-ocs-dev -b -d /home/partimag to_restore sda vda
Setting the TERM as linux
Clonezilla image dir: /home/partimag
*****************************************************.
Change sda to vda in /home/partimag/to_restore/parts... done!
Change sda to vda in /home/partimag/to_restore/sda-pt.sf... done!
Change sda to vda in /home/partimag/to_restore/dev-fs.list... done!
Change sda to vda in /home/partimag/to_restore/blkdev.list... done!
Change sda to vda in /home/partimag/to_restore/blkid.list... done!
*****************************************************.
Change sda to vda in /home/partimag/to_restore/disk... done!
Change sda to vda in /home/partimag/to_restore/sda-pt.parted... done!
Change sda to vda in /home/partimag/to_restore/sda-pt.parted.compact... done!
Change sda to vda in /home/partimag/to_restore/blkdev.list... done!
Change sda to vda in /home/partimag/to_restore/blkid.list... done!
*****************************************************.
Change sda to vda in /home/partimag/to_restore/lvm_vg_dev.list... done!
*****************************************************.
renamed '/home/partimag/to_restore/sda-chs.sf' -> '/home/partimag/to_restore/vda-chs.sf'
renamed '/home/partimag/to_restore/sda-hidden-data-after-mbr' -> '/home/partimag/to_restore/vda-hidden-data-after-mbr'
renamed '/home/partimag/to_restore/sda-mbr' -> '/home/partimag/to_restore/vda-mbr'
renamed '/home/partimag/to_restore/sda-pt.parted' -> '/home/partimag/to_restore/vda-pt.parted'
renamed '/home/partimag/to_restore/sda-pt.parted.compact' -> '/home/partimag/to_restore/vda-pt.parted.compact'
renamed '/home/partimag/to_restore/sda-pt.sf' -> '/home/partimag/to_restore/vda-pt.sf'
renamed '/home/partimag/to_restore/sda1.ext4-ptcl-img.gz' -> '/home/partimag/to_restore/vda1.ext4-ptcl-img.gz'
renamed '/home/partimag/to_restore/sda3.vfat-ptcl-img.gz' -> '/home/partimag/to_restore/vda3.vfat-ptcl-img.gz'





mdadm --zero-superblock /dev/vda

dd if=/dev/zero of=/dev/vda bs=512 seek=209714176 count=1024

/usr/sbin/ocs-sr -g auto -e1 auto -e2 -c -r -j2 -k0 -scr -p choose restoredisk to_restore vda


ocs-restore-mbr --ocsroot /home/partimag  to_restore vda


ocs-resize-part  --batch /dev/vda1

e2fsck -f -y /dev/vda1; resize2fs -p -f /dev/vda1

ocs-resize-part  --batch /dev/vda2

ocs-resize-part  --batch /dev/vda3

ocs-expand-lvm -b /dev/vda2

pvresize /dev/vda2

lvresize -L +1918m /dev/vg_sys/vol_opt_Eracent

e2fsck -f -y /dev/vg_sys/vol_opt_Eracent; resize2fs -p -f /dev/vg_sys/vol_opt_Eracent

lvresize -L +1918m /dev/vg_sys/vol_opt_commvault

e2fsck -f -y /dev/vg_sys/vol_opt_commvault; resize2fs -p -f /dev/vg_sys/vol_opt_commvault

lvresize -L +767m /dev/vg_sys/tmp

e2fsck -f -y /dev/vg_sys/tmp; resize2fs -p -f /dev/vg_sys/tmp

lvresize -L +192m /dev/vg_sys/home

e2fsck -f -y /dev/vg_sys/home; resize2fs -p -f /dev/vg_sys/home

lvresize -L +1601m /dev/vg_sys/var

e2fsck -f -y /dev/vg_sys/var; resize2fs -p -f /dev/vg_sys/var

lvresize -L +767m /dev/vg_sys/var_log

e2fsck -f -y /dev/vg_sys/var_log; resize2fs -p -f /dev/vg_sys/var_log

lvresize -L +767m /dev/vg_sys/opt

e2fsck -f -y /dev/vg_sys/opt; resize2fs -p -f /dev/vg_sys/opt

lvresize -L +1918m /dev/vg_sys/root

e2fsck -f -y /dev/vg_sys/root; resize2fs -p -f /dev/vg_sys/root

ocs-expand-lvm -b /dev/vda3

ocs-expand-lvm -b /dev/vdc

lvresize -L +10646m /dev/vg_app/lv_opt_hybris

e2fsck -f -y /dev/vg_app/lv_opt_hybris; resize2fs -p -f /dev/vg_app/lv_opt_hybris

lvresize -L +31939m /dev/vg_app/lv_var_opt_hybris

e2fsck -f -y /dev/vg_app/lv_var_opt_hybris; resize2fs -p -f /dev/vg_app/lv_var_opt_hybris

lvresize -L +9582m /dev/vg_app/lv_opt_hydra

e2fsck -f -y /dev/vg_app/lv_opt_hydra; resize2fs -p -f /dev/vg_app/lv_opt_hydra











