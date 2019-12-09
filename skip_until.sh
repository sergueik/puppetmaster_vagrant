#!/bin/sh

# NOTE: probably the next line only works with bash
START_DATE=${1:-2019-12-24}

if [ ! -z "${START_DATE}" ]
then
  expr $(date +'%Y-%m-%d') '<' "${START_DATE}"  > /dev/null
  if [ $? -eq 0 ]
  then
    echo "Not starting until ${START_DATE}"
    exit 0
  fi
fi
echo 'Starting work'


