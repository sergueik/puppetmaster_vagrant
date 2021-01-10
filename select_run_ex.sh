#!/bin/bash
# based on: https://askubuntu.com/questions/1705/how-can-i-create-a-select-menu-in-a-shell-script
# Bash Menu Script Example
DEBUG=true

runprocess(){
  for ENTRY in "${ARGUMENTS[@]}" ; do
    KEY="${ENTRY%%=*}"
    VALUE="${ENTRY##*=}"
    1>&2     printf "KEY %s VALUE: %s.\n" "${KEY}" "${VALUE}"
    1>&2 echo $ARGUMENT
  done		
  if [[ "$DEBUG" = 'true' ]]; then
    1>&2 echo "PASSWORD: ${PASSWORD}"
  fi
}
ARGUMENTS=()
PS3='Please enter your choice: '
OPTIONS=('Enter arguments' 'Password' 'Run' 'Quit')
select OPT in "${OPTIONS[@]}"
do
  case $OPT in
    "Enter arguments")
      echo $OPT
      read -ea ARGUMENTS
      ;;
    "Password")
      echo 'Enter password: '
      read -s PASSWORD
      ;;
    "Quit")
      break
      ;;
    "Run")
      echo "Running process"
      DUMMY=''
      RESULT=$(runprocess $DUMMY)
      ;;
    *) echo "invalid option $REPLY";;
  esac
done
