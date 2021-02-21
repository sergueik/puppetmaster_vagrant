#!/bin/bash
DATAFILE=${1:-data.properties}  
cat <<EOF>'data.properties'
x: |
a
b
c

y:d,e,f
z:i,j
t:1,2,3
EOF
if [ $DEBUG ] ;then
cat $DATAFILE| while read LINE ; do echo "LINE=\"${LINE}\"";done
fi
INBLOCK=false
EXITBLOCK=false
PARSE_ERROR=false

cat $DATAFILE| while read INPUTLINE ; do 

if $INBLOCK ; then
  echo "${INPUTLINE}"|grep -q ':  *|$'
  if [ $? = 0 ] ; then
    PARSE_ERROR=true
    echo 'Parse error'
    exit 1
  fi
  if [ -z "$INPUTLINE" ]; then
    INBLOCK=false
    EXITBLOCK=true
  fi
fi
echo "${INPUTLINE}"|grep -q ':  *|$'
if [ $? = 0 ] ; then
  INBLOCK=true
  EXITBLOCK=false
fi
if $EXITBLOCK ; then
  echo $OUTPUTLINE
  EXITBLOCK=false
fi

if $INBLOCK ; then
  if [ ! -z "${OUTPUTLINE}" ] ;then
    # hack to prevent dealing with ':,'
    OUTPUTLINE=$(echo "${OUTPUTLINE},${INPUTLINE}"|sed 's|:,|:|')
  else
    OUTPUTLINE=$(echo "$INPUTLINE" | sed 's|: *\|$|:|')
  fi
else
  OUTPUTLINE=$INPUTLINE
  if ! $EXITBLOCK ; then
    echo $OUTPUTLINE
  fi
fi
done
