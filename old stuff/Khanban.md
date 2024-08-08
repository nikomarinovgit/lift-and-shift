
Backup VMs:
Verify the complete DEV environment (for Hybris).
Copy the Original VM
Create a Script to make a Clonezilla backup of the source VM
Boot the Source VM with Clonezilla ISO
Exit to Console
Mount helper volume
Start script from helper volume
Copy of source VMs is done




Restore VMs:
Create a script to create required VM, shut it down and netboot in rescue mode.
Boot Clonezilla
Mout the helper volume
Start script to restore VM
Make adaption that script gets directory as parameter and changes into subfolder given with parameter provided
Make adaption that script removes the backup network interfacen
Make adaption that script sets the new IP address on the interface connected to the private network.
Restart the VM (reboot is not sufficient) to unmount the Clonezilla
UXOS has to take over and make additional changes (e.g. CommVault settings, ...)
Service team has to check functionality
