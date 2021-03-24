#!/bin/bash
# https://linuxize.com/post/at-command-in-linux/

DEFAULT_BEGIN_DATE=$(date +'24 Mar 2021 00:45')
BEGIN_DATE=${1:-$DEFAULT_BEGIN_DATE}
DELAY=$(expr 10 \* $(expr $(/usr/bin/od -A n -t u -N 1 /dev/urandom ) \% 31 ) )
echo "DELAY=${DELAY}"
BEGIN_EPOCH=$(expr $DELAY + $(date -d "${BEGIN_DATE}" +'%s'))
DELAYED_START_DATE=$(date -d @$BEGIN_EPOCH)
echo -n 'will start at '
echo $DELAYED_START_DATE

# convert to an at format
AT_START_DATE=$(date -d "$DELAYED_START_DATE" +'%Y%m%d%H%M.%S')
# NOTE: do not run beyond this point in Windows bash

LOGFILE=/tmp/a$$.log
if [[ "$OS" != 'Windows_NT' ]] ; then
  /usr/bin/at -t  $AT_START_DATE <<EOF
/bin/sh -c "echo 'launched'" | /usr/bin/tee $LOGFILE
EOF
  /usr/bin/at -l
  echo "Check the $LOGFILE"
fi

