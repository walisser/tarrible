# Tarrible Backup Utility

Tarrible is a set of shell scripts for creating backups that span multiple disks/volumes. It was created because the mainstream tools for Linux (bacula, amanda) were too complicated to setup or use, or didn't have the features desired.

As the name suggests, the tar utility is used to do the actual archival. The tar file is split into segments until the current disk of the backup is filled. At this point, you are asked to switch the disk, and then the process repeats until the backup is complete. An index file is created for locating the disk/split that contains a given file.

By default, tarrible splits archives into 1GB segments but you can modify this in create.sh. You can also pass additional parameters through to tar for example to do incremental backups.

## Tarrible Features
- Only uses tar, bash, and a few other common tools
- Spans disks/volumes automatically and prompts to insert the next volume as required
- Automatically fills the entire volume, no volume setup or labeling required
- Creates index file listing everything backed up and what disk/split contains each file
- Restores entire backups or individual files/folders without reading the entire backup set
- Saves a copy of the index on each disk/volume in case it gets lost

## Why Use Tarrible?
- Customize your own backup solution
- Backup on hard drives without using another RAID or NAS
- Data folders are larger than the media/disks available for backup
- A mix of different media/disks of different capacities or types may be used
- Get a cold-storage/offline backup on the cheap (without using tape or another raid array)

## Creating a Full (Level 0) Backup
```bash
# mount a disk and create folder to contain the backup
mount /dev/sdg1 /mnt/disk
mkdir /mnt/disk/mydata.20161201

# start the backup
./create.sh /mnt/mydata /mnt/disk/mydata.20161201 /tmp/mydata.index

# save the index for future reference
gzip -9 /tmp/mydata.index
mv /tmp/mydata.index.gz ~/backups/mydata.20161201.gz

# remove the disk and store it somewhere safe
umount /mnt/disk
```

## Recovering a file
To recover a single file, search for it in the backup index and extract using the begin/end location and path
```bash
# find the file
./find.sh ~/backups/mydata.20161201.gz current-liabilities.xls

    > ./financial/current-liabilities.xls
    > @disk1 @split10
    > @disk1 @split11

mkdir /tmp/recovered
mount /dev/sdg1 /mnt/disk
./extract.sh /mnt/disk/mydata.20161201 /tmp/recovered/ 1:10 1:11 ./financial/current-liabilities.xls 
```

## Recovering a folder
Similarly, you can search for a folder name. Find will list the folder contents followed by location.
```bash
# find the file
./find.sh ~/backups/mydata.20161201.gz "Photos/Hawaii"

    > ./Vacation/Photos/Hawaii/
    > ./Vacation/Photos/Hawaii/beach.jpg
    > ./Vacation/Photos/Hawaii/paul.jpg
    > ./Vacation/Photos/Hawaii/surfing.jpg
    > ./Vacation/Photos/Hawaii/volcano.jpg
    > @disk1 @split9
    > @disk1 @split9

mkdir /tmp/recovered
mount /dev/sdg1 /mnt/disk
./extract.sh /mnt/disk/mydata.20161201 /tmp/recovered/ 1:9 1:9 ./Vacation/Photos/Hawaii 
```

## Full recovery
To recover the complete backup, omit the file path and start with disk 1, split 1, ending with the last disk/split.
```bash
mkdir /tmp/recovered
mount /dev/sdg1 /mnt/disk
./extract.sh /mnt/disk/mydata.20161201 /tmp/recovered/ 1:1 2:99 
```

## Verifying a Backup
To verify a backup, use extract.sh with --to-stdout and send it to /dev/null. You'll need a temporary directory for bookkeeping. If tar encounters a problem it will print to the console stderr. Note this will fail if the first split is in the middle of a backed up file (contains neither the beginning or end). In this case, start verifying from the next split. 
```bash
rm -rf /tmp/tarrible
mkdir /tmp/tarrible
./extract.sh /mnt/disk/mydata.20161106 /tmp/tarrible 5:1 5:357 --to-stdout > /dev/null
rm -rf /tmp/tarrible
```

### Verify/Restore Errors
When verifying or restoring a backup you might see these errors.
```
tar: `some-file-path`: is possibly continued on this volume: header contains truncated name
```
This means tar is not 100% sure it has the correct split (volume) because the name was truncated at creation. Since the splits are numbered there is no chance of this happening. It might happen if you swapped in the wrong disk, however the disk labels are checked so you can't do that.

---

```
tar: `some-file-path`: Cannot extract -- file is continued from another volume
```
If you started verifying in the middle of the backup - say you only want to verify disk 2 of a 2 disk set -, the first file on the disk will start with the remainder of the last file on disk 1, so it can't be recovered.

---

```
tar: /tmp/tarrible/current.tar: Cannot read: Input/output error
```
You probably have bad blocks on the backup media or another hardware problem.


## Creating an Incremental Backup
To use incremental backups, you must first do a full backup (level 0) and create an incremental index (.snar file), and save it in addition to the tarrible index. This is simple since you can pass through additional parameters to tar at the end of create.sh and extract.sh.
```bash
mount /dev/sdg1 /mnt/disk
mkdir /mnt/disk/mydata.level0
./create.sh /mnt/mydata /mnt/disk/mydata.level0 /tmp/mydata.index --listed-incremental /tmp/mydata.snar
gzip -9 /tmp/mydata.index
mv /tmp/mydata.index.gz ~/backups/mydata.level0.gz
cp /tmp/mydata.snar ~/backup/mydata.level0.snar
```
After that, you can do a level 1 backup (only the differences since level 0 backup). If you want to do level 2 backup later, save the snar file again.
```
mount /dev/sdg1 /mnt/disk
mkdir /mnt/disk/mydata.level1
cp ~/backup/mydata.level0.snar /tmp/mydata.snar
./create.sh /mnt/mydata /mnt/disk/mydata.level1 /tmp/mydata.index --listed-incremental /tmp/mydata.snar
gzip -9 /tmp/mydata.index
mv /tmp/mydata.index.gz ~/backups/mydata.level1.gz
cp /tmp/mydata.snar ~/backups/mydata.level1.snar
```
