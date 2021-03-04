#!/bin/sh

# about to stop SERVICE (apache to mock)
stop_service(){
  /opt/apache3/bin/apachectl stop
}

start_service(){
  /opt/apache3/bin/apachectl start
}



check_service(){
SERVICE_NAME=${1:apache}
  COUNT=$(ps ax | grep apache |grep -v grep |wc -l)
 1>&2 echo "COUNT=${COUNT}"
 if [ "$COUNT" = "0" ]; then
    STATUS=0
  else
    STATUS=1
  fi
echo $STATUS
}

RESULT=$(check_service)

echo $RESULT

ARCHIVE='data.tar'
DATA=data
BASEDIR='/opt/apache3/'
SCRIPTDIR=$(dirname $0)
cd $BASEDIR
if [ -d $DATA ]
then
  # TODO: check if there are files
  COUNT=$(find $DATA -type f| wc  -l)
  if [ "$COUNT" != "0" ]; then
    BACKUP=1
  else
    BACKUP=0
  fi
else
  BACKUP=0
fi

echo "BACKUP=${BACKUP}"
if [ -e $ARCHIVE ]
then
  RESTORE=1
  if [ "$ARCHIVE" -ot "$DATA" ]; then
    RESTORE=0
  fi
else
  RESTORE=0
fi

echo "RESTORE=${RESTORE}"
cd $SCRIPTDIR
