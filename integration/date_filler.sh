#!/bin/bash
# origin: http://www.cyberforum.ru/shell/thread2524082.html
# see also: https://stackoverflow.com/questions/25701265/how-to-generate-a-list-of-all-dates-in-a-range-using-the-tools-available-in-bash

# testing
DEBUG=true

cd '/tmp'
mkdir 'range'
pushd '/tmp/range'

# NOTE locale specific date formats
NUM=0
DATE_END='31.10.2019'
DATE_START='2019-01-11'

while [ "$NEXT_DATE" != "${DATE_END}" ]; do
  NEXT_DATE=$(date -d "${DATE_START} + ${NUM} day" +%d.%m.%Y)
  ((NUM++))
  echo $NEXT_DATE
  # touch $NEXT_DATE
done
popd

DATE_START='09/05/2019'
DATE_END='10/15/2019'
DAY_INCREMENT=10

NEXT_DATE="${DATE_START}"
until [[ "${NEXT_DATE}" > "${DATE_END}" ]]; do
  INTERVAL_START=$NEXT_DATE
  NEXT_DATE=$(date -d "${NEXT_DATE} + ${DAY_INCREMENT} day" +%m/%d/%Y)
  if [[ "${NEXT_DATE}" < "${DATE_END}" ]]; then
    INTERVAL_END=$NEXT_DATE
  else
    INTERVAL_END=$DATE_END
  fi
  # avoid running SQL if report date interval collapses to the same start, end
  if [[ ${INTERVAL_START} < ${INTERVAL_END} ]]; then
    echo "Running the report over START=${INTERVAL_START} END=${INTERVAL_END}"
  else  
    if [[ $DEBUG == 'true' ]] ; then
      echo 'Skipping collapsed report interval'
    fi  
  fi
  # echo "${NEXT_DATE}"
done

# safe against the accidental date format change leading to the endless loop
DATE_START='07/01/2019'
DATE_END='10/01/2019'

# exotic version of the date interval generation
seq 0 $DAY_INREMENT $(( ($(date -d $DATE_END +%s) - $(date -d $DATE_START +%s))/84600 )) | xargs -I {} date -d "$DATE_START {} days" +%m/%d/%Y | xargs printf "%s\n"

DAY_INCREMENT=10

DAY_INCREMENT=10

DATE_START='09/05/2019'
DATE_END='10/15/2019'


if [[ $DEBUG == 'true' ]] ; then
  echo "DAY_INCREMENT=${DAY_INCREMENT}"
  echo "DATE_END=${DATE_END}"
  echo "DATE_START=${DATE_START}"
  echo "Day count sequence:"
  seq 0 $DAY_INCREMENT $(( ($(date -d $DATE_END +%s) - $(date -d $DATE_START +%s))/84600 ))
fi

# safer loop against date comparison:
# accidental date format change can lead to the endless loop
NEXT_DATE="${DATE_START}"
for DAY_COUNT in $( seq 0 $DAY_INCREMENT $(( ($(date -d $DATE_END +%s) - $(date -d $DATE_START +%s))/84600 ))) ; do
  DAY_COUNT=$(expr $DAY_COUNT + $DAY_INCREMENT)
  if [[ $DEBUG == 'true' ]] ; then
    echo "DAY_COUNT=${DAY_COUNT}"
  fi
  INTERVAL_START=$NEXT_DATE
  NEXT_DATE=$(date -d "${DATE_START} + ${DAY_COUNT} day" +%m/%d/%Y)
  if  [[ "${NEXT_DATE}" < "${DATE_END}" ]]; then
    INTERVAL_END=$NEXT_DATE
  else
    INTERVAL_END=$DATE_END
  fi
  # avoid running SQL if report date interval collapses to the same start, end
  if [[ ${INTERVAL_START} < ${INTERVAL_END} ]]; then
    echo "Running the report over INTERVAL_START=${INTERVAL_START} INTERVAL_END=${INTERVAL_END}"
  else 
    if [[ $DEBUG == 'true' ]] ; then
      echo 'Skipping collapsed report interval'
    fi  
  fi
done
