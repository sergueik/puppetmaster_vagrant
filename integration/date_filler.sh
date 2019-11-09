#!/bin/bash
# origin: http://www.cyberforum.ru/shell/thread2524082.html
# see also: https://stackoverflow.com/questions/25701265/how-to-generate-a-list-of-all-dates-in-a-range-using-the-tools-available-in-bash
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

DATE_START='07/01/2019'
DATE_END='10/01/2019'
DAY_INCREMENT=10

NEXT_DATE="${DATE_START}"
until [[ "${NEXT_DATE}" > "${DATE_END}" ]]; do
  INTERVAL_START=$NEXT_DATE
  NEXT_DATE=$(date -d "${NEXT_DATE} + ${DAY_INCREMENT} day" +%m/%d/%Y)
  if  [[ "${NEXT_DATE}" < "${DATE_END}" ]]; then
    INTERVAL_END=$NEXT_DATE
  else
    INTERVAL_END=$DATE_END
  fi
  echo "${INTERVAL_START} ${INTERVAL_END}"
  # echo "${NEXT_DATE}"
done

# exotic version of the date interval generation

DATE_START='07/01/2019'
DATE_END='10/01/2019'
seq 0 $(( ($(date -d $DATE_END +%s) - $(date -d $DATE_START +%s))/84600 )) | xargs -I {} date -d "$DATE_START {} days" +%m/%d/%Y | xargs printf "%s\n"

