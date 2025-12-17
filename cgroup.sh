#!/bin/sh

cgcreate -g memory:backup
#cgcreate -g blkio:backup
echo 2048M > /sys/fs/cgroup/memory/backup/memory.limit_in_bytes
#echo 100 > /sys/fs/cgroup/blkio/backup/blkio.weight

