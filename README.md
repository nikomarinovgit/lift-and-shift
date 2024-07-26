/usr/sbin/ocs-sr -e1 auto -e2 -c {confirmation} -t -r -k1 -scr -icds -p choose restoreparts to_restore sda1 sda2

-f, --from-part-in-img PARTITION Restore the partition from image. This is especially for "restoreparts" to restore the image of partition (only works for one) to different partition, e.g. sda1 of image to sdb6.

-p, --postaction [choose|poweroff|reboot|command|CMD] When save/restoration finishes, choose action in the client, poweroff, reboot (default), in command prompt or run CMD

-icds, --ignore-chk-dsk-size-pt Skip checking destination disk size before creating the partition table on it. By default it will be checked and if the size is smaller than the source disk, quit.

-scr, --skip-check-restorable-r By default Clonezilla will check the image if restorable before restoring. This option allows you to skip that.

-k1 Create partition table in the target disk proportionally.

-k2 Enter command line prompt to create partition table manually before restoring image.

-r, --resize-partition Resize the partition when restoration finishes, this will resize the file system size to fit the partition size. It is normally used when when a small partition image is restored to a larger partition.

-t, --no-restore-mbr Do NOT restore the MBR (Mater Boot Record) when restoring image. If this option is set, you must make sure there is an existing MBR in the current restored harddisk. Default is Yes. See -g above

-e1, --change-geometry NTFS-BOOT-PARTITION Force to change the CHS (cylinders, heads, sectors) value of NTFS boot partition after image is restored. NTFS-BOOT-PARTITION can be one of "/dev/sda1", "/dev/sda2"... or "auto" ("auto" will let clonezilla detect the NTFS boot partition automatically)

-e2, --load-geometry-from-edd Force to use the CHS (cylinders, heads, sectors) from EDD (Enhanced Disk Device) when creating partition table by sfdisk

/usr/sbin/ocs-sr --nogui -e2 -t -r -k1 -scr -icds -f sda2 -p choose restoreparts to_restore vda2
