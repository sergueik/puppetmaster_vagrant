#!/bin/bash

# enable DEBUG for testing
DEBUG=false

TILL_DATE_DEFAULT=$(date +'%d %b %Y')
BEGIN_YEAR_DATE=$(date +'1 Jan %Y')
PAST_MONTH_DATE=$(date -d "-1 month" +%Y%m%d)
TILL_DATE=${1:-$TILL_DATE_DEFAULT}
FROM_DATE=${1:-$PAST_MONTH_DATE}
if [[ $DEBUG == 'true' ]] ; then
  echo "From calendar date: ${FROM_DATE}"
  echo "Till calendar date: ${TILL_DATE}"
fi

TILL_SECONDS=$(date -d "${TILL_DATE}" +'%s')
FROM_SECONDS=$(date -d "${FROM_DATE}" +'%s')


if [[ $DEBUG == 'true' ]] ; then
  # bash variable expression extension
  NUM_DAYS=$(( (TILL_SECONDS - FROM_SECONDS) / 86400 ))
  echo "${NUM_DAYS} since the past month"
  NUM_DAYS=$(expr \( $TILL_SECONDS - $FROM_SECONDS \) / 86400 )
  echo "${NUM_DAYS} since the start of the year"
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

