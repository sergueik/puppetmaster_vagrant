#!/bin/bash
DEBUG=false
NAMES=869
VALUES=869
OPTS=$(getopt -o hdn:v: --long help,debug,names:values: -n 'tarse-options' -- "$@")
if [ $? != 0 ] ; then echo 'Failed parsing options' >&2 ; exit 1 ; fi
NAMES=1
VALUES=1
RANGE='month'
while true; do
  case "$1" in
    -h | --help ) HELP=true; shift ;;
    -d | --debug ) DEBUG=true; shift ;;
    -n | --names ) NAMES="$2"; shift; shift ;;
    -v | --values ) VALUES="$2";shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [[ $DEBUG == 'true' ]] ; then
  echo "NAMES=${NAMES}"
  echo "VALUES=${VALUES}"
fi
if [  $(echo $NAMES| sed 's|,|\n|g'|wc -l) != $(echo $VALUES| sed 's|,|\n|g'|wc -l)  ] ;then
  echo 'Parameter count mismatch'
  echo -e "Between\n$NAMES\nand\n$VALUES"
  exit 0
fi
# NOTE: redefining the variables
VALUES=($(echo $VALUES| sed 's|,| |g'))
NAMES=($(echo $NAMES| sed 's|,| |g'))
MAX_INDEX="${#NAMES[@]}"
if [[ $DEBUG == 'true' ]] ; then
  echo 'Redefined the variables'
  echo "NAMES=${NAMES[@]}"
  echo "VALUES=${VALUES[@]}"
fi

for((CNT=0;CNT<$MAX_INDEX;CNT++)) ; do
  NAME=$(echo ${NAMES[$CNT]})
  VALUE=$(echo ${VALUES[$CNT]})
  if [[ -z $VALUE ]]  ; then
    continue
  fi
 echo -e "pair $CNT:\nname=$NAME\nvalue=$VALUE"
done
