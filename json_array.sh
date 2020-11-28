#!/bin/bash

# converts the cutom JSON rowset keys into bash array variable by chopping the  string and element delimeters and enclosing parenthecis
#
INPUT_FILE='data_rowset.json'
NAMES=($( jq -r '.versions|flatten' $INPUT_FILE | jq -r '[.[]|keys]' | jq -cr 'flatten|.[]'))

printf "%s\n" "${NAMES[0]}"
printf "%s\n" "${NAMES[1]}"
printf "%s\n" "${NAMES[2]}"

exit 0
SNAPSHOT='snapshot.json'
# 0 for version-less components
jq '.[]|select( .desiredVersions|length == 1)|.name' $SNAPSHOT| sed '|"||g' | sort | tee /tmp/a.txt 
