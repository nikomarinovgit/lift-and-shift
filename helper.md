Lxu_if9`94;2Kd<6UQ#2,:t50e*ASRt="fGR8tWV,zvVjcfK@p

USB:
GW: 192.168.205.162
route add 194.182.174.52 MASK 255.255.255.255 192.168.205.162
BT:
GW: 192.168.44.1
route add 194.182.174.52 MASK 255.255.255.255 192.168.44.1





 Processing vg_app-lv_opt_hybris.ext4-ptcl-img.gz into vg_app-lv_opt_hybris 
 gunzip -c vg_app-lv_opt_hybris.ext4-ptcl-img.gz | partclone.ext4 -s - -O /dev/mapper/vg_app-lv_opt_hybris -r -F  
Target partition size(9102 MB) is smaller than source(10738 MB). Use option -C to disable size checking(Dangerous).

 Processing vg_app-lv_opt_hydra.ext4-ptcl-img.gz into vg_app-lv_opt_hydra 
 gunzip -c vg_app-lv_opt_hydra.ext4-ptcl-img.gz | partclone.ext4 -s - -O /dev/mapper/vg_app-lv_opt_hydra -r -F  
Target partition size(8607 MB) is smaller than source(9664 MB). Use option -C to disable size checking(Dangerous).


