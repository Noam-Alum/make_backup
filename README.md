# introduction

Make backups of selected files and directories by count of block device insertion.

### some background

<p>Recently while being at work I unfortunately had to format my computer due to some internal file changes I've made 🫠.<br>
The fact that I didn't have any backups with all my important files and directories was so absurd to me and made me think about it all day long, not to speak of how my boss  felt about me wasting time restoring my computer 😅, me being me I have to make my own thing... so I came up with this daemon.</p>

### Main feathers:

- If set correctly, it should backup your files and directories to a given directory in your block device.
- Removes old backups. (this can be set in the configuration file)
- Follows the general Linux conventions for proper daemon development (incorporating udev, rsyslog, and systemd with correct directory structures).
- Start backuping based on block device insertion. (eg, every five times I connect my SSD it would make a backup and save it there)

<br>

>**Disclaimer:**
>
>My SSD I used for this script is using NFT as its file system, as a result of that I could not use rsync with hardlinks but I do recommend doing so as it would take much less disk space and processing power.

---

# Installation

> This backuping solution is for Linux users only.

## Install zipped project

```sh
wget -O make_backup.zip https://codeload.github.com/Noam-Alum/make_backup/zip/refs/heads/main
```

## unzip
```sh
unzip make_backup.zip
```

## rsync files
```sh
rsync -av make_backup-main/etc/ /etc/
rsync -av make_backup-main/var/ /var/
rsync -av make_backup-main/opt/ /opt/
```

## remove traces
```sh
rm -rf make_backup-main make_backup.zip
```

## handle services
```sh
sudo systemctl restart udev rsyslog
sudo systemctl daemon-reload
systemctl enable make_backup.service
systemctl start make_backup.service
```

<br>

> **DANGER:**
> Make sure to change `/etc/systemd/system/make_backup.service` user and group to your likings:
> 
> ```sh
> User=changeme
> Group=changeme
> ```

---

# Usage

> **This section is reffering to the `/etc/make_backup/make_backup.conf` file.**

## count_location

Select a file to count block device entries:
```
count_location="/var/test.txt"
```
**This needs to be the full path to a file (e.g. /path/to/file.txt)**

## bd_count

Set the maximum count of block device entries that triggers a backup:
```
bd_count="5"
```
**This directive cannot be 0 and lower!**

## parent_directory

Set the main backuping directory:

```
parent_directory="/change/this/to/backups_dir"
```
**This should be without the / at the end!**

## Choose items to backup
Add the files and directories you want to backup in between this lines:
```
> start items to backup <
/backup/this/file.txt
/backup/this/direcotory/
> end items to backup <
```
make sure that directories **ends with /** and files **dont!**

## control amount of backups
To control how many backups remain in the chosen backups directory first check if its enabled.
```
## remove old backups
# yes | no
rm_old_backups="yes"
```
and make sure its set to `yes`.

## Backups retained

**We can change the following directives to control how many backups remain in the chosen backups directory.**

* **backup_in_c_month**

The amount of backups in the current month directory.

```
backup_in_c_month="14"
```

* **backup_in_month**

The amount of backups in past months.

```
backup_in_month="1"
```

* **month_in_c_year**

The amount of months to leave in past year.

```
month_in_c_year="12"
```

* **month_in_year**

The amount of months to leave in past year.

```
month_in_year="1"
```
