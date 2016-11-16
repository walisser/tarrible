#!/bin/bash
#
# Tarrible disk formatter
#
# Run this script (as root) to format a new disk or
# erase existing disk and get it ready for writing.
# Make sure the selected device is correct!!
#
# Note, the disk doesn't need to be partitioned, 
# e.g. /dev/sdg is a valid disk as is /dev/sdg1
#
# Examples:
#
# Format the second disk in a backup set:
#   ./disk-prepare.sh /dev/sdg MyDocuments2 mydocs.20161201
#
# Format the second volume of a backup set, stored in an image file:
#   ./disk-prepare.sh data1.img data1 data
#
self=$0
device=$1 # /dev/sdx /dev/sdx1 file.img etc
label=$2  # Filesystem label: backup1 backup2 backup3 etc (unique for every disk in the backup set)
folder=$3 # Backup location on disk: mybackup.20161105 (same for every disk in the backup set)

mountPoint=/mnt/tarrible

# make sure nothing is mounted
umount $mountPoint
cryptsetup luksClose tarrible

# setup the entire device/file for encryption
# use 1MiB alignment to accomodate various filesystems or devices
cryptsetup luksFormat --align-payload $((1024*1024/512)) $device || exit 1

# open the encrypted volume
cryptsetup luksOpen $device tarrible || exit 2

# create filesystem with 1% reserve and the given label
mkfs.ext4 -m 1 -L $label /dev/mapper/tarrible || exit 3

# wait for kernel to register the new label
sync
sleep 5

# mount and make folder to contain the backup
mount /dev/disk/by-label/$label $mountPoint || exit 4
mkdir $mountPoint/$folder || exit 5

# confirmation that it worked and is ready to use
df -h $mountPoint

