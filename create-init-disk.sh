#!/bin/bash

self=$0
dst="$TARRIBLE_DST"
index="$TARRIBLE_INDEX"
splitSize="$TARRIBLE_SPLIT_SIZE"

# prevent overwriting existing backup
if [ -e "$dst/index.gz" -o -e "$dst/label" -o -e "$dst/00001.tar" ]; then
    >&2 echo  $self: destination contains a backup
    exit 1
fi

# prevent using disk that's already or not mounted
if [ ! -e $dst ]; then
    >&2 echo $self: $dst does not exist
    exit 2
fi

free=`df "$dst" | tail -n 1 | sed -r 's/\s+/,/g' | cut -d ',' -f4`
if [ $free -lt $splitSize ]; then
    >&2 echo $self: destination is full
    exit 3
fi


# read disk counter
disk=`cat "$index.disk"`

# increment disk counter
echo $(($disk + 1)) > "$index.disk"

>&2 echo $self: init disk $disk

# add index entries
echo @disk:$disk
echo @split:1

# add disk label
echo disk$disk > "$dst/label"

exit 0
