Lxu_if9`94;2Kd<6UQ#2,:t50e*ASRt="fGR8tWV,zvVjcfK@p

USB:
GW: 192.168.205.162
route add 194.182.174.52 MASK 255.255.255.255 192.168.205.162
BT:
GW: 192.168.44.1
route add 194.182.174.52 MASK 255.255.255.255 192.168.44.1


lvm_vg_app.conf.bak does not exist. Creating it...
 VG device is /dev/sdb so i'm fixing that to vda4 for vg_app. 
sdb will become vda4 in lvm_vg_app.conf.bak
pvcreate -u AYdWNR-kONd-cHCe-wAnu-ezBH-L9GE-k2hTE8 /dev/vda4 --restorefile lvm_vg_app.conf.bak -f  
vgcfgrestore -f lvm_vg_app.conf.bak vg_app --force  
pvresize /dev/vda4  
vgchange -ay vg_app ;  
 Processing vg_app-lv_opt_hybris.ext4-ptcl-img.gz into vg_app-lv_opt_hybris 
 gunzip -c vg_app-lv_opt_hybris.ext4-ptcl-img.gz | partclone.restore -d3 -s - -O /dev/mapper/vg_app-lv_opt_hybris ; 
 Processing vg_app-lv_opt_hydra.ext4-ptcl-img.gz into vg_app-lv_opt_hydra 
 gunzip -c vg_app-lv_opt_hydra.ext4-ptcl-img.gz | partclone.restore -d3 -s - -O /dev/mapper/vg_app-lv_opt_hydra ; 
 Processing vg_app-lv_var_opt_hybris.ext4-ptcl-img.gz into vg_app-lv_var_opt_hybris 
 gunzip -c vg_app-lv_var_opt_hybris.ext4-ptcl-img.gz | partclone.restore -d3 -s - -O /dev/mapper/vg_app-lv_var_opt_hybris ; 
lvm_vg_sys.conf.bak does not exist. Creating it...
 VG device is /dev/sda2 so i'm fixing that to vda2 for vg_sys. 
sda2 will become vda2 in lvm_vg_sys.conf.bak
pvcreate -u R102cw-q2OA-wEkn-A0IG-QSQe-yDIx-CDDkUt /dev/vda2 --restorefile lvm_vg_sys.conf.bak -f  
vgcfgrestore -f lvm_vg_sys.conf.bak vg_sys --force  
pvresize /dev/vda2  
vgchange -ay vg_sys ;  
 Processing vg_sys-home.ext4-ptcl-img.gz into vg_sys-home 
 gunzip -c vg_sys-home.ext4-ptcl-img.gz | partclone.restore -d3 -s - -O /dev/mapper/vg_sys-home ; 
 Processing vg_sys-opt.ext4-ptcl-img.gz into vg_sys-opt 
 gunzip -c vg_sys-opt.ext4-ptcl-img.gz | partclone.restore -d3 -s - -O /dev/mapper/vg_sys-opt ; 
 Processing vg_sys-root.ext4-ptcl-img.gz into vg_sys-root 
 gunzip -c vg_sys-root.ext4-ptcl-img.gz | partclone.restore -d3 -s - -O /dev/mapper/vg_sys-root ; 
 Processing vg_sys-tmp.ext4-ptcl-img.gz into vg_sys-tmp 
 gunzip -c vg_sys-tmp.ext4-ptcl-img.gz | partclone.restore -d3 -s - -O /dev/mapper/vg_sys-tmp ; 
 Processing vg_sys-var.ext4-ptcl-img.gz into vg_sys-var 
 gunzip -c vg_sys-var.ext4-ptcl-img.gz | partclone.restore -d3 -s - -O /dev/mapper/vg_sys-var ; 
 Processing vg_sys-var_log.ext4-ptcl-img.gz into vg_sys-var_log 
 gunzip -c vg_sys-var_log.ext4-ptcl-img.gz | partclone.restore -d3 -s - -O /dev/mapper/vg_sys-var_log ; 
 Processing vg_sys-vol_opt_commvault.ext4-ptcl-img.gz into vg_sys-vol_opt_commvault 
 gunzip -c vg_sys-vol_opt_commvault.ext4-ptcl-img.gz | partclone.restore -d3 -s - -O /dev/mapper/vg_sys-vol_opt_commvault ; 
 Processing vg_sys-vol_opt_Eracent.ext4-ptcl-img.gz into vg_sys-vol_opt_Eracent 
 gunzip -c vg_sys-vol_opt_Eracent.ext4-ptcl-img.gz | partclone.restore -d3 -s - -O /dev/mapper/vg_sys-vol_opt_Eracent ; 
root@debian:/home/partimag/to_restore# 
