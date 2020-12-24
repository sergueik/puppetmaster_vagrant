#!/bin/bash

# packs loose JSON into key:value JSON and CSV


DATA_JSON=$(cat <<DATA
[
  {
    "propDef": {
      "name": "First",
      "id": 1,
      "value": ""
    },
    "propValue": {
      "name": "First",
      "id": 1,
      "value": "41"
    }
  },
  {
    "propDef": {
      "name": "Second",
      "id": 1,
      "value": ""
    },
    "propValue": {
      "name": "Second",
      "id": 2,
      "value": "42"
    }
  },
  {
    "propDef": {
      "name": "Third",
      "id": 1,
      "value": ""
    },
    "propValue": {
      "name": "Third",
      "id": 1,
      "value": "43"
    }
  }
]
DATA
)
OPTIONS=''
echo 'Original input:'
echo $DATA_JSON | jq $OPTIONS '.'

OPTIONS='-cr'
QUERY='.[]|.propValue|["value",.value]|join("=")'
VALUES=($(echo $DATA_JSON | jq $OPTIONS $QUERY))

OPTIONS='-cr'
QUERY='.[]|.propDef|["name",.name]|join("=")'
NAMES=($(echo $DATA_JSON | jq $OPTIONS $QUERY))
# NOTE: the following wil be misleading
# echo '----------'
# echo -e "Names:\n\"$NAMES\""
# echo -e "Values:\n\"$VALUES\""
# echo '----------'
MAX_INDEX="${#NAMES[@]}"

# 1>2 echo 'CSV:'
echo 'CSV:'
for CNT in $(seq 0 $MAX_INDEX) ; do
  NAME=$(echo ${NAMES[$CNT]} | cut -d '=' -f 2)
  VALUE=$(echo ${VALUES[$CNT]} | cut -d '=' -f 2)
  echo -e "$NAME\t$VALUE"
done
echo 'JSON'

ARGLINE=''
QUERY='.'
for CNT in $(seq 0 $MAX_INDEX) ; do
  NAME=$(echo ${NAMES[$CNT]} | cut -d '=' -f 2)
  VALUE=$(echo ${VALUES[$CNT]} | cut -d '=' -f 2)
  if [[ -z $VALUE ]]  ; then
    continue
  fi
 ARGLINE=$(echo "$ARGLINE --arg name$CNT $NAME --arg val$CNT $VALUE")
 QUERY=$(echo "$QUERY |.[\$name$CNT]=\$val$CNT")
done

# echo jq $ARGLINE "'$QUERY'" <<<'{}'
jq $ARGLINE "$QUERY" <<<'{}'
