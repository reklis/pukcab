#!/usr/bin/env bash

backupsource=$1
restorepath=$2

usage() {
  echo "usage: $0 <backup source folder> <restore destination>"
}

if [ "${backupsource}" == "" ]
then
  usage
  exit
fi

if [ "${restorepath}" == "" ]
then
  usage
  exit
fi

for tarball in `ls ${backupsource}/*.tgz`
do
  tar --listed-incremental=/dev/null -C ${restorepath} -xzvvf ${tarball}
done
