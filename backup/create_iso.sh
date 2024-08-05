#!/bin/bash

ocs-iso -l 0 -g en_US.UTF-8 -k NONE -a a1-clonezilla -i a1.v1 -u /a1/ -x noeject -s -m /a1/a1.sh -r 0

# sshpass -p B@danarka100 scp -o StrictHostKeyChecking=no a1-clonezilla.iso n_marinov@192.168.99.1:/home/n_marinov/Downloads/



