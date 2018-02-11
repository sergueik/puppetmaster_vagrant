#! /bin/bash

DEBUG=false
FLAG1=0
FLAG2=0

# origin:  http://heirloom.sourceforge.net/sh/sh.1.html#20
# uses workaround subshel bash creates for while loop when pipeline is used
# http://mywiki.wooledge.org/BashFAQ/024

exec 5<&0 < /usr/bin/cat <<EOF
# replace with the actual ldap config comand.
have: TLSv1.1
have: TLSv1.2
EOF
while read LINE
do
  if $DEBUG ; then  echo "read ${LINE}" ; fi
  if echo "$LINE" | grep 'TLSv1.1' ; then
    echo 'Found TLSv1.1'
    FLAG1=1
  fi
  if echo "$LINE" | grep 'TLSv1.2' ; then
    echo 'Found TLSv1.2'
    FLAG2=1
  fi
done
exec <&5 5<&-

echo 'After the scan:'
echo "FLAG1=${FLAG1}"
echo "FLAG2=${FLAG2}"
STATUS=0
if [[ $FLAG2 -ne 1 ]]
then
  echo 'TLSv1.2 not found'
  STATUS=1
fi
if [[ $FLAG1 -eq 1 ]]
then
  echo 'TLS v1.1 found'
  STATUS=2
fi
echo Done.
echo "STATUS=${STATUS}"
exit $STATUS
