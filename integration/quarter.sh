#!/bin/bash

TODAY_MONTH_DATE=$(date +%m%d)

QUARTER_STARTS_ARRAY=( "cow:moo"
        "dinosaur:roar"
        "bird:chirp"
        "bash:rock" )
# https://stackoverflow.com/questions/1494178/how-to-define-hash-tables-in-bash
for ENTRY in "${QUARTER_STARTS_ARRAY[@]}" ; do
    KEY="${ENTRY%%:*}"
    VALUE="${ENTRY##*:}"
    printf "%s likes to %s.\n" "$KEY" "$VALUE"
done



