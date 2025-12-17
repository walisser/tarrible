#!/bin/bash
#
# Tarrible disk mounter 
#
# mount disk prepared with disk-prepare.sh
#
self=$0
disk1=$1
disk2=$2
label=$3
mountPoint=/mnt/tarrible

device=/dev/md0

# make sure nothing is mounted
cryptsetup luksOpen $device tarrible || exit 1

# mount the disk
mount -r /dev/disk/by-label/$label $mountPoint || exit 2
