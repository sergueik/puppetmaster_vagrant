#!/bin/bash

LOGS=${1:-/tmp/xxx}

USER_OWNER=$(stat -c %U $LOGS)
if [ $(whoami) != $USER_OWNER ]; then
  echo "${LOGS} is owned by another user ($USER_OWNER)"
  GROUP_OWNER=$(stat -c %G $LOGS)
  groups $(whoami) | grep -q "$GROUP_OWNER"
  if [ $? != 0 ] ;  then
    echo "${LOGS} is owned by a group ($GROUP_OWNER) than $(whoami) does now belong. There will be logging errors"
    exit 1
  fi
fi


