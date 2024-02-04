# Make Backup

### Make backups of selected files by count of block device insertion

<p align="center">
  <img src="https://www.rackone.it/wp-content/uploads/2023/01/migliori-software-backup.jpg" alt="Migliori Software Backup">
</p>

### Backing up data from a personal computer is crucial for several reasons:

1. **Data Loss Protection:** <br>
   Safeguards against accidental deletion, hardware failures, or software issues, ensuring you don't lose important files, documents, or memories.

2. **System Crashes and Malware:** <br>
   Protects your data in case of system crashes, malware attacks, or ransomware incidents, allowing for a quick recovery without compromising personal information.

3. **Hardware Failures:** <br>
   Acts as a safety net in the event of hardware failures, such as a malfunctioning hard drive or a damaged computer, preventing permanent data loss.

4. **Peace of Mind:** <br>
   Provides peace of mind knowing that your important files are securely stored elsewhere, reducing stress and anxiety associated with potential data disasters.

5. **Ease of Recovery:** <br>
   Enables quick and efficient recovery in case of unexpected events, allowing you to restore your computer to a previous state with minimal downtime.

6. **Upgrades and Replacements:** <br>
   Facilitates smooth transitions during computer upgrades or replacements, ensuring a seamless transfer of your files and settings to a new device.

7. **Documenting Progress:** <br>
   Supports tracking changes over time, as backup solutions often offer versioning. This allows you to retrieve previous versions of files and document your work or project progress.

In essence, regular backups serve as a reliable insurance policy for your digital life, preserving your valuable data and mitigating the impact of unforeseen events.

<hr>

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
rm -rf make_backup-main make_backup.zip

# handle services
sudo systemctl restart udev rsyslog
sudo systemctl daemon-reload
systemctl enable make_backup.service
systemctl start make_backup.service
```
>Make sure to change /etc/systemd/system/make_backup.service user and group to youe likings
>```sh
>User=changeme
>Group=changeme
<br>
<hr>
<br>

# Usage example && Development setup
> This section is reffering to the */etc/make_backup/Make_Backup.conf* file.

<div style="text-align: center;">
  <img src="https://www.elegantthemes.com/blog/wp-content/uploads/2021/11/configuring-woocommerce-settings-1.png" alt="WooCommerce Settings">
</div>

## set count
Firstly you need to select a file to count block device entries
```sh
count_location=[/var/test.txt];
```
**This needs to be the full path to a file !** (/path/to/file.txt)

Then you should set count of how many times a block device entries cause a backup:
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

We can change this settings to control how many backups remain in the choosen backups directory like so:
```sh
backup_in_c_month=[14];
backup_in_month=[1];
month_in_c_year=[12];
month_in_year=[1];
```
* backup_in_c_month = the amount of backups in the current month directory.
* backup_in_month = the amount of backups in past months.
* month_in_c_year = the amount of months to leave in past year.
* month_in_year = the amount of months to leave in past year.

<hr>

## Contact

Noam Alum – [Website](https://ncode.codes) – nnoam.alum@gamil.com
