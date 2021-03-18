#!/bin/bash
RESULT=100
echo "RESULT=$RESULT"
FILE=${1:-$0}

tail -5 $FILE|while read LINE ; do
  RESULT=$(expr $RESULT \+ 1)
  echo "RESULT=$RESULT"  
done

echo 'finally'
echo "RESULT=$RESULT"
TMP_FILE=/tmp/a.$$.log

tail -5 $FILE|while read LINE ; do
  RESULT=$(expr $RESULT \+ 1)
  echo "RESULT=$RESULT"  
  echo $RESULT>$TMP_FILE
done
if [ -s $TMP_FILE ] ; then
  RESULT=$(cat $TMP_FILE)
fi
echo 'finally'
echo "RESULT=$RESULT"
