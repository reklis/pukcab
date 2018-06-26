# pukcab

the simplest possible incremental linux backup and restore

# usage

    usage: ./backup.sh [-c config] [-v] [-n]
      -c    path to non-default config file
      -v    verbose tarballing
      -n    do not unmount after backing up

    usage: ./restore.sh [-c configfile] [-v] [-s source] [-d destination] [-l level]
      -c    path to non-default config file
      -v    verbose tarball extraction
      -s    source of backup, default is to read target from config
      -d    destination of restore, default is ./restore
      -l    number of incremental backup, default is latest


# configuration example

    # ~/.config/pukcab.conf
    mount /mnt/san
    target /mnt/san/backup
    source /home/user1
    source /etc
    exclude /home/user1/.cache
    exclude /home/user1/Downloads

## configuration items

### mount

Single value. Optional.

Path to be mounted before backing up.  Will be unmounted unless `-n` is specified.

### target

Single value. Required.

This is the place where the tarballs will be located.  Organized by year-month.

example:

    /mnt/san/backup/2018-07/backup.0.tgz   # tarball
    /mnt/san/backup/2018-07/backup.0.snar  # backup index
    /mnt/san/backup/2018-07/backup.1.tgz   # incremental tarball
    /mnt/san/backup/2018-07/backup.1.snar  # incremental backup index


This is organized so that each month there is a full backup, and every subsequent backup that month will be incremental


### source

Multiple values.

Stuff to copy into the tarball.  Files or directories.


### exclude

Multiple values.

Stuff to skip when backing up.  Files or directories.

This is a straight passthrough to tar, so file globbing is supported.

