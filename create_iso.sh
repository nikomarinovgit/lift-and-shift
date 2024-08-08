#!/bin/bash

source ./a1/.env

ocs-iso -b text -a a1-clonezilla -g en_US.UTF-8 -i a1.$(date +"%d-%m-%Y-%H-%M-%S") -k NONE -m /a1/a1.sh -u /a1/ -s -r 200 -x noeject 

sshpass -p $sshpass scp -o StrictHostKeyChecking=no $a1_clonezilla_iso_name.iso $sshuser@$sshhost:$sshfolder



