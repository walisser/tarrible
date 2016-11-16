#!/bin/bash

self=$0
dst="$TARRIBLE_DST"
src="$TARRIBLE_SRC"
curr="$dst/current.tar"

disk=`cat "$dst/current.disk" | cut -d ':' -f 1`
split=`cat "$dst/current.disk" | cut -d ':' -f 2`

diskLabel="disk$disk"

# loop until we get usable disk or control-c 
while [ true ]; do

    # wait for media to be loaded, we could get control-c
    # if we are giving up
    >&2 echo
    >&2 read -p "Load $diskLabel in $src and press enter"
    if [ $? -ne 0 ]; then
        >&2 echo $self: aborting due to interrupt or control-c
        exit 1
    fi

    if [ ! -e "$src" ]; then
        >&2 echo $self: source $src does not exist
        continue;
    fi

    if [ ! -e "$src/00001.tar" ]; then
        >&2 echo $self: source does not contain a backup
        continue;
    fi

    label=`cat "$src/label"`;
    if [ "$label" != "$diskLabel" ]; then
        >&2 echo $self: the backup label does not match: got \"$label\", expected \"$diskLabel\"
        continue
    fi

    num=`printf %.5d $split`
    tar="$src/$num.tar"
    if [ ! -e "$tar" ]; then
        >&2 echo $self: requested split $num does not exist
        continue;
    fi

    ln -sfv "$tar" "$curr"
    if [ $? -ne 0 ]; then
        >&2 echo $self: failed to make symlink
        continue;
    else
        break
    fi
done

