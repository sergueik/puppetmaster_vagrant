#!/bin/bash

DEBUG=1
SELF=$(basename $0)
PROCNAME=${1:-VBoxService}
PROCMASK=$(echo $PROCNAME | sed 's|\([a-z0-9]\)$|\[\1\]|')
# Should the following work?
# PROCMASK=$(echo $PROCNAME | sed 's|\([a-z0-9]\)$|[\1]|')

if [[ $DEBUG -ne 0 ]]
then
  echo "PROCNAME=${PROCNAME}"
  echo "PROCMASK=${PROCMASK}"
  /bin/ps -ef | grep $PROCMASK | grep -v $SELF
  # sometimes there is suggestons to swap the
  # command and its output redirection (>/dev/null or 1>/dev/null)
  # the folloing line illustrates why this is a bad idea
  # if a status code check is performed after the command run

  echo ">/dev/null /bin/ps -ef | grep $PROCMASK | grep -v $SELF"
  >/dev/null /bin/ps -ef | grep $PROCMASK | grep -v $SELF
  echo $?

  echo "/bin/ps -ef | grep $PROCMASK | grep -v $SELF > /dev/null"
  /bin/ps -ef | grep $PROCMASK | grep -v $SELF > /dev/null
  echo $?
fi
/bin/ps -ef | grep $PROCMASK | grep -v $SELF > /dev/null
if [[ $? -ne 0 ]]
then
  echo "${PROCNAME} failing."
  exit 1
else
  echo "${PROCNAME} is running."
  exit 0
fi

