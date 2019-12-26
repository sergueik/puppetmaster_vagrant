#!/bin/bash

# based on https://qna.habr.com/q/696092
# ask is to crontab job to run every other day
# onetrivial solution is to cron it to run daily and skip every other day
# ./date_diff_cron.sh '22 Dec 2019'

# enable DEBUG for testing
DEBUG=true

JOB_DATE_DEFAULT=$(date +'%d %b %Y')
# e.g. '25 Dec 2019'
JOB_DATE=${1:-$JOB_DATE_DEFAULT}
if [[ $DEBUG == 'true' ]] ; then
  echo "JOB_DATE=${JOB_DATE}"
fi
BEGIN_YEAR_DATE=$(date +'1 Jan %Y')

D1=$(date -d "${JOB_DATE}" +'%s')
D2=$(date -d "${BEGIN_YEAR_DATE}" +'%s')

# bash variable expression extension
NUM_DAYS=$(( (D1 - D2) / 86400 ))

# NOTE:  the next line is a wrong syntax
# NUM_DAYS=$[ D1 - D2 / 86400 ]

if [[ $DEBUG == 'true' ]] ; then
  echo "${NUM_DAYS} since the start of the year"
fi

if [[ $(( NUM_DAYS % 2 )) -eq 0 ]];  then
  echo "Skip ${JOB_DATE}"
else
  echo "Do it ${JOB_DATE}"
fi

# alternatively not using bash shell extensions
NUM_DAYS=$(expr \( $D1 - $D2 \) / 86400 )
if [[ $DEBUG == 'true' ]] ; then
  echo "${NUM_DAYS} since the start of the year"
fi
if [[ $(expr $NUM_DAYS % 2 ) -eq 0 ]];  then
  echo "Skip ${JOB_DATE}"
else
  echo "Do it ${JOB_DATE}"
fi

