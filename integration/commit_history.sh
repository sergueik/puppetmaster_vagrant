#!/bin/bash

TODAY=$(date +'%d %b %Y')
# e.g. $0 '25 Dec 2019'
NOW_DATE=${1:-$TODAY}
BEGIN_DATE=$(date +'14 Apr 2014')

NOW_EPOCH=$(date -d "${NOW_DATE}" +'%s')
BEGIN_EPOCH=$(date -d "${BEGIN_DATE}" +'%s')

# bash variable expression extension
NUM_DAYS=$(( (NOW_EPOCH - BEGIN_EPOCH) / 86400 ))
echo "Bash count: ${NUM_DAYS}"

# expr
NUM_DAYS=$(expr \( $NOW_EPOCH - $BEGIN_EPOCH \) / 86400 )
echo "Expr count: ${NUM_DAYS}"
