#!/bin/bash

# inspired by: https://www.cyberforum.ru/shell/thread2845584.html
# NOTE: no bc in git bash

if [[ $DEBUG == 'true' ]] ; then
  if [ ! -z "${EXEPATH}" ] ; then
    echo 'running from git bash'	
    # EXEPATH=C:\Program Files\Git
  fi
  DEBUG=
fi
# NOTE: the leading "0" makes bash will consider it is octal number
# when removed (addded) the base 10 and base 8 math needs to be used

FILE_PERMISSIONS=${1:-0751}
RESULT=''
PERMISSIONS=( '1:x' '2:w' '4:r')
echo $FILE_PERMISSIONS|grep -qE '^0'
if [ $? ] ; then
  FILE_PERMISSIONS="0$FILE_PERMISSIONS"
fi
# for DIGIT in $(echo "$FILE_PERMISSIONS/100" |/usr/bin/bc)  $(echo "($FILE_PERMISSIONS/10)%10" |/usr/bin/bc) $(echo "$FILE_PERMISSIONS%10" |/usr/bin/bc) ; do
for DIGIT in "$(($FILE_PERMISSIONS/0100))"  "$((($FILE_PERMISSIONS/010)%010))"  "$(($FILE_PERMISSIONS%010))" ; do
  if [[ $DEBUG == 'true' ]] ; then
    echo "DIGIT=$DIGIT"
    BINARY_DIGIT=$(echo "obase=2;$DIGIT" | bc)
    echo "DIGIT=$BINARY_DIGIT"
  fi
  for ENTRY in "${PERMISSIONS[@]}" ; do
    KEY="${ENTRY%%:*}"
    VALUE="${ENTRY##*:}"
    if [[ $DEBUG == 'true' ]] ; then
      echo '$(('$KEY' &$DIGIT))'
      echo "$(($KEY & $DIGIT))"
    fi
    if [ "$(( $KEY & $DIGIT ))" != 0 ] ; then
      echo $VALUE
      RESULT=$(echo "$RESULT$VALUE")
    else
      echo '-'
      RESULT=$(echo "${RESULT}-")
    fi
  done
done

echo $RESULT
