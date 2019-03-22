#!/bin/bash

# script for jenkins job with an embedded shell command that is creating the
# log dir on every run and does not purge the workspace

NUMBER_TO_KEEP=5
if [ -z "${NUMBER_TO_KEEP}" ] ; then
  NUMBER_TO_KEEP=3
fi
CURRENT_LOGDIR='log10'
DUMMYFILE='dummy'
if [ ! -z "${CURRENT_LOGDIR}" ] ; then
  MARKER_FILE=$CURRENT_LOGDIR
else
  MARKER_FILE=$DUMMYFILE
fi
DEBUG=false
if [ -z "${DEBUG}" ] ; then
  DEBUG=false
fi

ADMIN_USER='root'
BUILD_USER='jenkins'

ARRAY_LOGDIRS=()
if $DEBUG ; then
  echo "find . -maxdepth 1 -type d  -and \( ! -cnewer ${MARKER_FILE} \) -and -name '*' -and \\( -user ${BUILD_USER} -or -user ${ADMIN_USER} \\)"
fi
echo 'Collecting log dirs, pass 1'
for LOGDIR in $(find . -maxdepth 1 -type d  -and \( ! -newer ${MARKER_FILE} \) -and -name 'log*' -and \( -user ${BUILD_USER} -or -user ${ADMIN_USER} \) ) ;  do
  if [ ${LOGDIR} != '..' -a ${LOGDIR} != '.' ] ; then
    echo "Adding ${LOGDIR}"
    ARRAY_LOGDIRS+=($LOGDIR)
  fi
done
echo "Keeping ${NUMBER_TO_KEEP} recent log dirs, pass 2"

if $DEBUG ; then
  echo "ls -ldt ${ARRAY_LOGDIRS[*]}"
fi
CNT=1
for LOGDIR in $(ls -1dt ${ARRAY_LOGDIRS[*]}) ; do
  CNT=$(expr $CNT + 1)
  if [[ $CNT > $NUMBER_TO_KEEP ]] ; then
    echo "Purging ${LOGDIR}..."
    rm -fr $LOGDIR
  else
    echo "Keeping ${LOGDIR}"
  fi
done
