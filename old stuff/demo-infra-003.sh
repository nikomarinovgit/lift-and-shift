#!/bin/bash

exo c bs d " nm-rescue-10GB" vlhydak003 -z at-vie-1

exo c i rm vlhydak003 -f -z AT-VIE-1

exo c i add vlhydak003 --disk-size 100 --instance-type Extra-Large  --private-network nm-ls-10.2.232.0-ens224 --private-network nm-ls-10.247.166.0-ens192 --template "Linux Debian 12 (Bookworm) 64-bit" --security-group nm-sg -z AT-VIE-1 -Q

exo c bs a " nm-rescue-10GB" vlhydak003 -z at-vie-1

exo c i stop vlhydak003

exo c i start --rescue-profile=netboot vlhydak003
