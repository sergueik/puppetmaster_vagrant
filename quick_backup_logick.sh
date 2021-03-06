#!/bin/sh

# about to stop SERVICE (apache to mock)
stop_service(){
SERVICE_NAME=${1:nginx}
# "kill -n STOP"  does not work well with apache due to
# need to process all forked processes
  /opt/apache3/bin/apachectl stop
}

start_service(){
SERVICE_NAME=${1:nginx}

  /opt/apache3/bin/apachectl start
}

check_service(){
 SERVICE_NAME=${1:nginx}
 1>&2 echo "SERVICE_NAME=${SERVICE_NAME}"
  COUNT=$(ps ax | grep -i $SERVICE_NAME |grep -v grep |wc -l)
 1>&2 echo "COUNT=${COUNT}"
 if [ "$COUNT" = "0" ]; then
    STATUS=0
  else
    STATUS=1
  fi
echo $STATUS
}

RESULT=$(check_service apache)

echo $RESULT

ARCHIVE='data.tar'
DATADIR=data
BASEDIR='/opt/apache3/'
SCRIPTDIR=$(dirname $0)
cd $BASEDIR
if [ -d $DATADIR ]
then
  # check if there are files
  COUNT=$(find $DATADIR -type f| wc -l)
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
  if [ "$ARCHIVE" -ot "$DATADIR" ]; then
    RESTORE=0
  fi
else
  RESTORE=0
fi

echo "RESTORE=${RESTORE}"
if [ "$RESTORE" = 1 ]
then
  echo 'Will restore'
fi
if [ "$BACKUP" = 1 ]
then
  echo "Will archive data dir $(pwd)/${DATADIR}"
fi
# Done

cd $SCRIPTDIR
