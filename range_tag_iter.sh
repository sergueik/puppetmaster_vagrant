i#!/bin/bash

# enable DEBUG for testing
DEBUG=false
START_TAG=869
END_TAG=869
OPTS=$(getopt -o hds:e: --long help,debug,start:end: -n 'tarse-options' -- "$@")
if [ $? != 0 ] ; then echo 'Failed parsing options' >&2 ; exit 1 ; fi
START_TAG=1
END_TAG=1
RANGE='month'
while true; do
  case "$1" in
    -h | --help ) HELP=true; shift ;;
    -d | --debug ) DEBUG=true; shift ;;
    -s | --start ) START_TAG="$2"; shift; shift ;;
    -e | --end ) END_TAG="$2"; RANGE='week';shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [[ $DEBUG == 'true' ]] ; then
  echo "START_TAG=${START_TAG}"
  echo "END_TAG=${END_TAG}"
fi
expr $START_TAG \< $END_TAG > /dev/null
if [ $? != 0 ] ; then
  echo 'Invalid range'
  exit 0
fi

for TAG in $(seq $START_TAG 1 $END_TAG) ; do
  echo "# repetition ${TAG}"
  echo curl https://www.google.com/?q=$TAG
done

