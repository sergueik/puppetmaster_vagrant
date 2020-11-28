#!/bin/bash
INPUT_FILE='data_rowset.json'
NAMES=($( jq -r '.versions|flatten' $INPUT_FILE | jq -r '[.[]|keys]' | jq 'flatten' | sed 's|\[||;s|\]||;s|,||;s|"||g'))

printf "%s\n" "${NAMES[0]}"
printf "%s\n" "${NAMES[1]}"
printf "%s\n" "${NAMES[2]}"

exit 0
SNAPSHOT='snapshot.json'
# 0 for version-less components
jq '.[]|select( .desiredVersions|length == 1)|.name' $SNAPSHOT| sed '|"||g' | sort | tee /tmp/a.txt 
