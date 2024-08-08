
# WMware -> Exoscale

There are two scripts 
  - /a1/backup.sh
  - restore.sh

The /a1/ folder is copied on the ISO while creating it.
The ISO is created by create_iso.sh from inside a booted clonezilla.iso (https://clonezilla.org/downloads/download.php?branch=stable).



## 1. Backup VMware VMs (source VM):

  Boot the a1-clonezilla.iso.
  Bootloader has two mode GRAPHYC and TEXT. May differ between releases.

  <p align="center">
    <img src="https://github.com/user-attachments/assets/236ffe84-da33-482a-a276-882e0f346ed6" alt="Bootloader Image">
  </p>
  
### Follow the steps: 
  Will boot directly into script and welcome you with:
  
   - Confirm the detected OS.

  <p align="center">
    <img src="https://github.com/user-attachments/assets/32c8541a-5ccf-4151-a862-0e2e504d2217" alt="Welcome Script Image">
  </p>


  It will try to get info about the source VM network.
  
  - in network-scripts (/etc/sysconfig) 
  - and NetworkManager files (/etc/NetworkManager/system-connections). 

  <p align="center">
    <img src="https://github.com/user-attachments/assets/d59ef521-8402-4656-b8c9-c91be864b5be" alt="Network Info Image">
  </p>

  Next it will ask for settings
   - will print the values found in scraped files as (__default__: **X.X.X.X**):
   - If default is blank, it will be empty (network fail) ulness filled corectly.
   - At the end it will show summary of the values.

  <p align="center">
    <img src="https://github.com/user-attachments/assets/51a9463f-cd5d-4e5d-b578-ef9e53c8fc6a" alt="Summary Image">
  </p>

  Then he will:
   1. Apply the setting (to every network interface the VM has)
   2. And curl check to the s3 bucket pointed.
   3. If crul check fail, it will try with adding proxy and curl again:

          export http_proxy=http://zproxy.a1.inside:443
          export https_proxy=http://zproxy.a1.inside:443
          export HTTP_PROXY=http://zproxy.a1.inside:443
          export HTTPS_PROXY=http://zproxy.a1.inside:443

<p align="center">
  <img src="https://github.com/user-attachments/assets/2e6c2e52-763d-406c-a178-e4a25c090231" alt="Summary Image">
</p>

**Then the backup starts:**

<p align="center">
  <img src="https://github.com/user-attachments/assets/f9feea36-7e0b-468f-af79-abd6af6cae03" alt="Summary Image">
</p>

**At the end it will ask what to do:**

<p align="center">
  <img src="https://github.com/user-attachments/assets/63cbd553-db15-48ab-890d-5f9c8b617f1a" alt="Summary Image">
</p>


# 2. Restore VMware VMs (destination VM)





