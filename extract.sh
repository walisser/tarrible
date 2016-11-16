#!/bin/bash
#
# Tarrible backup recovery
# 
# Extract individual files, directories, or the full backup
# by specifying the path where the backup files are (source),
# and the place to extract files into (destination),
# the begin and end location in the backup set (from find.sh)
#
# To extract only a given file or folder put the archive path(s) in extraArgs
# 
# begin/end = pair of numbers x:y, x is the disk number in the set, y is the split number
#
self=$0
src=$1; shift 1   # location of the backup set
dst=$1; shift 1   # destination to write to
begin=$1; shift 1 # location of the first disk/split
end=$1; shift 1   # location of the last disk/split
extraArgs=$@      # extra arguments to pass to tar

tarCmd="tar --extract --multi-volume --directory \"$dst\" --file \"$dst/current.tar\" --new-volume-script ./extract-new-volume.sh $extraArgs"

# variables used in child scripts
export TARRIBLE_SRC="$src"
export TARRIBLE_DST="$dst"

beginDisk=`echo $begin | cut -d ':' -f1`
beginSplit=`echo $begin | cut -d ':' -f2`

endDisk=`echo $end | cut -d ':' -f1`
endSplit=`echo $end | cut -d ':' -f2`

echo $self: src=$src, dst=$dst, begin=disk$beginDisk:$beginSplit, end=disk$endDisk:$endSplit
echo $self: tar=$tarCmd

if [ ! -e $dst ]; then
    echo $self: dst does not exist
    exit 1
fi

echo $beginDisk:$beginSplit > "$dst/current.disk"
echo $endDisk:$endSplit > "$dst/end.disk"

# prompt for the first disk
./extract-load-disk.sh
if [ $? -ne 0 ]; then exit $?; fi

# start tarring
echo $self: starting tar 
eval $tarCmd

# remove tmp files
echo $self: restore complete
