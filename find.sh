#!/bin/bash
#
# Tarrible backup search
#
# Finds the disk/split range of a file name or globbing pattern
# in a backup set, to be used with extract.sh
#
# The output lists the files matching followed immediately
# the the start and end positions in the backup set, then
# repeats for all matching ranges.
#
# Examples:
#
# Find the location of an imporant document:
#   ./find.sh ~/vault/mybackup.index.gz "2011-tax-return.pdf"
#
# Find the location of "Photos" folder of "Documents" folder:
#   ./find.sh ~/vault/mybackup.index.gz Documents/Photos
#
self=$0
index=$1   # gzipped index from backup creation
pattern=$2 # file name / globbing pattern

# read every line from index
mapfile lines < <(zcat "$index")

startDisk=none
startSplit=none
endDisk=none
endSplit=none
found=

# loop over the lines
i=0
line=${lines[$i]}
i=$(($i + 1))

while [ -n "$line" ]; do

    # find first line that matches, the starting disk and split
    while [ -n "$line" ]; do

        if [[ "$line" = *@disk* ]]; then
            startDisk=$line
        
        elif [[ "$line" = *@split* ]]; then
            startSplit=$line

        elif [[ "$line" = *$pattern* ]]; then
            echo $line
            found=$line
            break;
        fi

        line=${lines[$i]}
        i=$(($i + 1))
    done

    if [ -z "$found" ]; then
       # no start found, give up
       exit 0 
    fi

    endDisk=$startDisk
    endSplit=$startSplit
    line=${lines[$i]}
    i=$(($i + 1))

    # find first line that doesn't match, giving the ending disk and split
    while [ -n "$line" ]; do

        if [[ "$line" = *@disk* ]]; then
            endDisk=$line

        elif [[ "$line" = *@split* ]]; then
            endSplit=$line

        elif [[ ! "$line" = *$pattern* ]]; then
            break;

        else
            echo $line
        fi

        line=${lines[$i]}
        i=$(($i + 1))
    done

    echo $startDisk $startSplit
    echo $endDisk $endSplit

    # keep searching until running out of matching lines
    found=
done

