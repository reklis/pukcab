#!/usr/bin/env bash

configfile="${HOME}/.config/pukcab.conf"

if [ ! -f $configfile ]
then
  echo "config file not found! ${configfile}"
  echo
  echo example config:
  echo
  echo target /mnt/san/backup
  echo source /home/user1
  echo source /etc
  echo exclude /home/user1/.cache
  echo exclude /home/user1/Downloads
  echo
  exit
fi

datestamp=`date +'%Y-%m'`
target=`grep ^target ${configfile} | sed 's/^target //' | head -1`
target="${target}/${datestamp}"
mkdir -p ${target}

lastindex=`ls -1 ${target}/*.snar 2>/dev/null | tail -n 1`
nextindex=0

if [ "${lastindex}" != "" ]
then
  lastindex=`echo $lastindex | egrep -o '[0-9]+\.snar$' | sed 's/\.snar$//'`
  nextindex=$(( lastindex + 1 ))
  cp ${target}/backup_${lastindex}.snar ${target}/backup_${nextindex}.snar
fi

sources=`grep ^source ${configfile} | sed 's/^source //' | xargs`
excludes=`grep ^exclude ${configfile} | sed 's/^exclude //' | xargs printf " --exclude %s"`

backupfile="backup_${nextindex}"

tar --ignore-failed-read \
  --no-check-device \
  --listed-incremental=${target}/${backupfile}.snar \
  ${excludes} \
  -czpvvf ${target}/${backupfile}.tgz ${sources}

du -ah ${target}
