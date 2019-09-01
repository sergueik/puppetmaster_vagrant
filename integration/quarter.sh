#!/bin/bash

TODAY_MONTH_DATE=$(date +%m%d)
# testing
DEBUG=true
if [[ $DEBUG == 'true' ]] ; then
  TODAY_MONTH_DATE=0215
fi
if [[ $DEBUG == 'true' ]] ; then
  echo "Today is ${TODAY_MONTH_DATE}"
fi
TODAY_YEAR=$(date +%Y)
# TODO: year adjustment for 4th quarter when evaluating the last completed quarter

QUARTER_START_DATES=( '1:01-01'
  '2:04-01'
  '3:07-01'
  '4:10-01')

QUARTER_END_DATES=( '1:03-31'
  '2:06-30'
  '3:09-30'
  '4:12-31')

FOLLOWING_QUARTER_START_DATE=( '0401:1'
  '0701:2'
  '1001:3')
QUARTER=4
# https://stackoverflow.com/questions/1494178/how-to-define-hash-tables-in-bash
for ENTRY in "${FOLLOWING_QUARTER_START_DATE[@]}" ; do
  KEY="${ENTRY%%:*}"
  VALUE="${ENTRY##*:}"
  if [[ "${TODAY_MONTH_DATE}" < "${KEY}" ]] ; then
    QUARTER=$VALUE
    if [[ $DEBUG == 'true' ]] ; then
      printf "Date %s is quarter %s.\n" "${TODAY_MONTH_DATE}" "${QUARTER}"
    fi
    break
  fi
done

for ENTRY in "${QUARTER_START_DATES[@]}" ; do
  KEY="${ENTRY%%:*}"
  VALUE="${ENTRY##*:}"
  if [[ "${QUARTER}" = "${KEY}" ]] ; then
    QUARTER_START_DATE=$VALUE
    if [[ $DEBUG == 'true' ]] ; then
      printf "Start date of quarter %s is: %s.\n" "${QUARTER}" "${QUARTER_START_DATE}"
    fi
  fi
done

for ENTRY in "${QUARTER_END_DATES[@]}" ; do
  KEY="${ENTRY%%:*}"
  VALUE="${ENTRY##*:}"
  if [[ "${QUARTER}" = "${KEY}" ]] ; then
    QUARTER_END_DATE=$VALUE
    if [[ $DEBUG == 'true' ]] ; then
      printf "End date of quarter %s is: %s.\n" "${QUARTER}" "${QUARTER_END_DATE}"
    fi
  fi
done
# date format YYYY-mm-dd
printf "Current quarter is %s-%s ... %s-%s\n" "${TODAY_YEAR}" "${QUARTER_START_DATE}" "${TODAY_YEAR}" "${QUARTER_END_DATE}"
 

PREV_QUARTERS=('1:4' '2:1' '3:2' '4:3')
for ENTRY in "${PREV_QUARTERS[@]}" ; do
  KEY="${ENTRY%%:*}"
  VALUE="${ENTRY##*:}"
  if [[ "${QUARTER}" = "${KEY}" ]] ; then
    PREV_QUARTER=$VALUE
    if [[ "${PREV_QUARTER}" == '4' ]] ;  then
      PREV_QUARTER_YEAR=$((TODAY_YEAR -1 ))
    else
      PREV_QUARTER_YEAR=$TODAY_YEAR
    fi
    if [[ $DEBUG == 'true' ]] ; then
      printf "Previous quarter of %s is %s.\n" "${QUARTER}" "${PREV_QUARTER}"
    fi  
  fi
done
for ENTRY in "${QUARTER_START_DATES[@]}" ; do
  KEY="${ENTRY%%:*}"
  VALUE="${ENTRY##*:}"
  if [[ "${PREV_QUARTER}" = "${KEY}" ]] ; then
    PREV_QUARTER_START_DATE=$VALUE
    printf "Start date of quarter %s is: %s.\n" "${PREV_QUARTER}" "${PREV_QUARTER_START_DATE}"
    break
  fi
done

for ENTRY in "${QUARTER_END_DATES[@]}" ; do
  KEY="${ENTRY%%:*}"
  VALUE="${ENTRY##*:}"
  if [[ "${PREV_QUARTER}" = "${KEY}" ]] ; then
    PREV_QUARTER_END_DATE=$VALUE
    if [[ $DEBUG == 'true' ]] ; then
      printf "End date of quarter %s is: %s.\n" "${PREV_QUARTER}" "${PREV_QUARTER_END_DATE}"
    fi
  fi
done
# date format YYYY-mm-dd
printf "Previous quarter is %s-%s ... %s-%s\n" "${PREV_QUARTER_YEAR}" "${PREV_QUARTER_START_DATE}" "${PREV_QUARTER_YEAR}" "${PREV_QUARTER_END_DATE}"
 
