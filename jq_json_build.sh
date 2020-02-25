#!/bin/bash
# origin: https://stackoverflow.com/questions/38860529/create-json-using-jq-from-pipe-separated-keys-and-values-in-bash
# see also: https://programminghistorian.org/en/lessons/json-and-jq
DATAFILE1="/tmp/data1.$$"
# NOTE:  do not use | as a separator
cat<<EOF>$DATAFILE1
first:11:second:12:third:13
first:22:second:22:third:23
first:32:second:32:third:33
EOF

1>&2 echo 'Loading:'
1>&2 cat $DATAFILE1
1>&2 echo '---'

DATAFILE2="/tmp/data2.$$"
DATAFILE2="/tmp/data.tmp.json"

IFS=':'; cat $DATAFILE1| while read KEY1 VALUE1 KEY2 VALUE2 KEY3 VALUE3; do
jq --arg k1 "$KEY1"   \
   --arg v1 "$VALUE1" \
   --arg k2 "$KEY2"   \
   --arg v2 "$VALUE2" \
   --arg k3 "$KEY3"   \
   --arg v3 "$VALUE3" \
   '. | .[$k1]=$v1 | .[$k2]=$v2 | .[$k3]=$v3'  \
   <<<'{}' ;
done > $DATAFILE2
DATA_KEY='data'
# making the rowset keyed by $DATA_KEY
# TODO: explore alternatives
cat $DATAFILE2 | jq --slurp '.' | jq "{\"$DATA_KEY\": .}"


# NOTE: the following does not work
# jq --arg data_key "$DATA_KEY" '{ .[$data_key] =. }'
rm -f $DATAFILE1
rm -f $DATAFILE2

exit 0
# see also https://qna.habr.com/q/716813?e=8633575#clarification_833889
DATA_FILE='/tmp/data.txt'
cat<<EOF> $DATA_FILE
rabbit1-test1
rabbit1-test2
rabbit1-test3
EOF
jq -Rs --arg a '/' --arg c 'rabbit1' '[ .[:-1] |
  split("\n")[] |
  { "{#VHOSTNAME}" : $a ,
    "{#QUEUENAME}": . ,
    "{#NODENAME}": $c } ] |
   { "data" : . }' $DATA_FILE
rm -f $DATA_FILE

