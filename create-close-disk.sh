#!/bin/bash

self=$0
dst="$TARRIBLE_DST"
index="$TARRIBLE_INDEX"

# make a backup copy of the index so far
>&2 echo $self: "backing up index..."
cat "$index" | gzip -9 > "$dst/index.gz"

exit 0
