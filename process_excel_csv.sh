#!/bin/sh

# reads comma-separated data in multiple rows directly from the argument, or from file argument, or from pipeline

DEFAULT_ARG='a,b,c'
FILE=${1:-$DEFAULT_ARG}
if [ "$FILE" = '-' ]
then
while read LINE
do
  LINES=$(echo -e "$LINES\n$LINE")
done < "${2:-/dev/stdin}"

else
LINES=$(echo -e "$FILE")
fi
if [ ! -z $DEBUG  ] ; then
  echo -e "$LINES"
fi
IFS=','
echo -e "$LINES" | while read  A B C ;
do
  echo "A=$A"
  echo "B=$B"
  echo "C=$C"
  echo -e "\n"
done
# e.g. usage:
# export DEBUG=true
# echo -e "a,b,c\nd,e,f" | ./process_excel_csv.sh -
# a,b,c
# d,e,f
# A=a
# B=b
# C=c
#
# A=d
# B=e
# C=f


# echo a,b,c > a.csv; echo d,e,f >> a.csv;./process_excel_csv.sh - a.csv
# a,b,c
# d,e,f
# A=a
# B=b
# C=c
#
#
# A=d
# B=e
# C=f
#
# ./process_excel_csv.sh "a,b,c"
# a,b,c
# A=a
# B=b
# C=c
