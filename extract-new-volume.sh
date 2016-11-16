#!/bin/bash
#
# Tarrible extraction handler
#
# This script is invoked by tar when it needs the next
# segment of a multi-volume archive.
#
self=$0
dst="$TARRIBLE_DST"
src="$TARRIBLE_SRC"
curr="$dst/current.tar"

currDisk=`cat "$dst/current.disk" | cut -d ':' -f 1`
endDisk=`cat  "$dst/end.disk" | cut -d ':' -f 1`
endSplit=`cat "$dst/end.disk" | cut -d ':' -f 2`

# read current split number from the symlink, use
# a trick to get rid of the leading zeroes
currSplit=`basename \`readlink "$curr"\` | cut -d '.' -f 1`
nextSplit=$(( $(( 1$currSplit - 100000)) + 1))


num=`printf %.5d $nextSplit`
tar="$src/$num.tar"

if [ -e "$tar" ]; then

    if [ $currDisk -eq $endDisk -a $nextSplit -gt $endSplit ]; then
        >&2 echo $self: reached the end
        exit 1
    fi
    
    # link the next split
    >&2 ln -sfv "$tar" "$curr"
    if [ $? -ne 0 ]; then
        >&2 echo $self: failed to link current.tar, giving up
        exit 2
    fi

else 

    # ran out of splits on this disk, load the next one

    # update the current disk file to the next disk, first split
    nextDisk=$(($currDisk + 1))
    echo $nextDisk:1 > "$dst/current.disk"
    
    ./extract-load-disk.sh
    if [ $? -ne 0 ]; then
        exit 2
    fi
fi

