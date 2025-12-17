#!/bin/bash
#
# Tarrible disk unmounter 
#
# unmount disk prepared with disk-prepare.sh
#

./disk-unmount.sh

mdadm --stop /dev/md0
mdadm --remove /dev/md0

