# Make Backup

Make backups of selected files by count of block device insertion
![](header.png)

## Installation

OS X & Linux:

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

## Usage example && Development setup

By default make backup backups to the /tmp directory as a fallback to the main backups directory, to choose the backup directory we need to edit the /etc/make_backup/Make_Backup.conf configuration file.

```sh
parent_directory=[/change/this/to/backkups_dir];
```
Swap /change/this/to/backkups_dir to the actual path to your backups directory *with out the / at the end!*

We can add the files and direcotories we want to backup in between this lines:
```sh
> start items to backup <
/backup/this/file.txt
/backup/this/direcotory/
> end items to backup <
```
make sure that direcotories *ends with /* and files *dont!*

To control how many backups remain in the choosen backups directory we first need to check if its enables.
```sh


## Release History

* 0.2.1
    * CHANGE: Update docs (module code remains unchanged)
* 0.2.0
    * CHANGE: Remove `setDefaultXYZ()`
    * ADD: Add `init()`
* 0.1.1
    * FIX: Crash when calling `baz()` (Thanks @GenerousContributorName!)
* 0.1.0
    * The first proper release
    * CHANGE: Rename `foo()` to `bar()`
* 0.0.1
    * Work in progress

## Meta

Your Name – [@YourTwitter](https://twitter.com/dbader_org) – YourEmail@example.com

Distributed under the XYZ license. See ``LICENSE`` for more information.

[https://github.com/yourname/github-link](https://github.com/dbader/)

## Contributing

1. Fork it (<https://github.com/yourname/yourproject/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request

<!-- Markdown link & img dfn's -->
[npm-image]: https://img.shields.io/npm/v/datadog-metrics.svg?style=flat-square
[npm-url]: https://npmjs.org/package/datadog-metrics
[npm-downloads]: https://img.shields.io/npm/dm/datadog-metrics.svg?style=flat-square
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[wiki]: https://github.com/yourname/yourproject/wiki
