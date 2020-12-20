#!/bin/bash

# build JSON from csv

TMP_FILE1="/tmp/data1.$$"
cat<<DATA>$TMP_FILE1
      first:11:second:12:third:13
	first:22:second:22:third:23
  first:32:second:32:third:33
DATA
TMP_FILE2="/tmp/data2.$$"
      
IFS=':'; cat $TMP_FILE1|tr '\t' ' '| sed 's|^  *||g'| while read K1 V1 K2 V2 K3 V3; do
  jq --arg key1 "$K1"   \
     --arg val1 "$V1" \
     --arg key2 "$K2"   \
     --arg val2 "$V2" \
     --arg key3 "$K3"   \
     --arg val3 "$V3" \
  '. | .[$key1]=$val1 | .[$key2]=$val2 | .[$key3]=$val3'  \
  <<<'{}' ;
done > $TMP_FILE2
      
cat $TMP_FILE2 | jq --slurp '.'
rm -f $TMP_FILE1
rm -f $TMP_FILE2
