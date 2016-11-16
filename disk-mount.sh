#!/bin/bash
#
# Tarrible disk mounter 
#
# mount disk prepared with disk-prepare.sh
#
self=$0
device=$1
label=$2
mountPoint=/mnt/tarrible

# make sure nothing is mounted
cryptsetup luksOpen $device tarrible || exit 1

# mount the disk
mount -r /dev/disk/by-label/$label $mountPoint || exit 2
