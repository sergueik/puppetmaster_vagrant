#!/bin/bash
# based on: https://qna.habr.com/q/1008411
#
TMP_FILE="/tmp/data1.$$"
# NOTE:  do not use | as a separator
cat<<EOF>$TMP_FILE
cat 
dog
mouse
EOF

# incorrect processing - the subshell is gone after the loop ends together with the value
ROW=1
RESULT=()
cat $TMP_FILE | while read LINE
do
   RESULT["$ROW"]="$LINE"
   ROW=$(($ROW+1))
   echo "inside loop: " ${RESULT[@]}
done

echo "After loop: " ${RESULT[@]}

# better way - no subprocess no loss of variables due to scope visibility

ROW=1
RESULT=()
while read LINE
do
   RESULT["$ROW"]="$LINE"
   ROW=$(($ROW+1))
   echo "inside loop: " ${RESULT[@]}
done <$TMP_FILE
echo "After loop: " ${RESULT[@]}

# yet another option
ROW=1
RESULT=()
shopt -s lastpipe
cat $TMP_FILE | while read LINE
do
   RESULT["$ROW"]="$LINE"
   ROW=$(($ROW+1))
   echo "inside loop: " ${RESULT[@]}
done
shopt -u lastpipe
echo "After loop: " ${RESULT[@]}


