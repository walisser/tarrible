#!/bin/bash
#
# Tarrible disk unmounter 
#
# unmount disk prepared with disk-prepare.sh
#
mountPoint=/mnt/tarrible

# make sure nothing is mounted
umount $mountPoint
cryptsetup luksClose tarrible
