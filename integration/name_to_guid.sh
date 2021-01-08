#!/bin/bash

DEBUG=true
ENV='tst'
DC='stl'

OPTS=$(getopt -o hed: --long help,env,dc: -n 'parse-options' -- "$@")
if [ $? != 0 ] ; then echo 'Failed parsing options' >&2 ; exit 1 ; fi
while true; do
  case "$1" in
    -h | --help ) HELP=true; shift ;;
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
  echo "ENV=${ENV}"
  echo "UCD_ENV=${UCD_ENV}"
fi

GUID_LOOKUP=( 'TST-STL:01-01-01'
  'TST-WEC:02-02-02'
  'DEV-STL:03-03-03'
  'DEV-WEC:04-04-04')

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
