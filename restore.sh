#!/usr/bin/env bash

defaultconfig="${HOME}/.config/pukcab.conf"

level=-1
backupsource=""
restorepath=""
verbose=""

usage() {
  echo "usage: $0 [-c configfile] [-v] [-s source] [-d destination] [-l level]"
  echo "  -c    path to non-default config file"
  echo "  -v    verbose tarball extraction"
  echo "  -s    source of backup, default is to read target from config"
  echo "  -d    destination of restore, default is ./restore"
  echo "  -l    number of incremental backup, default is latest"
}

configfile="${defaultconfig}"
while getopts ":c:s:d:l:v" o; do
  case "${o}" in
    c)
      configfile=${OPTARG}
      ;;
    v)
      verbose="vv"
      ;;
    s)
      backupsource=${OPTARG}
      ;;
    d)
      restorepath=${OPTARG}
      ;;
    l)
      level=${OPTARG}
      ;;
    esac
done
shift $((OPTIND-1))

if [ ! -f $configfile ]
then
  echo
  echo "error: config file not found! ${configfile}"
  echo
  usage
  exit 1
fi

if [ "${backupsource}" == "" ]
then
  backupsource=`grep ^target ${configfile} | sed 's/^target //' | head -n 1`
  backupsource=`find /mnt/backup -type d | sort | tail -n 1`
fi
echo "backup source: $backupsource"

if [ "${restorepath}" == "" ]
then
  restorepath="./restore"
  mkdir -p "${restorepath}"
fi

echo "restore path: ${restorepath}"

if [ 0 -gt ${level} ]
then
  echo "restoring to latest backup"
  tarballs=`ls ${backupsource}/backup_*.tgz`
else
  echo "restoring to index ${level}"
  headcount=$((level+1))
  tarballs=`find ${backupsource} -name 'backup_*.tgz' | sort | head -n ${headcount}`
fi

if [ 0 -ne $? ]
then
  echo "no backup files found"
  exit 2
fi

mkdir -p "${restorepath}"

for tarball in $tarballs
do
  tar --listed-incremental=/dev/null \
    -C ${restorepath} \
    -xz${verbose} \
    -f ${tarball}
done
