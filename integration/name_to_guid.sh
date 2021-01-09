#!/bin/bash

DEBUG=true
ALL=false
ENV='tst'
DC='stl'

OPTS=$(getopt -o hae:d: --long help,all,env:,dc: -n 'parse-options' -- "$@")
if [ $? != 0 ] ; then echo 'Failed parsing options' >&2 ; exit 1 ; fi
while true; do
  case "$1" in
    -h | --help ) HELP=true; shift ;;
    -a | --all ) ALL=true; shift ;;
    -e | --env ) ENV="$2"; shift; shift ;;
    -d | --dc ) DC="$2"; shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

UCD_ENV=$(echo "${ENV}-${DC}"|tr '[a-z]' '[A-Z]')
if [[ $DEBUG == 'true' ]] ; then
  echo "OPTIND=${OPTIND}"
  echo "DC=${DC}"
  echo "ALL=${ALL}"
  echo "ENV=${ENV}"
  echo "UCD_ENV=${UCD_ENV}"
fi

GUID_LOOKUP=( 'TST-EAST:01-01-01'
  'TST-EA:01-01-01'
  'TST-WEST:02-02-02'
  'TST-WE:02-02-02'
  'DEV-EAST:03-03-03'
  'DEV-WEST:04-04-04'
  'UAT-EAST:03-03-03'
  'UAT-WEST:04-04-04'
  )
if [[ $ALL == 'true' ]] ; then
  for ENTRY in "${GUID_LOOKUP[@]}" ; do
    VALUE="${ENTRY##*:}"
    UCD_GUIDS=$(echo $UCD_GUIDS $VALUE)
  done
else
  for ENTRY in "${GUID_LOOKUP[@]}" ; do
    KEY="${ENTRY%%:*}"
    VALUE="${ENTRY##*:}"
    if [[ "${UCD_ENV}" = "${KEY}" ]] ; then
      UCD_GUID=$VALUE
      if [[ $DEBUG == 'true' ]] ; then
        printf "ENV %s  GUID is: %s.\n" "${UCD_ENV}" "${UCD_GUID}"
      fi
    fi
  done

  if [[ -z $UCD_GUID ]]  ; then
    echo "Failed to find GUID for env=${ENV} dc=${DC}"
    exit 0
  else
    UCD_GUIDS=$UCD_GUID	
  fi
fi
# echo "Processing $UCD_GUIDS"
for UCD_GUID in $UCD_GUIDS; do
  echo "Processing $UCD_GUID"
done
