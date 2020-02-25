#!/bin/bash

# https://www.cyberciti.biz/faq/unix-howto-read-line-by-line-from-file/

ARRAY=()
LIST1=$(cat <<EOF
first item
second item
last item
one more item
EOF
)
LIST2=$(cat <<EOF
first key
other key
another key
some key
EOF
)

IFS=

# a longer veesion of joining two arrays using bash array syntax
# for (( i=0; i<${#array1[@]}; i++ )); do echo "${array[$i]}${array2[$i]}"; done
# https://qna.habr.com/q/717095

# add index to both lists
CNT=0
LIST1_FILE='/tmp/list1.txt'
LIST2_FILE='/tmp/list2.txt'

echo $LIST1 | while read -r LINE; do
  CNT=$((CNT + 1))
  echo $CNT $LINE | tee -a $LIST1_FILE
done
CNT=0
echo $LIST2 | while read -r LINE; do
  CNT=$((CNT + 1))
  echo $CNT $LINE | tee -a $LIST2_FILE
done

join $LIST1_FILE $LIST2_FILE

rm -f $LIST1_FILE $LIST2_FILE
