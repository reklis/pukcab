# pukcab

the simplest possible linux backup and restore


# configuration example


    # ~/.config/pukcab.conf
    target /mnt/san/backup
    source /home/user1
    source /etc
    exclude /home/user1/.cache
    exclude /home/user1/Downloads

## configuration items

### target

Single value.

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

Stuff to skip when backing up.  Files or directories.


