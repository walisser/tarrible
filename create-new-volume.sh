#!/bin/bash

#
# This script runs via tar --new-volume-script mechanism
# - if the disk is not full, rename the current.tar to the next number available
# - if the disk is full, wait for a new disk to be mounted
#
self=$0
dst="$TARRIBLE_DST"
curr="$dst/current.tar"
splitSize="$TARRIBLE_SPLIT_SIZE"

if [ ! -e "$curr" ]; then
   >&2 echo $self: no current.tar in $dst
   exit 1
fi

# find the next split by iterating
for i in {1..10000}; do

   num=`printf %.5d $i` 
   if [ -e "$dst/$num.tar" ]; then
      y=y 
   else
      # rename the current split
      mv  "$curr" "$dst/$num.tar"

      # get free space on dst to know when its time to switch disks
      # this might be inaccurate since --sync isn't passed to df
      free=`df "$dst" | tail -n 1 | sed -r 's/\s+/,/g' | cut -d ',' -f4`
     
      # status line
      >&2 echo $self: split:$i free:$(($free/1024))MB
      
      if [ $free -lt $splitSize ]; then
     
          # next split doesn't fit on the media, must load another disk
          ./create-close-disk.sh

          # loop until we get usable disk or control-c 
          while [ true ]; do

              # wait for media to be loaded, we could get control-c
              # if we are giving up
              >&2 read -p "Load the next disk and press enter"
              if [ $? -ne 0 ]; then
                  >&2 echo $self: aborting due to interrupt or control-c
                  exit 3
              fi

              ./create-init-disk.sh
              if [ $? -eq 0 ]; then
                  break
              fi
          done
      else
          # next split is on the current media so
          # add its number to index
          echo @split:$(($i + 1))
      fi 

      exit 0
   fi
done

>&2 echo $self: ran out of numbers
exit 2

