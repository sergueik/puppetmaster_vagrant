#!/bin/bash
# inspired by: https://www.cyberforum.ru/shell/thread2845584.html
# NOTE: no bc in git bash

if [[ $DEBUG == 'true' ]] ; then
  if [ ! -z "${EXEPATH}" ] ; then
    echo 'running from git bash'	
    # EXEPATH=C:\Program Files\Git
  fi
fi
DEBUG=
FILE_PERMISSIONS=${1:-0751}
RESULT=''
PERMISSIONS=( '1:x' '2:w' '4:r')
# for DIGIT in $(echo "$FILE_PERMISSIONS/100" |/usr/bin/bc)  $(echo "($FILE_PERMISSIONS/10)%10" |/usr/bin/bc) $(echo "$FILE_PERMISSIONS%10" |/usr/bin/bc) ; do
for DIGIT in "$(($FILE_PERMISSIONS/100))"  "$((($FILE_PERMISSIONS/10)%10))"  "$(($FILE_PERMISSIONS%10))" ; do
  if [[ $DEBUG == 'true' ]] ; then
    echo "DIGIT=$DIGIT"
    BINARY_DIGIT=$(echo "obase=2;$DIGIT" | bc)
    echo "DIGIT=$BINARY_DIGIT"
  fi
  for PBIT in 4 2 1 ; do
    if [[ $DEBUG == 'true' ]] ; then
      echo '$(('$PBIT' &$DIGIT))'
      echo "$(($PBIT & $DIGIT))"
    fi
    if [ "$(( $PBIT & $DIGIT ))" != 0 ] ; then
      for ENTRY in "${PERMISSIONS[@]}" ; do
        KEY="${ENTRY%%:*}"
        VALUE="${ENTRY##*:}"
        if [[ "${PBIT}" = "${KEY}" ]] ; then
          echo $VALUE
          RESULT=$(echo "$RESULT$VALUE")
        fi
      done
    else
      echo '-'
      RESULT=$(echo "${RESULT}-")
    fi
  done
done

echo $RESULT
