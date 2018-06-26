#!/usr/bin/env bash

defaultconfig="${HOME}/.config/pukcab.conf"

usage() {
  echo
  echo "usage: $0 [-c config] [-v] [-n]"
  echo "  -c    path to non-default config file"
  echo "  -v    verbose tarballing"
  echo "  -n    do not unmount after backing up"
  echo
}

configfile="${defaultconfig}"
verbose=""
shouldunmount=true

while getopts ":c:vn" o; do
  case "${o}" in
    c)
      configfile=${OPTARG}
      ;;
    v)
      verbose="vv"
      ;;
    n)
      shouldunmount=false
      ;;
    esac
done
shift $((OPTIND-1))

if [ ! -f $configfile ]
then
  echo
  echo "error: config file not found! ${configfile}"
  echo
  echo example config:
  echo
  echo mount /mnt/san
  echo target /mnt/san/backup
  echo source /home/user1
  echo source /etc
  echo exclude /home/user1/.cache
  echo exclude /home/user1/Downloads
  echo
  echo default config location: ${defaultconfig}
  usage
  exit 1
fi

mount=`grep ^mount ${configfile} | sed 's/^mount //' | head -n 1`

if [ -n "${mount}" ]
then
  echo "mounting ${mount}..."
  sudo mount ${mount}
fi

sources=`grep ^source ${configfile} | sed 's/^source //' | xargs`

if [ "" = "${sources}" ]
then
  echo
  echo "error: $configfile missing source entries"
  echo
  usage
  exit 1
fi

excludes=`grep ^exclude ${configfile} | sed 's/^exclude //' | xargs printf " --exclude %s"`

if [ " --exclude " = "${excludes}" ]
then
  excludes=""
fi

target=`grep ^target ${configfile} | sed 's/^target //' | head -n 1`

if [ "" = "${target}" ]
then
  echo
  echo "error: $configfile missing target entry"
  echo
  usage
  exit 1
fi

datestamp=`date +'%Y-%m'`
target=`grep ^target ${configfile} | sed 's/^target //' | head -1`
target="${target}/${datestamp}"
mkdir -p ${target}
echo "backing up to ${target}..."

lastindex=`ls -1 ${target}/*.snar 2>/dev/null | tail -n 1`
nextindex=0

if [ "${lastindex}" != "" ]
then
  lastindex=`echo $lastindex | egrep -o '[0-9]+\.snar$' | sed 's/\.snar$//'`
  nextindex=$(( lastindex + 1 ))
  cp ${target}/backup_${lastindex}.snar ${target}/backup_${nextindex}.snar
fi

backupfile="backup_${nextindex}"

tar --ignore-failed-read \
  --no-check-device \
  --listed-incremental=${target}/${backupfile}.snar \
  ${excludes} \
  -czp${verbose} \
  -f ${target}/${backupfile}.tgz ${sources}

du -ah ${target}

if [ -n "${mount}" ]
then
  if [ true = $shouldunmount ]
  then
    echo "unmounting ${mount}..."
    sudo umount ${mount}
  fi
fi
