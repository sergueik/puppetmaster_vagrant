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

while [ "$D" != "${DATE_END}" ]; do
  D=$(date -d "${DATE_START} + ${NUM} day" +%d.%m.%Y)
  ((NUM++))
  touch $D
done
popd

DATE_END='10/01/2019'
DATE_START='07/01/2019'
DAY_INCREMENT=7

NEXT_DATE="${DATE_START}"
until [[ "${NEXT_DATE}" > "${DATE_END}" ]]; do
  echo "${NEXT_DATE}"
  NEXT_DATE=$(date -d "${NEXT_DATE} + ${DAY_INCREMENT} day" +%m/%d/%Y)
done

