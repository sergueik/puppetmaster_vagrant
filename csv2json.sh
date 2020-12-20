#!/bin/bash

# build JSON from csv
# based on: https://unix.stackexchange.com/questions/163845/using-jq-to-extract-values-and-format-in-csv/227950

DATA_JSON=$(cat <<DATA
{
  "data": [
  {
    "displayName": "First Name",
    "column": 1,
    "value": "Bill"
  },
  {
    "displayName": "Last Name",
    "column": 2,
    "value": "Gates"
  },
  {
    "displayName": "Position",
    "column": 3,
    "value": "Enterprener"
  },
  {
    "displayName": "Company Name",
    "column": 4,
    "value": "Microsoft"
  },
  {
    "displayName": "Country",
    "column": 5,
    "value": "USA"
  }
]
}
DATA
)
echo 'Original input:'
echo $DATA_JSON | jq '.'
# TODO:
# https://stackoverflow.com/questions/54621301/how-to-colorize-individual-columns-in-csv-file-in-terminal
echo 'CSV-style format:'
echo $DATA_JSON | jq -cr '.data | map(["displayName",.displayName,"column",( .column |tostring),"value", .value] | join(":")) | join("\n")' -
TMP_FILE1="/tmp/data1.$$"

cat<<DATA>$TMP_FILE1
      displayName:First Name:column:1:value:Bill
	displayName:Last Name:column:2:value:Gates
  displayName:Position:column:3:value:enterpreneur
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
# based on:
# https://stackoverflow.com/questions/60741567/generate-nested-json-using-array-elements-as-keys
echo 'Rebuild original input format:'
RESULT_FILE1="/tmp/result1.$$"
cat $TMP_FILE2 | jq --slurp '{"all": [.]| add}' | tee $RESULT_FILE1 > /dev/null
jq '.' < $RESULT_FILE1

RESULT_FILE2="/tmp/result2.$$"
echo 'Alternative input, array of rows:'
cat $TMP_FILE2 | jq --slurp '.' | tee $RESULT_FILE2 > /dev/null
jq '.' < $RESULT_FILE2

rm -f $TMP_FILE1
rm -f $TMP_FILE2
exit 0

# NOTE:
# jq -cr --arg key 'data' --arg value '[{"one":1,"two":2}]' '.|.[$key]=$value' <<< '{}'
# does not produce deep keys
# but rather istring value:
# {"data":"[{\"one\":1,\"two\":2}]"}
