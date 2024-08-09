#!/bin/bash

# exo c i add nm-test-vm02 --disk-size 100 --instance-type Extra-Large  --template "Linux Debian 12 (Bookworm) 64-bit" --security-group nm-sg -z AT-VIE-1 -Q
# exo c bs a " nm-rescue-10GB" nm-test-vm02 -z at-vie-1

exo c i start --rescue-profile=netboot nm-test-vm02 -f

