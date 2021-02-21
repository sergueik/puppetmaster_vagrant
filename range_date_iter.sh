#!/bin/bash

# enable DEBUG for testing
DEBUG=false

OPTS=$(getopt -o hdym:w: --long help,debug,year,months:,weeks: -n 'parse-options' -- "$@")
if [ $? != 0 ] ; then echo 'Failed parsing options' >&2 ; exit 1 ; fi
MONTHS=1
WEEKS=1
RANGE='month'
while true; do
  case "$1" in
    -h | --help ) HELP=true; shift ;;
    -d | --debug ) DEBUG=true; shift ;;
    -y | --year ) RANGE='year'; shift ;;
    -m | --months ) MONTHS="$2"; shift; shift ;;
    -w | --weeks ) WEEKS="$2"; RANGE='week';shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done
TILL_DATE_DEFAULT=$(date +'%d %b %Y')
DAYS=$(expr $WEEKS \* 7)
BEGIN_YEAR_DATE=$(date +'1 Jan %Y')
PAST_MONTH_DATE=$(date -d "-$MONTHS month" +%Y%m%d)
PAST_WEEK_DATE=$(date -d "-$DAYS day" +%Y%m%d)

if [[ $DEBUG == 'true' ]] ; then
  echo "Range selection: ${RANGE}"
  echo "Past month date: ${PAST_MONTH_DATE}"
  echo "Past week date: ${PAST_WEEK_DATE}"
  echo "Begin year date: ${BEGIN_YEAR_DATE}"
  # exit
fi
TILL_DATE=${1:-$TILL_DATE_DEFAULT}
if [[ $RANGE == 'month' ]]; then 
  FROM_DATE=${1:-$PAST_MONTH_DATE}
elif [[ $RANGE == 'year' ]]; then 
  FROM_DATE=${1:-$BEGIN_YEAR_DATE}
else
  FROM_DATE=${1:-$PAST_WEEK_DATE}
fi
if [[ $DEBUG == 'true' ]] ; then
  echo "From calendar date: ${FROM_DATE}"
  echo "Till calendar date: ${TILL_DATE}"
fi

TILL_SECONDS=$(date -d "${TILL_DATE}" +'%s')
FROM_SECONDS=$(date -d "${FROM_DATE}" +'%s')


if [[ $DEBUG == 'true' ]] ; then
  # bash variable expression extension
  NUM_DAYS=$(( (TILL_SECONDS - FROM_SECONDS) / 86400 ))
  echo "${NUM_DAYS} days date range"
  NUM_DAYS=$(expr \( $TILL_SECONDS - $FROM_SECONDS \) / 86400 )
  echo "${NUM_DAYS} days date range"
fi

if [[ $DEBUG == 'true' ]] ; then
  echo "TILL_SECONDS=${TILL_SECONDS}"
  echo "FROM_SECONDS=${FROM_SECONDS}"
fi

ITER_SECONDS=$FROM_SECONDS

while [ $(expr $ITER_SECONDS \< $TILL_SECONDS ) = 1 ]; do
  echo "Unix seconds: ${ITER_SECONDS}"
  ITER_DATE=$(date -d @$ITER_SECONDS +'%d %b %Y')
  echo "Calendar date: ${ITER_DATE}"
  ITER_SECONDS=$(expr $ITER_SECONDS + 86400 )
done

