#!/bin/sh
# origin: https://raw.githubusercontent.com/Pravkhande/serverspec/master/Security/run_script.sh
# This block is used for machine details from file

IFS=$'\n' GLOBIGNORE='*' command eval  'IPs=($(cat parameters.csv))'

# This block is used for machine details from environment variable
LINE_NUMBER=0
for LINE in "${IPs[@]}"
do
  # echo $LINE
  LINE_NUMBER=$((LINE_NUMBER+1))
  echo Line $LINE_NUMBER
  IFS=':'
  read -ra ary <<< "$LINE"
    export AUTHENTICATION=${ary[0]}
    export IP=${ary[1]}
    export USER=${ary[2]}
    export PASSWORD=${ary[3]}

    echo AUTHENTICATION=$AUTHENTICATION
    echo IP=$IP
    echo USER=$USER
    echo PASSWORD=$PASSWORD
  
done
