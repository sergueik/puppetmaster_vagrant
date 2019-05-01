#!/bin/bash
# replace some version $OLD_VAL in configiration scattered across blueprint directories designed deep around Puppet hierarchy in mind
DEFAULT_FOLDER='.'
FOLDER=${1:-$DEFAULT_FOLDER}
# echo $FOLDER
# exit 0
OLD_VAL='8.5.35'
NEW_VAL='8.5.38'
grep -ilr "$OLD_VAL" $FOLDER /dev/null | xargs -i sed -i "s|$OLD_VAL|$NEW_VAL|g"  {}
