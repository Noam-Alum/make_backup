# Make Backup

Make backups of selected files by count of block device insertion
![](header.png)

# Installation

## OS X & Linux:

```sh
# Install zipped project
wget -O make_backup.zip https://codeload.github.com/Noam-Alum/make_backup/zip/refs/heads/main

# unzip
unzip make_backup.zip

# rsync files
rsync -av make_backup-main/etc/ /etc/
rsync -av make_backup-main/var/ /var/

# remove directory
rm -rf make_backup-main

# handle services
sudo systemctl restart udev
sudo systemctl daemon-reload
systemctl enable make_backup.service
systemctl start make_backup.service
```

# Usage example && Development setup

## set count
First you should set count of how many times a block device entries cause a backup:
```sh
bd_count=[5];
```
**This settings cannot be 0 and lower!**

## set backup directory
By default make backup backups to the /tmp directory as a fallback to the main backups directory, to choose the backup directory we need to edit the /etc/make_backup/Make_Backup.conf configuration file.

```sh
parent_directory=[/change/this/to/backkups_dir];
```
Swap /change/this/to/backkups_dir to the actual path to your backups directory *with out the / at the end!*

## choose items to backup
We can add the files and direcotories we want to backup in between this lines:
```sh
> start items to backup <
/backup/this/file.txt
/backup/this/direcotory/
> end items to backup <
```
make sure that direcotories **ends with /** and files **dont!**

## control amount of backups
To control how many backups remain in the choosen backups directory we first need to check if its enables.
```sh
## remove old backups
# yes | no
rm_old_backups=[yes];
```
and make sure its set as ```yes```.

```sh
backup_in_c_month=[14];
backup_in_month=[1];
month_in_c_year=[12];
month_in_year=[1];
```
We can change this settings to control how many backups remain in the choosen backups directory like so:
* backup_in_c_month = the amount of backups in the current month directory.
* backup_in_month = the amount of backups in past months.
* month_in_c_year = the amount of months to leave in past year.
* month_in_year = the amount of months to leave in past year.

## Meta

Noam Alum – [Website](https://ncode.codes) – nnoam.alum@gamil.com
