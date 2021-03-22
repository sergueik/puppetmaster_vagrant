#!/bin/bash

KEYS='a,b,c'
VALS='A,B,C'
CNT=0
for ARG in $(echo $KEYS | sed 's|,| |g'); do
  # store number of lines in an array
  KEYS[$CNT]=$ARG
  # increase counter
  CNT=$[ $CNT + 1 ]
done
CNT=0
for ARG in $(echo $VALS | sed  's|,| |g') ; do
  # store number of lines in an array
  VALS[$CNT]=$ARG
  # increase counter
  CNT=$[ $CNT + 1 ]
done
MAXCNT=$CNT
echo MAXCNT=$MAXCNT
for ((CNT=0;CNT<MAXCNT;CNT++)); do
  echo CNT=$CNT
  # NOTE need '{','}'
  echo "${KEYS[$CNT]}"
  echo ${VALS[$CNT]}
done
MAXCNT=$[ $MAXCNT - 1 ]
for CNT in $(seq 0 1 $MAXCNT); do
  echo CNT=$CNT
  # NOTE need '{','}'
  echo "${KEYS[$CNT]}"
  echo ${VALS[$CNT]}
done
