#!/bin/bash
#
# Tarrible backup creation
# 
# Create a backup of a directory, by specifying the path where the 
# backup files are (source), the place to write files into (destination),
# and the location of the index file.
#
#
self=$0
src=$1; shift 1 # source directory
dst=$1; shift 1 # destination directory (on mounted media)
index=$1; shift 1 # index directory (not on mounted media)
extraArgs=$@ # additional arguments for tar

# split size sets the max amount of waste (unused space) per disk,
# in addition to typical waste from file system overhead and reserved blocks
# maximum of 10000 splits per disk, so plan accordingly
splitSize=$((1024*1024)) # split size in KB (1024)

tarCmd="tar --verbose --create --multi-volume --tape-length $splitSize --file \"$dst/current.tar\" --new-volume-script ./create-new-volume.sh --directory \"$src\" $extraArgs . >> \"$index\""

# variables used in child scripts
export TARRIBLE_DST="$dst"
export TARRIBLE_SPLIT_SIZE="$splitSize"
export TARRIBLE_INDEX="$index"

echo $self: src=$src, dst=$dst, index=$index
echo $self: tar=$tarCmd

if [ -e "$index" ]; then
   echo $self: index file exists, will not overwrite
   exit 1
fi

# index header
echo @start:`date` > "$index"
echo @tar:$tarCmd >> "$index"
echo @src:$src    >> "$index"
echo @dst:$dst    >> "$index"

# init the first disk
echo 1 > "$index.disk"
./create-init-disk.sh >> "$index"
if [ $? -ne 0 ]; then exit $?; fi

# start tarring
echo $self: starting tar piping to $index...
eval $tarCmd

# rename the last split
for i in {1..10000}; do
    num=`printf %.5d $i`
    if [ -e "$dst/$num.tar" ]; then
       y=y
    else
       # rename the current split
       mv  "$dst/current.tar" "$dst/$num.tar"
       break;
    fi
done

# index trailer
echo @end:`date` >> "$index"

# close the last disk
./create-close-disk.sh >> "$index"

echo $self: backup complete
