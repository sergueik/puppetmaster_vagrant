#!/bin/bash

TODAY_MONTH_DATE=$(date +%m%d)


QUARTER_START_DATES=( '1:01/01'
  '2:04/01'
  '3:07/01'
  '4:10/01')

QUARTER_END_DATES=( '1:03/31'
  '2:06/30'
  '3:09/30'
  '4:12/31')


FOLLOWING_QUARTER_START_DATE=( "0401:1"
        "0701:2"
        "1001:3")
QUARTER=4
# https://stackoverflow.com/questions/1494178/how-to-define-hash-tables-in-bash
for ENTRY in "${FOLLOWING_QUARTER_START_DATE[@]}" ; do
  QUARTER_START="${ENTRY%%:*}"
  QUARTER="${ENTRY##*:}"
  if [[ "${TODAY_MONTH_DATE}" < "${QUARTER_START}" ]] ; then
    printf "%s is for %s.\n" "$QUARTER_START" "$QUARTER"
  fi
done

for ENTRY in "${QUARTER_START_DATES[@]}" ; do
  KEY="${ENTRY%%:*}"
  VALUE="${ENTRY##*:}"
  if [[ "${QUARTER}" = "${KEY}" ]] ; then
    QUARTER_START_DATE=$VALUE
    printf "%s is for %s.\n" "$QUARTER" "$VALUE"
  fi
done


for ENTRY in "${QUARTER_END_DATES[@]}" ; do
  KEY="${ENTRY%%:*}"
  VALUE="${ENTRY##*:}"
  if [[ "${QUARTER}" = "${KEY}" ]] ; then
    QUARTER_END_DATE=$VALUE
    printf "%s is for %s.\n" "$QUARTER" "$VALUE"
  fi
done
echo "Today is ${TODAY_MONTH_DATE}"
printf "Current quarter is %s ... %s" "${QUARTER_START_DATE}" "${QUARTER_END_DATE}"
 

